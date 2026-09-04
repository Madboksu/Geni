extends Control

signal entity_selected(entity_ui)
signal card_dropped_on_me(card_data: CardData)

@export var entity_data: BattleEntity

@onready var texture_avatar: TextureRect = %TextureAvatar
@onready var lbl_name: Label = get_node("%LblName")
@onready var hp_box: HBoxContainer = get_node("%HpBox")
@onready var hp_bar: ProgressBar = get_node("%HpBar")
@onready var lbl_hp: Label = %LblHp
@onready var lbl_block: Label = get_node("%LblBlock")
@onready var container_status: HBoxContainer = get_node("%ContainerStatus")
@onready var badge_wet: PanelContainer = %BadgeWet
@onready var badge_muddy: PanelContainer = %BadgeMuddy
@onready var badge_stun: PanelContainer = %BadgeStun
@onready var select_border: ReferenceRect = %SelectBorder

var is_selected: bool = false
var current_sprite_frames: SpriteFrames

var block_bar: ProgressBar = null
var current_frame_idx: int = 0
var anim_timer: float = 0.0
var frame_duration: float = 0.166

func setup(p_entity: BattleEntity, avatar_texture: Texture2D = null, p_sprite_frames: SpriteFrames = null) -> void:
	# Putuskan sinyal lama jika sebelumnya sudah ada data
	if entity_data:
		entity_data.hp_changed.disconnect(_on_hp_changed)
		entity_data.block_changed.disconnect(_on_block_changed)
		entity_data.status_changed.disconnect(_on_status_changed)
		
	entity_data = p_entity
	if entity_data:
		entity_data.hp_changed.connect(_on_hp_changed)
		entity_data.block_changed.connect(_on_block_changed)
		entity_data.status_changed.connect(_on_status_changed)
		
	# Mencegah crash jika setup dipanggil sebelum add_child()
	if not is_inside_tree():
		await ready 
		
	current_sprite_frames = p_sprite_frames
	if current_sprite_frames:
		var speed: float = current_sprite_frames.get_animation_speed("idle")
		if speed > 0.0:
			frame_duration = 1.0 / speed
		current_frame_idx = 0
		anim_timer = 0.0
		texture_avatar.texture = current_sprite_frames.get_frame_texture("idle", 0)
	elif avatar_texture:
		current_sprite_frames = null
		texture_avatar.texture = avatar_texture
		
	if not entity_data.is_boss:
		lbl_name.visible = true
		hp_box.visible = true
		hp_bar.visible = true
		lbl_hp.visible = true
		container_status.visible = true
		lbl_block.visible = true
		
		hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hp_bar.custom_minimum_size = Vector2(0, 16)
		hp_bar.show_percentage = false
		
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color(0.8, 0.2, 0.2, 1.0)
		hp_bar.add_theme_stylebox_override("background", style_bg)
		hp_bar.add_theme_stylebox_override("fill", style_fill)
		
		# Move HP label inside the HP bar (overlay on top)


		var my_hp_bar = hp_bar
		var my_lbl_hp = lbl_hp
		if my_lbl_hp and my_hp_bar and my_lbl_hp.get_parent() != my_hp_bar:
			my_lbl_hp.reparent(my_hp_bar)
			
		if my_lbl_hp:
			my_lbl_hp.set_anchors_preset(Control.PRESET_FULL_RECT)
			my_lbl_hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			my_lbl_hp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			my_lbl_hp.add_theme_font_size_override("font_size", 10)
			my_lbl_hp.add_theme_color_override("font_color", Color.WHITE)
			my_lbl_hp.add_theme_color_override("font_outline_color", Color.BLACK)
			my_lbl_hp.add_theme_constant_override("outline_size", 3)
			my_lbl_hp.mouse_filter = Control.MOUSE_FILTER_IGNORE


		
		# Move them to the top (above AvatarBox)
		var vbox = lbl_name.get_parent()
		var avatar_box = vbox.get_node("AvatarBox")
		vbox.move_child(lbl_name, 0)
		vbox.move_child(hp_box, 1)
		vbox.move_child(container_status, 2)
		vbox.move_child(lbl_block, 3)
		vbox.move_child(avatar_box, 4)
		
		# Center text
		lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_block.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_box.alignment = BoxContainer.ALIGNMENT_CENTER
		container_status.alignment = BoxContainer.ALIGNMENT_CENTER
		
	_update_ui()

func _process(delta: float) -> void:
	if current_sprite_frames:
		anim_timer += delta
		if anim_timer >= frame_duration:
			anim_timer -= frame_duration
			var count: int = current_sprite_frames.get_frame_count("idle")
			if count > 0:
				current_frame_idx = (current_frame_idx + 1) % count
				texture_avatar.texture = current_sprite_frames.get_frame_texture("idle", current_frame_idx)


func _ready() -> void:
	
	var lbl_wet = Label.new()
	lbl_wet.text = "WET"
	lbl_wet.add_theme_font_size_override("font_size", 10)
	lbl_wet.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0))
	badge_wet.add_child(lbl_wet)
	
	var lbl_muddy = Label.new()
	lbl_muddy.text = "MUD"
	lbl_muddy.add_theme_font_size_override("font_size", 10)
	lbl_muddy.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
	badge_muddy.add_child(lbl_muddy)
	
	var lbl_stun = Label.new()
	lbl_stun.text = "STUN"
	lbl_stun.add_theme_font_size_override("font_size", 10)
	lbl_stun.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	badge_stun.add_child(lbl_stun)

	block_bar = ProgressBar.new()
	block_bar.custom_minimum_size = Vector2(0, 8)
	block_bar.show_percentage = false
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = Color(0.4, 0.6, 0.9, 1.0)
	block_bar.add_theme_stylebox_override("background", style_bg)
	block_bar.add_theme_stylebox_override("fill", style_fill)
	
	# Add below hp_bar
	if get_node_or_null("VBoxContainer/HpBar"):
		get_node("VBoxContainer").add_child(block_bar)
		get_node("VBoxContainer").move_child(block_bar, get_node("VBoxContainer/HpBar").get_index() + 1)
	elif hp_bar:
		hp_bar.get_parent().add_child(block_bar)
	
	_update_ui()


func _update_ui() -> void:
	if not is_inside_tree() or not entity_data:
		return
	lbl_name.text = entity_data.entity_name
	hp_bar.max_value = entity_data.max_hp
	hp_bar.value = entity_data.current_hp
	lbl_hp.text = "%d / %d" % [entity_data.current_hp, entity_data.max_hp]
	lbl_block.text = "Block: %d" % entity_data.current_block
	if block_bar:
		block_bar.max_value = entity_data.max_hp
		block_bar.value = entity_data.current_block
	
	badge_wet.visible = entity_data.is_wet
	badge_muddy.visible = entity_data.is_muddy
	badge_stun.visible = entity_data.is_stunned
	
	if entity_data.is_boss:
		pass

func set_selected(p_selected: bool) -> void:
	is_selected = p_selected
	select_border.visible = false

func _on_hp_changed(new_hp: int, max_hp: int) -> void:
	var diff = new_hp - hp_bar.value
	if diff < 0:
		_spawn_floating_text(str(diff), Color.RED)
	elif diff > 0:
		_spawn_floating_text("+" + str(diff), Color.GREEN)
		
	if new_hp < hp_bar.value:
		if entity_data.is_player:
			GameManager.play_sfx("get_hit", -5.0)
		else:
			GameManager.play_sfx("hit", -5.0)
	hp_bar.value = new_hp
	lbl_hp.text = "%d / %d" % [new_hp, max_hp]
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(texture_avatar, "modulate", Color(2.0, 0.4, 0.4), 0.1)
	
	# Shake effect
	var avatar_box = get_node("VBoxContainer/AvatarBox")
	var original_pos = avatar_box.position
	
	var shake_tw = create_tween()
	shake_tw.tween_property(avatar_box, "position", original_pos + Vector2(30, 0), 0.05)
	shake_tw.tween_property(avatar_box, "position", original_pos + Vector2(-30, 0), 0.05)
	shake_tw.tween_property(avatar_box, "position", original_pos + Vector2(15, 0), 0.05)
	shake_tw.tween_property(avatar_box, "position", original_pos + Vector2(-15, 0), 0.05)
	shake_tw.tween_property(avatar_box, "position", original_pos, 0.05)
	
	tween.chain().tween_property(texture_avatar, "modulate", Color.WHITE, 0.2)

func _on_block_changed(new_block: int) -> void:
	if block_bar: block_bar.value = new_block
	if new_block > 0 and lbl_block.text != ("Block: %d" % new_block):
		GameManager.play_sfx("click", -5.0) # Sound for gaining shield
	lbl_block.text = "Block: %d" % new_block


func _on_status_changed() -> void:
	if entity_data:
		badge_wet.visible = entity_data.is_wet
		badge_muddy.visible = entity_data.is_muddy
		badge_stun.visible = entity_data.is_stunned

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		entity_selected.emit(self)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is CardData:
		# Opsional: Kamu bisa menambahkan logika visual hover di sini
		# misal: set_selected(true)
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is CardData:
		# Opsional: Matikan visual hover setelah di-drop
		# set_selected(false)
		card_dropped_on_me.emit(data)

func _spawn_floating_text(msg: String, color: Color) -> void:
	var lbl = Label.new()
	lbl.text = msg
	lbl.add_theme_color_override("font_color", color)
	if is_inside_tree() and lbl_name:
		lbl.add_theme_font_override("font", lbl_name.get_theme_font("font"))
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
	
	add_child(lbl)
	lbl.position = texture_avatar.position + Vector2(randf_range(20, 100), randf_range(20, 50))
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 50, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(lbl.queue_free)
