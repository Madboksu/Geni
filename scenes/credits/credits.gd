extends Control

@onready var title_image: TextureRect = %TitleImage
@onready var btn_back: Button = %BtnBack

var _anim_time: float = 0.0
var _title_base_y: float = 18.0

func _ready() -> void:
	if is_instance_valid(title_image):
		_title_base_y = title_image.position.y
		title_image.pivot_offset = title_image.size * 0.5
	
	btn_back.pressed.connect(_on_btn_back_pressed)
	_setup_back_button_juice()

func _process(delta: float) -> void:
	_anim_time += delta
	if is_instance_valid(title_image):
		title_image.position.y = _title_base_y + sin(_anim_time * 2.0) * 4.0
		title_image.rotation = sin(_anim_time * 1.0) * 0.012

func _setup_back_button_juice() -> void:
	btn_back.pivot_offset = btn_back.size * 0.5
	btn_back.mouse_entered.connect(func():
		var tw = create_tween()
		tw.tween_property(btn_back, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	btn_back.mouse_exited.connect(func():
		var tw = create_tween()
		tw.tween_property(btn_back, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn_back.button_down.connect(func():
		var tw = create_tween()
		tw.tween_property(btn_back, "scale", Vector2(0.96, 0.96), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn_back.button_up.connect(func():
		var tw = create_tween()
		tw.tween_property(btn_back, "scale", Vector2(1.06, 1.06), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

func _on_btn_back_pressed() -> void:
	GameManager.load_scene("res://scenes/main_menu/main_menu.tscn")

