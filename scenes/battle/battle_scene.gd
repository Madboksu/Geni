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

func _ready() -> void:
	reward_popup.visible = false
	win_loss_panel.visible = false
	zoom_overlay.visible = false
	zoom_overlay.gui_input.connect(_on_zoom_overlay_gui_input)
	btn_execute.pressed.connect(_on_btn_execute_pressed)
	btn_continue.pressed.connect(_on_btn_continue_pressed)
	reward_popup.reward_selected.connect(_on_reward_selected)
	
	_setup_battle()

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
		enemy_entities.append(enemy)
		
		var enemy_ui = entity_ui_scene.instantiate()
		container_enemies.add_child(enemy_ui)
		var frames = cfg.get("sprite_frames", null)
		var tex = cfg.get("texture", null)
		enemy_ui.setup(enemy, tex, frames)
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
			1: # Level 1: 1 Tree Grunt mendominasi layar
				return [
					{"name": "Tree Grunt", "hp": 50, "sprite_frames": anim_tree_grunt}
				]
			2:
				return [
					{"name": "Pyro Scavenger", "hp": 30, "texture": avatar_wolf_tex},
					{"name": "Tree Grunt", "hp": 35, "sprite_frames": anim_tree_grunt}
				]
			3:
				return [
					{"name": "Flame Guard Golem", "hp": 45, "texture": avatar_golem_tex},
					{"name": "Tree Grunt", "hp": 30, "sprite_frames": anim_tree_grunt}
				]
			4: # Boss Fight Act 1
				return [
					{"name": "Ember Beast (BOSS)", "hp": 85, "texture": avatar_boss1_tex}
				]
	else:
		# Act 2
		match level:
			4: # Mid-Boss
				return [
					{"name": "Arson Commander", "hp": 90, "texture": avatar_golem_tex}
				]
			8: # Final Boss
				return [
					{"name": "Chief Executive Ignis", "hp": 140, "texture": avatar_boss2_tex}
				]
			_:
				return [
					{"name": "Corporate Sentry A", "hp": 30, "texture": avatar_golem_tex},
					{"name": "Corporate Sentry B", "hp": 30, "texture": avatar_golem_tex}
				]
	return [{"name": "Fire Elemental", "hp": 25, "texture": avatar_wolf_tex}]

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
		_auto_select_alive_target()
		
	if _check_all_enemies_dead():
		_on_battle_victory()
		return
		
	await get_tree().create_timer(0.4).timeout
	is_executing = false

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
			_log("Target basah [Wet]!")
		elif card.applies_status == CardData.StatusType.MUDDY:
			target.apply_status_muddy()
			_log("Target berlumpur [Muddy]!")
			
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
	_log("=== KEKALAHAN... Pemain Gugur ===")
	lbl_win_loss_title.text = "DEFEAT...\nKamu telah gugur"
	win_loss_panel.visible = true

func _on_btn_continue_pressed() -> void:
	if player_entity.current_hp > 0:
		GameManager.load_scene("res://scenes/level_select/level_select.tscn")
	else:
		GameManager.reset_run()
		GameManager.load_scene("res://scenes/level_select/level_select.tscn")

func _log(msg: String) -> void:
	lbl_battle_log.text = msg

func _show_card_zoom(card_data: CardData) -> void:
	if not zoom_card_instance:
		zoom_card_instance = card_ui_scene.instantiate()
		zoom_card_holder.add_child(zoom_card_instance)
		zoom_card_instance.position = Vector2.ZERO
		zoom_card_instance.pivot_offset = Vector2(80, 120)
		zoom_card_instance.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed:
				_hide_card_zoom()
		)
		
	zoom_card_instance.setup(card_data)
	zoom_overlay.visible = true
	zoom_card_instance.scale = Vector2(1.0, 1.0)
	zoom_card_instance.modulate.a = 0.0
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(zoom_card_instance, "scale", Vector2(2.1, 2.1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(zoom_card_instance, "modulate:a", 1.0, 0.12)

func _hide_card_zoom() -> void:
	if not zoom_overlay.visible:
		return
	if zoom_card_instance:
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(zoom_card_instance, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(zoom_card_instance, "modulate:a", 0.0, 0.1)
		tw.chain().tween_callback(func():
			zoom_overlay.visible = false
		)
	else:
		zoom_overlay.visible = false

func _on_zoom_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_hide_card_zoom()

func _unhandled_input(event: InputEvent) -> void:
	if zoom_overlay.visible and event is InputEventMouseButton and event.pressed:
		_hide_card_zoom()
		get_viewport().set_input_as_handled()
