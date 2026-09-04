extends Control

# Scenes & UI References
@onready var container_enemies: HBoxContainer = %ContainerEnemies
@onready var container_hand: HBoxContainer = %ContainerHand
@onready var btn_execute: Button = %BtnExecute
@onready var lbl_energy: Label = %LblEnergy
@onready var lbl_battle_log: Label = %LblBattleLog
@onready var reward_popup: Control = %RewardPopup
@onready var win_loss_panel: PanelContainer = %WinLossPanel
@onready var lbl_win_loss_title: Label = %LblWinLossTitle
@onready var btn_continue: Button = %BtnContinue
@onready var btn_winloss_restart: Button = %BtnWinLossRestart
@onready var btn_winloss_exit: Button = %BtnWinLossExit
@onready var btn_pause: TextureButton = %BtnPause
@onready var pause_panel: PanelContainer = %PausePanel
@onready var btn_pause_resume: Button = %BtnPauseResume
@onready var btn_pause_restart: Button = %BtnPauseRestart
@onready var btn_pause_exit: Button = %BtnPauseExit

@onready var zoom_overlay: Control = %ZoomOverlay
@onready var zoom_card_holder: Control = %ZoomCardHolder
var zoom_card_instance: Control = null

# Corner HUD References (Pucuk-Pucuk)
@onready var player_hp_bar: ProgressBar = %PlayerHpBar
@onready var lbl_player_hp: Label = %LblPlayerHp
@onready var lbl_player_block: Label = %LblPlayerBlock
@onready var player_status: HBoxContainer = %PlayerStatus

@onready var boss_hud: PanelContainer = %BossHUD
@onready var lbl_boss_name: Label = %LblBossName
@onready var boss_hp_bar: ProgressBar = %BossHpBar
@onready var lbl_boss_hp: Label = %LblBossHp
@onready var lbl_boss_block: Label = %LblBossBlock
@onready var boss_status: HBoxContainer = %BossStatus

# Preloads
var card_ui_scene = preload("res://scenes/battle/components/card_ui.tscn")
var entity_ui_scene = preload("res://scenes/battle/components/entity_ui.tscn")

# Preloaded SVG textures
var avatar_wolf_tex = preload("res://assets/placeholders/monster_wolf.svg")
var avatar_golem_tex = preload("res://assets/placeholders/monster_golem.svg")
var avatar_boss1_tex = preload("res://assets/placeholders/monster_boss1.svg")
var avatar_boss2_tex = preload("res://assets/placeholders/monster_boss2.svg")
var anim_tree_grunt = preload("res://assets/monsters/tree_grunt/tree_grunt_frames.tres")
var anim_tree_boss = preload("res://assets/monsters/tree_boss/tree_boss_frames.tres")
var tex_burn_tree_boss = preload("res://assets/burn-tree-boss-static.png")
var anim_burn_tree_boss = preload("res://assets/monsters/burn_tree_boss/burn_tree_boss_frames.tres")
var anim_kroco = preload("res://assets/monsters/monsterkroco/kroco_frames.tres")
var anim_kroco2 = preload("res://assets/monsters/kroco2/kroco2_frames.tres")
var anim_krocoijo = preload("res://assets/monsters/krocoijo/krocoijo_frames.tres")
var anim_flowery_boss = preload("res://assets/monsters/flowery_boss/flowery_frames.tres")
var anim_flowery_final = preload("res://assets/monsters/flowery_final/flowery_final_frames.tres")

# Battle Data State
var player_entity: BattleEntity
var enemy_entities: Array = []
var enemy_ui_nodes: Array = []

var current_energy: int = 3
var max_energy: int = 3

var draw_pile: Array = []
var hand: Array = [] # CardData objects
var discard_pile: Array = []

var target_enemy_index: int = 0
var is_executing: bool = false

var combat_log_panel: PanelContainer
var combat_log_text: RichTextLabel


func _ready() -> void:
	reward_popup.visible = false
	win_loss_panel.visible = false
	zoom_overlay.visible = false
	zoom_overlay.gui_input.connect(_on_zoom_overlay_gui_input)
	btn_execute.pressed.connect(_on_btn_execute_pressed)
	btn_continue.pressed.connect(_on_btn_continue_pressed)

	btn_winloss_restart.pressed.connect(_on_btn_restart_pressed)
	btn_winloss_exit.pressed.connect(_on_btn_exit_pressed)
	
	btn_pause.pressed.connect(func(): 
		GameManager.play_sfx("click", -5.0)
		pause_panel.visible = true
	)
	btn_pause_resume.pressed.connect(func():
		GameManager.play_sfx("click", -5.0)
		pause_panel.visible = false
	)
	btn_pause_restart.pressed.connect(_on_btn_restart_pressed)
	btn_pause_exit.pressed.connect(_on_btn_exit_pressed)

	reward_popup.reward_selected.connect(_on_reward_selected)
	
	_setup_battle()
	_show_tutorial_if_needed()

var _tutorial_active: bool = false
var _tutorial_step: int = 0
var _tutorial_overlay: ColorRect
var _tutorial_title: Label
var _tutorial_desc: Label
var _tutorial_btn: Button
var _tutorial_visual: Control

func _show_tutorial_if_needed() -> void:
	if GameManager.current_act == 1 and GameManager.current_level == 1:
		_tutorial_active = true
		_tutorial_step = 0
		_tutorial_overlay = ColorRect.new()
		_tutorial_overlay.set_anchors_preset(PRESET_FULL_RECT)
		_tutorial_overlay.color = Color(0, 0, 0, 0.4) # AGAK REDUP
		_tutorial_overlay.z_index = 100
		_tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_tutorial_overlay)
		
		_tutorial_visual = Control.new()
		_tutorial_visual.set_anchors_preset(PRESET_FULL_RECT)
		_tutorial_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tutorial_overlay.add_child(_tutorial_visual)
		
		var float_container = Control.new()
		float_container.set_anchors_preset(PRESET_FULL_RECT)
		float_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tutorial_overlay.add_child(float_container)
		
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(480, 240)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE # BIAR BISA KLIK MUSUH TEMBUS PANEL
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.1, 0.14, 0.85)
		style.border_color = Color(0.75, 0.55, 0.22, 0.9)
		style.border_width_bottom = 2
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.set_corner_radius_all(10)
		panel.add_theme_stylebox_override("panel", style)
		
		float_container.add_child(panel)
		panel.position = Vector2(1280 / 2.0 - 240, 20)
		
		var margin = MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_theme_constant_override("margin_left", 24)
		margin.add_theme_constant_override("margin_right", 24)
		margin.add_theme_constant_override("margin_top", 24)
		margin.add_theme_constant_override("margin_bottom", 24)
		panel.add_child(margin)

		var vbox = VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 24)
		margin.add_child(vbox)
		
		var font = preload("res://assets/card/PublicPixel.ttf")
		
		_tutorial_title = Label.new()
		_tutorial_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_tutorial_title.add_theme_font_override("font", font)
		_tutorial_title.add_theme_font_size_override("font_size", 14)
		_tutorial_title.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
		vbox.add_child(_tutorial_title)
		
		_tutorial_desc = Label.new()
		_tutorial_desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tutorial_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_tutorial_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_tutorial_desc.add_theme_font_override("font", font)
		_tutorial_desc.add_theme_font_size_override("font_size", 9)
		_tutorial_desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
		vbox.add_child(_tutorial_desc)
		
		_tutorial_btn = Button.new()
		_tutorial_btn.mouse_filter = Control.MOUSE_FILTER_STOP # Button needs to be clickable
		_tutorial_btn.custom_minimum_size = Vector2(220, 36)
		_tutorial_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_tutorial_btn.add_theme_font_override("font", font)
		_tutorial_btn.add_theme_font_size_override("font_size", 10)
		_tutorial_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.7, 0.25, 0.05, 0.9)
		btn_style.border_color = Color(1, 0.75, 0.2, 0.9)
		btn_style.border_width_bottom = 2
		btn_style.border_width_top = 2
		btn_style.border_width_left = 2
		btn_style.border_width_right = 2
		btn_style.set_corner_radius_all(6)
		_tutorial_btn.add_theme_stylebox_override("normal", btn_style)
		_tutorial_btn.add_theme_stylebox_override("hover", btn_style)
		_tutorial_btn.add_theme_stylebox_override("pressed", btn_style)
		_tutorial_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		vbox.add_child(_tutorial_btn)
		
		_tutorial_btn.pressed.connect(_on_tutorial_next)
		
		_tutorial_overlay.modulate.a = 0.0
		var tw2 = create_tween()
		tw2.tween_property(_tutorial_overlay, "modulate:a", 1.0, 0.2)
		
		_update_tutorial_step()

func _update_tutorial_step() -> void:
	for c in _tutorial_visual.get_children():
		c.queue_free()
		
	var font = preload("res://assets/card/PublicPixel.ttf")
	
	if _tutorial_step == 0:
		_tutorial_title.text = "1. INFO KARTU"
		_tutorial_desc.text = "Klik Kanan pada salah satu kartu di bawah untuk melihat detail fungsinya."
		_tutorial_btn.visible = false
		btn_execute.disabled = true
		
		var arrow = Label.new()
		arrow.text = "⬇"
		arrow.add_theme_font_override("font", font)
		arrow.add_theme_font_size_override("font_size", 54)
		arrow.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		arrow.position = Vector2(1280 / 2.0 - 24, 720 - 260)
		_tutorial_visual.add_child(arrow)
		
		var tw = create_tween().bind_node(arrow).set_loops()
		tw.tween_property(arrow, "position:y", 720 - 210, 1.2).set_trans(Tween.TRANS_SINE)
		tw.tween_property(arrow, "modulate:a", 0.0, 0.2)
		tw.tween_property(arrow, "position:y", 720 - 260, 0.0)
		tw.tween_property(arrow, "modulate:a", 1.0, 0.2)
		
	elif _tutorial_step == 1:
		_tutorial_title.text = "2. CARA BERMAIN"
		_tutorial_desc.text = "Tarik (Drag) salah satu kartu dari area bawah dan arahkan langsung ke tubuh musuh di tengah layar."
		_tutorial_btn.visible = false
		btn_execute.disabled = true
		
		var arrow = Label.new()
		arrow.text = "⬆"
		arrow.add_theme_font_override("font", font)
		arrow.add_theme_font_size_override("font_size", 54)
		arrow.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		arrow.position = Vector2(1280 / 2.0 - 24, 720 - 220)
		_tutorial_visual.add_child(arrow)
		
		var tw = create_tween().bind_node(arrow).set_loops()
		tw.tween_property(arrow, "position:y", 720 / 2.0 - 40, 1.2).set_trans(Tween.TRANS_SINE)
		tw.tween_property(arrow, "modulate:a", 0.0, 0.2)
		tw.tween_property(arrow, "position:y", 720 - 220, 0.0)
		tw.tween_property(arrow, "modulate:a", 1.0, 0.2)
		
	elif _tutorial_step == 2:
		_tutorial_title.text = "3. BATAS ENERGY"
		_tutorial_desc.text = "Hebat! Setiap giliran, kamu hanya diberi jatah 3 ENERGY.\nSetiap kartu memakan sejumlah Energy.\n\n(Ketuk layar di mana saja untuk lanjut)"
		_tutorial_btn.visible = false
		btn_execute.disabled = false
		
		# Layar bisa ditap untuk lanjut
		var tap_btn = Button.new()
		tap_btn.set_anchors_preset(PRESET_FULL_RECT)
		tap_btn.modulate.a = 0.0
		_tutorial_visual.add_child(tap_btn)
		tap_btn.pressed.connect(func():
			_tutorial_step = 3
			_update_tutorial_step()
		)
		
		var arrow = Label.new()
		arrow.text = "↖ ENERGY"
		arrow.add_theme_font_override("font", font)
		arrow.add_theme_font_size_override("font_size", 14)
		arrow.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
		arrow.position = Vector2(250, 70)
		_tutorial_visual.add_child(arrow)
		
		var tw = create_tween().bind_node(arrow).set_loops()
		tw.tween_property(arrow, "position:x", 210, 0.6).set_trans(Tween.TRANS_SINE)
		tw.tween_property(arrow, "position:x", 250, 0.6).set_trans(Tween.TRANS_SINE)

	elif _tutorial_step == 3:
		_tutorial_title.text = "4. CONTOH COMBO"
		_tutorial_desc.text = "Beberapa kartu menciptakan reaksi COMBO mematikan!\n\nContoh: Gunakan kartu [Douse] untuk memberi musuh efek basah (WET). Lanjutkan dengan [Thunder Strike]. Petir akan menyetrum musuh basah, meledak, dan memberikan efek [STUN]!\n\nMusuh berstatus STUN akan diam dan membuang 1 gilirannya.\nJika energi habis atau selesai, tekan AKHIRI GILIRAN."
		_tutorial_btn.text = "MENGERTI"
		_tutorial_btn.visible = true
		btn_execute.disabled = false
		
func _on_tutorial_next() -> void:
	if _tutorial_step == 3:
		_tutorial_active = false
		var tw = create_tween()
		tw.tween_property(_tutorial_overlay, "modulate:a", 0.0, 0.2)
		tw.tween_callback(_tutorial_overlay.queue_free)
		# Jangan otomatis akhiri giliran, biarkan pemain main kartu sisa atau klik manual

func _setup_battle() -> void:
	_log("Memulai Pertarungan - Act %d Level %d" % [GameManager.current_act, GameManager.current_level])
	
	# 1. Setup Player
	player_entity = BattleEntity.new()
	player_entity.entity_name = GameManager.player_name
	player_entity.max_hp = GameManager.player_max_hp
	player_entity.current_hp = GameManager.player_current_hp
	player_entity.is_player = true
	
	player_entity.hp_changed.connect(_update_player_hud)
	player_entity.block_changed.connect(_update_player_hud)
	player_entity.status_changed.connect(_update_player_hud)
	_update_player_hud()
	
	# 2. Setup Enemies based on level
	enemy_entities.clear()
	enemy_ui_nodes.clear()
	for child in container_enemies.get_children():
		child.queue_free()
		
	var enemy_configs = _get_level_enemy_config(GameManager.current_act, GameManager.current_level)
	for i in range(enemy_configs.size()):
		var cfg = enemy_configs[i]
		var enemy = BattleEntity.new()
		enemy.entity_name = cfg["name"]
		enemy.max_hp = cfg["hp"]
		enemy.current_hp = cfg["hp"]
		enemy.is_boss = cfg.get("is_boss", false)
		enemy_entities.append(enemy)
		
		var enemy_ui = entity_ui_scene.instantiate()
		container_enemies.add_child(enemy_ui)
		var frames = cfg.get("sprite_frames", null)
		var tex = cfg.get("texture", null)
		enemy_ui.setup(enemy, tex, frames)
		
		# Shrink to fit if multiple enemies or explicitly small
		var is_small = cfg.get("is_small", false)
		if is_small:
			enemy_ui.custom_minimum_size = Vector2(250, 300)
			
		var enemy_idx = i
		enemy_ui.entity_selected.connect(func(_ui): _select_target_enemy(enemy_idx))
		enemy_ui.card_dropped_on_me.connect(_on_card_dropped.bind(enemy))
		enemy_ui_nodes.append(enemy_ui)
		
		enemy.hp_changed.connect(_update_boss_hud)
		enemy.block_changed.connect(_update_boss_hud)
		enemy.status_changed.connect(_update_boss_hud)
		
	if enemy_ui_nodes.size() > 0:
		_select_target_enemy(0)
		
	# 3. Setup Deck & Draw Pile
	draw_pile = GameManager.player_deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
		
	_setup_particles()
	_setup_combat_log()
	_start_player_turn()

func _update_player_hud(_a = null, _b = null) -> void:
	if not player_entity:
		return
	player_hp_bar.max_value = player_entity.max_hp
	player_hp_bar.value = maxi(player_entity.current_hp, 0)
	lbl_player_hp.text = "%d/%d" % [maxi(player_entity.current_hp, 0), player_entity.max_hp]
	lbl_player_block.text = "Block: %d" % player_entity.current_block
	
	# Update player status badges
	for child in player_status.get_children():
		child.queue_free()
	if player_entity.is_wet:
		_add_status_badge(player_status, "[Wet]", Color(0.2, 0.8, 1))
	if player_entity.is_muddy:
		_add_status_badge(player_status, "[Muddy]", Color(0.8, 0.6, 0.3))
	if player_entity.is_stunned:
		_add_status_badge(player_status, "[Stun]", Color(1, 0.8, 0.2))

func _update_boss_hud(_a = null, _b = null) -> void:
	if enemy_entities.is_empty() or target_enemy_index >= enemy_entities.size():
		boss_hud.visible = false
		return
		
	var target: BattleEntity = enemy_entities[target_enemy_index]
	if not target.is_boss:
		boss_hud.visible = false
		return
		
	boss_hud.visible = true
	lbl_boss_name.text = target.entity_name
	boss_hp_bar.max_value = target.max_hp
	boss_hp_bar.value = maxi(target.current_hp, 0)
	lbl_boss_hp.text = "%d/%d" % [maxi(target.current_hp, 0), target.max_hp]
	lbl_boss_block.text = "Block: %d" % target.current_block
	
	# Update boss status badges
	for child in boss_status.get_children():
		child.queue_free()
	if target.is_wet:
		_add_status_badge(boss_status, "[Wet]", Color(0.2, 0.8, 1))
	if target.is_muddy:
		_add_status_badge(boss_status, "[Muddy]", Color(0.8, 0.6, 0.3))
	if target.is_stunned:
		_add_status_badge(boss_status, "[Stun]", Color(1, 0.8, 0.2))

func _add_status_badge(parent: HBoxContainer, text: String, color: Color) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 8)
	parent.add_child(lbl)

func _get_level_enemy_config(act: int, level: int) -> Array:
	if act == 1:
		match level:
			1: # Level 1: 1 Kroco
				return [
					{"name": "Pohon Kroco", "hp": 25, "sprite_frames": anim_kroco, "is_small": true}
				]
			2: # Level 2: 2 Kroco (beda jenis)
				return [
					{"name": "Pohon Kroco", "hp": 25, "sprite_frames": anim_kroco, "is_small": true},
					{"name": "Kroco Ijo", "hp": 25, "sprite_frames": anim_krocoijo, "is_small": true}
				]
			3: # Level 3: 3 Kroco (semua jenis)
				return [
					{"name": "Pohon Kroco", "hp": 25, "sprite_frames": anim_kroco, "is_small": true},
					{"name": "Kroco Gelap", "hp": 30, "sprite_frames": anim_kroco2, "is_small": true},
					{"name": "Kroco Ijo", "hp": 25, "sprite_frames": anim_krocoijo, "is_small": true}
				]
			4: # Level 4: 1 Mini Boss (Tidak berapi)
				return [
					{"name": "Grown Tree Beast (MINI BOSS)", "hp": 100, "sprite_frames": anim_tree_boss, "is_boss": true}
				]
			5: # Level 5: 1 Boss (Berapi, Darah Lebih Banyak)
				return [
					{"name": "Ember Beast (BOSS)", "hp": 250, "sprite_frames": anim_burn_tree_boss, "is_boss": true}
				]
	else:
		# Act 2: sama kroco tapi HP lebih banyak + flowery boss
		match level:
			1:
				return [
					{"name": "Kroco Ijo", "hp": 40, "sprite_frames": anim_krocoijo, "is_small": true}
				]
			2:
				return [
					{"name": "Kroco Gelap", "hp": 40, "sprite_frames": anim_kroco2, "is_small": true},
					{"name": "Kroco Ijo", "hp": 40, "sprite_frames": anim_krocoijo, "is_small": true}
				]
			3:
				return [
					{"name": "Pohon Kroco", "hp": 40, "sprite_frames": anim_kroco, "is_small": true},
					{"name": "Kroco Gelap", "hp": 50, "sprite_frames": anim_kroco2, "is_small": true},
					{"name": "Kroco Ijo", "hp": 40, "sprite_frames": anim_krocoijo, "is_small": true}
				]
			4: # Mini Boss Act 2
				return [
					{"name": "Flowery Scout (MINI BOSS)", "hp": 150, "sprite_frames": anim_flowery_final, "is_boss": true}
				]
			5: # Final Boss Act 2: Flowery
				return [
					{"name": "Flowery Queen (BOSS)", "hp": 300, "sprite_frames": anim_flowery_boss, "is_boss": true}
				]
			_:
				return [
					{"name": "Kroco Gelap", "hp": 45, "sprite_frames": anim_kroco2, "is_small": true},
					{"name": "Kroco Ijo", "hp": 45, "sprite_frames": anim_krocoijo, "is_small": true}
				]
	return [{"name": "Pohon Kroco", "hp": 25, "sprite_frames": anim_kroco, "is_small": true}]

func _select_target_enemy(index: int) -> void:
	target_enemy_index = index
	for i in range(enemy_ui_nodes.size()):
		enemy_ui_nodes[i].set_selected(i == index)
	_update_boss_hud()

func _start_player_turn() -> void:
	is_executing = false
	current_energy = max_energy
	_update_energy_ui()
	player_entity.reset_turn()
	_update_player_hud()
	
	# Draw 5 cards
	_draw_cards(5)
	_render_hand_ui()
	btn_execute.disabled = false
	_log("Giliran Pemain: Tarik dan mainkan kartu ke musuh.")

func _draw_cards(count: int) -> void:
	for i in range(count):
		if draw_pile.size() == 0:
			if discard_pile.size() == 0:
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			draw_pile.shuffle()
		var card_id = draw_pile.pop_back()
		var card_data = CardDatabase.get_card(card_id)
		if card_data:
			hand.append(card_data)

func _render_hand_ui() -> void:
	for child in container_hand.get_children():
		child.queue_free()
	for card_data in hand:
		var card_ui = card_ui_scene.instantiate()
		container_hand.add_child(card_ui)
		card_ui.setup(card_data)
		card_ui.card_inspect_requested.connect(_show_card_zoom)

func _update_energy_ui() -> void:
	lbl_energy.text = "ENERGY: %d/%d" % [current_energy, max_energy]

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("card_data") and not enemy_entities.is_empty()

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.has("card_data") and not enemy_entities.is_empty():
		var target: BattleEntity = enemy_entities[target_enemy_index]
		_on_card_dropped(data["card_data"], target)

func _on_card_dropped(card_data: CardData, target_entity: BattleEntity) -> void:
	if is_executing:
		return
		
	if current_energy < card_data.cost:
		_log("Energy tidak cukup untuk kartu " + card_data.name)
		return
		
	var card_ui_to_remove = null
	for child in container_hand.get_children():
		if child.card_data == card_data:
			card_ui_to_remove = child
			break
			
	if not card_ui_to_remove:
		return
		
	current_energy -= card_data.cost
	_update_energy_ui()
	
	hand.erase(card_data)
	discard_pile.append(card_data.id)
	card_ui_to_remove.queue_free()
	
	_start_single_execution(card_data, target_entity)

func _start_single_execution(card: CardData, target_entity: BattleEntity) -> void:
	is_executing = true
	_log("Eksekusi [%s] pada [%s]" % [card.name, target_entity.entity_name])
	
	_execute_card_effect(card, target_entity)
	
	if target_entity and target_entity.current_hp <= 0:
		if not target_entity.is_player:
			GameManager.play_sfx("monster_scream", 5.0)
		_auto_select_alive_target()
		
	if _check_all_enemies_dead():
		_on_battle_victory()
		return
		
	await get_tree().create_timer(0.4).timeout
	is_executing = false
	
	if _tutorial_active and _tutorial_step == 1:
		_tutorial_step = 2
		_update_tutorial_step()

func _on_btn_execute_pressed() -> void:
	if is_executing:
		return
	
	# Discard remaining hand
	for card in hand:
		discard_pile.append(card.id)
	hand.clear()
	_render_hand_ui()
	
	_enemy_turn_phase()

func _execute_card_effect(card: CardData, target: BattleEntity) -> void:
	# Utility effects
	if card.draw_cards > 0:
		_draw_cards(card.draw_cards)
		_log("Rain Dance: Tarik %d kartu." % card.draw_cards)
	if card.discard_cards > 0 and hand.size() > 0:
		var discarded = hand.pop_back()
		discard_pile.append(discarded.id)
		_log("Rain Dance: Membuang kartu [%s]." % discarded.name)
		_render_hand_ui()
		
	if card.self_hp_cost > 0:
		player_entity.take_damage(card.self_hp_cost)
		_log("Blood Pact: Pengorbanan %d HP." % card.self_hp_cost)
	if card.energy_gain > 0:
		current_energy += card.energy_gain
		_update_energy_ui()
		_log("Blood Pact: Mendapatkan +%d Energy!" % card.energy_gain)

	if card.heal > 0:
		player_entity.heal(card.heal)
		_log("Medkit: Memulihkan %d HP." % card.heal)
		
	if card.block > 0:
		player_entity.add_block(card.block)
		_log("Memberikan %d Block pada Pemain." % card.block)

	# Target attacks & Primer/Igniter Reaksi Berantai
	if target and target.current_hp > 0:
		var final_damage = card.damage
		var is_combo_triggered = false
		
		# Igniter Synergy Check
		if card.type == CardData.CardType.IGNITER or card.type == CardData.CardType.ULTIMATE:
			if card.combo_req_status == CardData.StatusType.WET and target.is_wet:
				final_damage = card.combo_damage
				is_combo_triggered = true
				_log(">>> REAKSI BERANTAI [WET] TERPICU! <<<")
				if card.combo_applies_status == CardData.StatusType.STUN:
					target.apply_status_stun()
					_log("Target terkena efek [Stun]!")
				if card.combo_block > 0:
					player_entity.add_block(card.combo_block)
					_log("Pemain mendapatkan bonus +%d Block!" % card.combo_block)
					
			elif card.combo_req_status == CardData.StatusType.MUDDY and target.is_muddy:
				final_damage = card.combo_damage
				is_combo_triggered = true
				_log(">>> REAKSI BERANTAI [MUDDY] TERPICU! <<<")
				if card.combo_block > 0:
					player_entity.add_block(card.combo_block)
					_log("Pemain mendapatkan bonus +%d Block!" % card.combo_block)
		
		# Coin Flip logic for Ultimate
		if card.is_coin_flip:
			var success = randf() > 0.5 or (card.combo_req_status == CardData.StatusType.MUDDY and target.is_muddy)
			if not success:
				final_damage = card.coin_flip_fail_damage
				_log("Lempar Koin: GAGAL! Damage berkurang jadi %d." % final_damage)
			else:
				_log("Lempar Koin: SUKSES! Full Damage %d!" % final_damage)
				
		# Apply status from Primer
		if card.applies_status == CardData.StatusType.WET:
			target.apply_status_wet()
			_log("Target terkena efek [WET]!")
		elif card.applies_status == CardData.StatusType.MUDDY:
			target.apply_status_muddy()
			_log("Target terkena efek [MUDDY]!")
			
		if final_damage > 0:
			target.take_damage(final_damage)
			_log("Menyerang %s sebesar %d damage!" % [target.entity_name, final_damage])
			
	_update_player_hud()
	_update_boss_hud()

func _enemy_turn_phase() -> void:
	btn_execute.disabled = true
	_log("=== GILIRAN MUSUH DIMULAI ===")
	
	for i in range(enemy_entities.size()):
		var enemy = enemy_entities[i]
		if enemy.current_hp <= 0:
			continue
			
		if enemy.is_stunned:
			_log("%s terkena [Stun] dan tidak bisa bergerak!" % enemy.entity_name)
			enemy.tick_turn()
			continue
			
		enemy.reset_turn()
		
		# Intent: Attack or Block
		var action_roll = randf()
		if action_roll < 0.7:
			var dmg = randi_range(6, 12)
			player_entity.take_damage(dmg)
			_log("%s menyerang Pemain sebesar %d Damage!" % [enemy.entity_name, dmg])
		else:
			var blk = randi_range(4, 8)
			enemy.add_block(blk)
			_log("%s bertahan dan menambah %d Block!" % [enemy.entity_name, blk])
			
		_update_player_hud()
		_update_boss_hud()
		
		if player_entity.current_hp <= 0:
			_on_battle_defeat()
			return
			
		await get_tree().create_timer(0.6).timeout
		
	_start_player_turn()

func _auto_select_alive_target() -> void:
	for i in range(enemy_entities.size()):
		if enemy_entities[i].current_hp > 0:
			_select_target_enemy(i)
			return

func _check_all_enemies_dead() -> bool:
	for enemy in enemy_entities:
		if enemy.current_hp > 0:
			return false
	return true

func _on_battle_victory() -> void:
	_log("=== KEMENANGAN! Semua musuh tumbang ===")
	GameManager.player_current_hp = player_entity.current_hp
	
	# Unlock logic
	if GameManager.current_act == 1:
		if GameManager.current_level >= GameManager.act1_max_level_unlocked:
			GameManager.act1_max_level_unlocked = GameManager.current_level + 1
	elif GameManager.current_act == 2:
		if GameManager.current_level >= GameManager.act2_max_level_unlocked:
			GameManager.act2_max_level_unlocked = GameManager.current_level + 1
			
	SaveManager.save_game(StoryData.active_save_slot)
	
	lbl_win_loss_title.text = "VICTORY!\nKamu Menang!"
	reward_popup.show_reward()

func _on_reward_selected(card_id: String) -> void:
	GameManager.add_card_to_deck(card_id)
	SaveManager.save_game(StoryData.active_save_slot)
	win_loss_panel.visible = true

func _on_battle_defeat() -> void:
	GameManager.play_sfx("game_over", 5.0)
	_log("=== KEKALAHAN... Pemain Gugur ===")
	lbl_win_loss_title.text = "DEFEAT...\nKamu telah gugur"
	btn_continue.visible = false
	win_loss_panel.visible = true


func _on_btn_restart_pressed() -> void:
	GameManager.play_sfx("click", -5.0)
	GameManager.load_scene("res://scenes/battle/battle_scene.tscn")

func _on_btn_exit_pressed() -> void:
	GameManager.play_sfx("click", -5.0)
	GameManager.load_scene("res://scenes/level_select/level_select.tscn")

func _on_btn_continue_pressed() -> void:
	GameManager.play_sfx("click", -5.0)
	GameManager.load_scene("res://scenes/level_select/level_select.tscn")


func _setup_particles() -> void:
	# Dimmer: only darkens the background, NOT the monsters
	var dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0, 0, 0, 0.4)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dimmer.z_index = -100
	add_child(dimmer)

	# Shift monsters up
	if container_enemies:
		var arena = container_enemies.get_parent()
		if arena:
			arena.offset_top = -40

	# Fire particles (above monsters, below cards)
	var p = CPUParticles2D.new()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(640, 10)
	p.position = Vector2(640, -20)
	p.direction = Vector2(0, 1)
	p.spread = 20.0
	p.gravity = Vector2(0, 50)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 60.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 3.0
	p.color = Color(1.0, 0.5, 0.2, 0.6)
	p.z_index = 2
	
	if GameManager.current_level == 5:
		p.amount = 150
		p.color = Color(1.0, 0.3, 0.1, 0.8)
		p.gravity = Vector2(0, 80)
		p.scale_amount_max = 5.0
	else:
		p.amount = 40
		
	# Smoke particles (above monsters, below cards)
	var s = CPUParticles2D.new()
	s.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	s.emission_rect_extents = Vector2(640, 10)
	s.position = Vector2(640, -20)
	s.direction = Vector2(0, 1)
	s.gravity = Vector2(0, 30)
	s.initial_velocity_min = 10.0
	s.initial_velocity_max = 30.0
	s.scale_amount_min = 4.0
	s.scale_amount_max = 12.0
	s.color = Color(0.2, 0.2, 0.2, 0.3)
	s.z_index = 2
	if GameManager.current_level == 5:
		s.amount = 80
	else:
		s.amount = 20
		
	add_child(p)
	add_child(s)

func _setup_combat_log() -> void:
	if get_node_or_null("%LblBattleLog"): get_node("%LblBattleLog").visible = false
	
	combat_log_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.14, 0.85)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.6, 0.2, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	combat_log_panel.add_theme_stylebox_override("panel", style)
	
	combat_log_panel.custom_minimum_size = Vector2(250, 150)
	combat_log_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	combat_log_panel.position = Vector2(get_viewport_rect().size.x - 260, 10)
	combat_log_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	combat_log_panel.add_child(margin)
	
	combat_log_text = RichTextLabel.new()
	combat_log_text.scroll_following = true
	combat_log_text.bbcode_enabled = true
	combat_log_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font = preload("res://assets/card/PublicPixel.ttf")
	if font:
		combat_log_text.add_theme_font_override("normal_font", font)
		combat_log_text.add_theme_font_size_override("normal_font_size", 10)
	margin.add_child(combat_log_text)
	
	add_child(combat_log_panel)

func _log(msg: String) -> void:
	print(msg)
	if combat_log_text:
		combat_log_text.append_text(msg + "\n")


func _show_card_zoom(card_data: CardData) -> void:
	GameManager.play_sfx("inspect", -2.0)
	if not zoom_card_instance:
		zoom_card_instance = card_ui_scene.instantiate()
		zoom_card_holder.add_child(zoom_card_instance)
		zoom_card_instance.position = Vector2(-80, -120)
		zoom_card_instance.pivot_offset = Vector2(160, 240)
		zoom_card_instance.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed:
				_hide_card_zoom()
		)
		
	zoom_card_instance.setup(card_data)
	zoom_card_instance.make_zoomed()
	zoom_overlay.visible = true
	zoom_card_instance.modulate.a = 0.0
	zoom_card_instance.scale = Vector2(0.8, 0.8)
	zoom_card_instance.pivot_offset = Vector2(160, 240)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(zoom_card_instance, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(zoom_card_instance, "modulate:a", 1.0, 0.12)
	
	if _tutorial_active and _tutorial_step == 0 and _tutorial_visual:
		_tutorial_visual.visible = false

func _hide_card_zoom() -> void:
	if not zoom_overlay.visible:
		return
	if zoom_card_instance:
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(zoom_card_instance, "scale", Vector2(0.7, 0.7), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(zoom_card_instance, "modulate:a", 0.0, 0.1)
		tw.chain().tween_callback(func():
			zoom_overlay.visible = false
			if _tutorial_active and _tutorial_step == 0:
				_tutorial_step = 1
				_update_tutorial_step()
				if _tutorial_visual:
					_tutorial_visual.visible = true
		)
	else:
		zoom_overlay.visible = false
		if _tutorial_active and _tutorial_step == 0:
			_tutorial_step = 1
			_update_tutorial_step()
			if _tutorial_visual:
				_tutorial_visual.visible = true

func _on_zoom_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_hide_card_zoom()

func _unhandled_input(event: InputEvent) -> void:
	if zoom_overlay.visible and event is InputEventMouseButton and event.pressed:
		_hide_card_zoom()
		get_viewport().set_input_as_handled()
