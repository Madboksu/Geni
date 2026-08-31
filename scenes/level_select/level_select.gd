extends Node2D

# ─────────────────────────────────────────────
#  OVERWORLD LEVEL SELECT
#  Karakter bisa gerak bebas, masuk gerbang
#  untuk ke battle scene atau tempat lain.
# ─────────────────────────────────────────────

const SPEED := 120.0

@onready var player: CharacterBody2D = $Player
@onready var hint_label: Label       = $UI/HintLabel
@onready var act_label: Label        = $UI/ActLabel

var current_gate: Node  = null
var _transitioning: bool = false


func _ready() -> void:
	hint_label.visible = false
	act_label.text     = "ACT %d" % GameManager.current_act

	for gate in $Gates.get_children():
		gate.body_entered.connect(_on_gate_entered.bind(gate))
		gate.body_exited.connect(_on_gate_exited.bind(gate))
		_update_gate_visual(gate)


func _physics_process(_delta: float) -> void:
	if _transitioning:
		player.velocity = Vector2.ZERO
		return

	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"):  direction.x -= 1
	if Input.is_action_pressed("ui_down"):  direction.y += 1
	if Input.is_action_pressed("ui_up"):    direction.y -= 1

	player.velocity = direction.normalized() * SPEED
	player.move_and_slide()

	# Hint label ikut posisi player di screen space
	if hint_label.visible:
		var screen_pos: Vector2 = get_viewport().get_canvas_transform() * player.global_position
		hint_label.position = screen_pos + Vector2(-60, -52)


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_accept") and current_gate != null:
		_enter_gate(current_gate)


# ─────────────────────────────────────────────
#  GATE LOGIC
# ─────────────────────────────────────────────

func _on_gate_entered(body: Node, gate: Node) -> void:
	if body != player:
		return
	current_gate = gate
	var locked: bool = gate.get_meta("locked", false)
	if locked:
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
			var slot := max(StoryData.active_save_slot, 1)
			SaveManager.save_game(slot)
			hint_label.text = "✅ Game Tersimpan!"
			await get_tree().create_timer(2.0).timeout
			if is_instance_valid(hint_label) and current_gate != null:
				hint_label.text = "[E] %s" % current_gate.get_meta("label", "Masuk")

		_:
			_transitioning = false
			push_warning("Gate action tidak dikenal: %s" % gate.get_meta("action", ""))


# ─────────────────────────────────────────────
#  VISUAL
# ─────────────────────────────────────────────

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

	var sprite := gate.get_node_or_null("Sprite")
	if sprite is ColorRect:
		if locked:
			sprite.color = Color(0.30, 0.30, 0.30)
		else:
			match action:
				"battle":
					var lvl: int = gate.get_meta("level", 1)
					# Boss gate warna merah, normal kuning
					sprite.color = Color(0.85, 0.15, 0.10) if lvl == 4 else Color(1.0, 0.78, 0.0)
				"save":
					sprite.color = Color(0.2, 0.8, 0.5)
				"main_menu":
					sprite.color = Color(0.5, 0.5, 0.9)
