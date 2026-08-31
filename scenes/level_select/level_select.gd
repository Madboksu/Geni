extends Node2D

# ─────────────────────────────────────────────
#  OVERWORLD LEVEL SELECT
#  Karakter bisa gerak bebas, masuk gerbang
#  untuk ke battle scene atau tempat lain.
# ─────────────────────────────────────────────

const SPEED := 120.0

# Referensi node
@onready var player: CharacterBody2D = $Player
@onready var hint_label: Label       = $UI/HintLabel
@onready var act_label: Label        = $UI/ActLabel

# Gerbang yang sedang disentuh player (null = tidak ada)
var current_gate: Node = null


func _ready() -> void:
	hint_label.visible = false
	act_label.text = "ACT %d" % GameManager.current_act

	# Sambungkan sinyal semua gerbang
	for gate in $Gates.get_children():
		gate.body_entered.connect(_on_gate_entered.bind(gate))
		gate.body_exited.connect(_on_gate_exited.bind(gate))
		_update_gate_visual(gate)


func _physics_process(_delta: float) -> void:
	# ── Gerakan karakter (WASD / Arrow Keys) ──
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"):  direction.x -= 1
	if Input.is_action_pressed("ui_down"):  direction.y += 1
	if Input.is_action_pressed("ui_up"):    direction.y -= 1

	player.velocity = direction.normalized() * SPEED
	player.move_and_slide()

	# Hint label mengikuti posisi player
	if hint_label.visible:
		hint_label.global_position = player.global_position + Vector2(-50, -44)


func _unhandled_input(event: InputEvent) -> void:
	# Tekan E / Space / Enter untuk masuk gerbang
	if event.is_action_pressed("ui_accept") and current_gate != null:
		_enter_gate(current_gate)


# ─────────────────────────────────────────────
#  GATE LOGIC
# ─────────────────────────────────────────────

func _on_gate_entered(body: Node, gate: Node) -> void:
	if body != player:
		return
	current_gate = gate
	var is_locked: bool = gate.get_meta("locked", false)
	if is_locked:
		hint_label.text = "🔒 Terkunci"
	else:
		hint_label.text = "[E] %s" % gate.get_meta("label", "Masuk")
	hint_label.visible = true


func _on_gate_exited(body: Node, gate: Node) -> void:
	if body != player:
		return
	if current_gate == gate:
		current_gate = null
		hint_label.visible = false


func _enter_gate(gate: Node) -> void:
	if gate.get_meta("locked", false):
		return

	match gate.get_meta("action", ""):
		"battle":
			GameManager.current_act   = gate.get_meta("act",   1)
			GameManager.current_level = gate.get_meta("level", 1)
			GameManager.load_scene("res://scenes/battle/battle_scene.tscn")

		"main_menu":
			GameManager.load_scene("res://scenes/main_menu/main_menu.tscn")

		"save":
			var slot := StoryData.active_save_slot if StoryData.active_save_slot > 0 else 1
			SaveManager.save_game(slot)
			hint_label.text = "✅ Game Tersimpan!"
			await get_tree().create_timer(2.0).timeout
			if current_gate != null:
				hint_label.text = "[E] %s" % current_gate.get_meta("label", "Masuk")

		_:
			push_warning("Gate action tidak dikenal: %s" % gate.get_meta("action", ""))


func _update_gate_visual(gate: Node) -> void:
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

	# Ubah warna kotak gerbang: abu-abu = terkunci, kuning = terbuka
	var sprite := gate.get_node_or_null("Sprite")
	if sprite is ColorRect:
		sprite.color = Color(0.35, 0.35, 0.35) if locked else Color(1.0, 0.78, 0.0)
