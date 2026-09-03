extends Control

signal entity_selected(entity_ui)
signal card_dropped_on_me(card_data: CardData)

@export var entity_data: BattleEntity

@onready var texture_avatar: TextureRect = %TextureAvatar
@onready var lbl_name: Label = %LblName
@onready var hp_bar: ProgressBar = %HpBar
@onready var lbl_hp: Label = %LblHp
@onready var lbl_block: Label = %LblBlock
@onready var container_status: HBoxContainer = %ContainerStatus
@onready var badge_wet: PanelContainer = %BadgeWet
@onready var badge_muddy: PanelContainer = %BadgeMuddy
@onready var badge_stun: PanelContainer = %BadgeStun
@onready var select_border: ReferenceRect = %SelectBorder

var is_selected: bool = false
var current_sprite_frames: SpriteFrames = null
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
	_update_ui()

func _update_ui() -> void:
	if not is_inside_tree() or not entity_data:
		return
	lbl_name.text = entity_data.entity_name
	hp_bar.max_value = entity_data.max_hp
	hp_bar.value = entity_data.current_hp
	lbl_hp.text = "%d / %d" % [entity_data.current_hp, entity_data.max_hp]
	lbl_block.text = "Block: %d" % entity_data.current_block
	
	badge_wet.visible = entity_data.is_wet
	badge_muddy.visible = entity_data.is_muddy
	badge_stun.visible = entity_data.is_stunned

func set_selected(p_selected: bool) -> void:
	is_selected = p_selected
	select_border.visible = false

func _on_hp_changed(new_hp: int, max_hp: int) -> void:
	hp_bar.value = new_hp
	lbl_hp.text = "%d / %d" % [new_hp, max_hp]
	
	var tween = create_tween()
	tween.tween_property(texture_avatar, "modulate", Color(2.0, 0.4, 0.4), 0.1)
	tween.tween_property(texture_avatar, "modulate", Color.WHITE, 0.2)

func _on_block_changed(new_block: int) -> void:
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
