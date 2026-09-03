extends Node2D

# ─────────────────────────────────────────────
#  OVERWORLD LEVEL SELECT
#  Karakter bisa gerak bebas, masuk gerbang
#  untuk ke battle scene atau tempat lain.
# ─────────────────────────────────────────────

const SPEED := 120.0

@onready var player:     CharacterBody2D = $Player
@onready var hint_label: Label           = $UI/HintLabel
@onready var act_label:  Label           = $UI/ActLabel

var current_gate: Area2D = null
var _transitioning: bool = false


func _ready() -> void:
	hint_label.visible = false
	act_label.text     = "ACT %d" % GameManager.current_act

	for gate: Area2D in $Gates.get_children():
		# BUG FIX: set locked state DULU sebelum connect sinyal,
		# supaya saat body_entered terpicu, meta "locked" sudah ada
		_update_gate_visual(gate)
		gate.body_entered.connect(_on_gate_entered.bind(gate))
		gate.body_exited.connect(_on_gate_exited.bind(gate))


func _physics_process(_delta: float) -> void:
	if _transitioning:
		player.velocity = Vector2.ZERO
		return

	var direction := Vector2.ZERO
	# Arrow Keys
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"):  direction.x -= 1
	if Input.is_action_pressed("ui_down"):  direction.y += 1
	if Input.is_action_pressed("ui_up"):    direction.y -= 1

	player.velocity = direction.normalized() * SPEED
	player.move_and_slide()

	# BUG FIX: hint_label ada di CanvasLayer (screen space).
	# Gunakan global_position player langsung — CanvasLayer layer=0 pakai
	# world→screen transform yang sama dengan viewport, jadi tidak perlu konversi manual.
	if hint_label.visible:
		hint_label.position = player.global_position + Vector2(-60, -52)


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_accept") and current_gate != null:
		_enter_gate(current_gate)


# ─────────────────────────────────────────────
#  GATE LOGIC
# ─────────────────────────────────────────────

func _on_gate_entered(body: Node, gate: Area2D) -> void:
	# BUG FIX: hanya CharacterBody2D (player) yang boleh trigger —
	# StaticBody2D dinding juga ada di collision_layer 1 sehingga bisa masuk sinyal ini
	if not body is CharacterBody2D:
		return
	if body != player:
		return

	current_gate = gate
	var locked: bool = gate.get_meta("locked", false)
	if locked:
		hint_label.text = "🔒 Terkunci"
	else:
		hint_label.text = "[E] %s" % gate.get_meta("label", "Masuk")
	hint_label.visible = true


func _on_gate_exited(body: Node, gate: Area2D) -> void:
	if not body is CharacterBody2D:
		return
	if body != player:
		return
	if current_gate == gate:
		current_gate = null
		hint_label.visible = false
		hint_label.text    = "[E] Masuk"  # reset teks default


func _enter_gate(gate: Area2D) -> void:
	if gate.get_meta("locked", false) or _transitioning:
		return
	_transitioning = true

	match gate.get_meta("action", ""):
		"battle":
			GameManager.current_act   = gate.get_meta("act",   1)
			GameManager.current_level = gate.get_meta("level", 1)
			GameManager.load_scene("res://scenes/battle/battle_scene.tscn")

		"main_menu":
			GameManager.load_scene("res://scenes/main_menu/main_menu.tscn")

		"save":
			_transitioning = false
			var slot: int = maxi(StoryData.active_save_slot, 1)
			SaveManager.save_game(slot)
			hint_label.text    = "✅ Game Tersimpan!"
			hint_label.visible = true  # pastikan visible saat konfirmasi
			await get_tree().create_timer(2.0).timeout
			# BUG FIX: setelah await, cek apakah player MASIH di gate save ini
			# (bisa saja player sudah keluar selagi menunggu 2 detik)
			if is_instance_valid(hint_label):
				if current_gate != null:
					hint_label.text = "[E] %s" % current_gate.get_meta("label", "Masuk")
				else:
					hint_label.visible = false

		_:
			_transitioning = false
			push_warning("Gate action tidak dikenal: %s" % gate.get_meta("action", ""))


# ─────────────────────────────────────────────
#  VISUAL
# ─────────────────────────────────────────────

func _update_gate_visual(gate: Area2D) -> void:
	var action: String = gate.get_meta("action", "")
	var locked := false

	if action == "battle":
		var req_act:   int = gate.get_meta("act",   1)
		var req_level: int = gate.get_meta("level", 1)
		if req_act == 1:
			locked = req_level > GameManager.act1_max_level_unlocked
		elif req_act == 2:
			locked = req_level > GameManager.act2_max_level_unlocked

	gate.set_meta("locked", locked)

	var sprite := gate.get_node_or_null("Sprite")
	if sprite is ColorRect:
		if locked:
			sprite.color = Color(0.30, 0.30, 0.30)
		else:
			match action:
				"battle":
					var lvl: int = gate.get_meta("level", 1)
					sprite.color = Color(0.85, 0.15, 0.10) if lvl == 4 else Color(1.0, 0.78, 0.0)
				"save":
					sprite.color = Color(0.2, 0.8, 0.5)
				"main_menu":
					sprite.color = Color(0.5, 0.5, 0.9)

	# Update label teks gate agar tampilkan status
	var label_node := gate.get_node_or_null("Label")
	if label_node is Label:
		if locked:
			label_node.modulate = Color(0.5, 0.5, 0.5)  # redup jika terkunci
		else:
			label_node.modulate = Color(1, 1, 1)
