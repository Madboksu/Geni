extends Control

# Scenes & UI References
@onready var container_enemies: HBoxContainer = %ContainerEnemies
@onready var container_player: CenterContainer = %ContainerPlayer
@onready var container_hand: HBoxContainer = %ContainerHand
@onready var container_queue: HBoxContainer = %ContainerQueue
@onready var btn_execute: Button = %BtnExecute
@onready var lbl_energy: Label = %LblEnergy
@onready var lbl_battle_log: Label = %LblBattleLog
@onready var reward_popup: Control = %RewardPopup
@onready var win_loss_panel: PanelContainer = %WinLossPanel
@onready var lbl_win_loss_title: Label = %LblWinLossTitle
@onready var btn_continue: Button = %BtnContinue

# Preloads
var card_ui_scene = preload("res://scenes/battle/components/card_ui.tscn")
var queue_slot_ui_scene = preload("res://scenes/battle/components/queue_slot_ui.tscn")
var entity_ui_scene = preload("res://scenes/battle/components/entity_ui.tscn")

# Preloaded SVG textures
var avatar_player_tex = preload("res://assets/placeholders/player_avatar.svg")
var avatar_wolf_tex = preload("res://assets/placeholders/monster_wolf.svg")
var avatar_golem_tex = preload("res://assets/placeholders/monster_golem.svg")
var avatar_boss1_tex = preload("res://assets/placeholders/monster_boss1.svg")
var avatar_boss2_tex = preload("res://assets/placeholders/monster_boss2.svg")

# Battle Data State
var player_entity: BattleEntity
var enemy_entities: Array = []
var enemy_ui_nodes: Array = []
var player_ui_node: Control

var current_energy: int = 3
var max_energy: int = 3

var draw_pile: Array = []
var hand: Array = [] # CardData objects
var discard_pile: Array = []
var queued_cards: Array = [] # CardData objects queued in slots

var target_enemy_index: int = 0
var is_executing: bool = false

func _ready() -> void:
	reward_popup.visible = false
	win_loss_panel.visible = false
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
	
	for child in container_player.get_children():
		child.queue_free()
	player_ui_node = entity_ui_scene.instantiate()
	container_player.add_child(player_ui_node)
	player_ui_node.setup(player_entity, avatar_player_tex)
	
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
		enemy_ui.setup(enemy, cfg["texture"])
		var enemy_idx = i
		enemy_ui.entity_selected.connect(func(_ui): _select_target_enemy(enemy_idx))
		enemy_ui_nodes.append(enemy_ui)
		
	if enemy_ui_nodes.size() > 0:
		_select_target_enemy(0)
		
	# 3. Setup Deck & Draw Pile
	draw_pile = GameManager.player_deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
	
	# 4. Setup Queue UI Slots (3 slots)
	for child in container_queue.get_children():
		child.queue_free()
	for i in range(3):
		var slot = queue_slot_ui_scene.instantiate()
		container_queue.add_child(slot)
		slot.setup(i)
		slot.slot_clicked.connect(_on_queue_slot_clicked)
		
	_start_player_turn()

func _get_level_enemy_config(act: int, level: int) -> Array:
	if act == 1:
		match level:
			1: # Tutorial 3 monsters
				return [
					{"name": "Ember Prowler A", "hp": 18, "texture": avatar_wolf_tex},
					{"name": "Ember Prowler B", "hp": 18, "texture": avatar_wolf_tex},
					{"name": "Ember Prowler C", "hp": 18, "texture": avatar_wolf_tex}
				]
			2:
				return [
					{"name": "Pyro Scavenger A", "hp": 25, "texture": avatar_wolf_tex},
					{"name": "Pyro Scavenger B", "hp": 25, "texture": avatar_wolf_tex}
				]
			3:
				return [
					{"name": "Flame Guard Golem", "hp": 40, "texture": avatar_golem_tex},
					{"name": "Ember Prowler", "hp": 20, "texture": avatar_wolf_tex}
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

func _start_player_turn() -> void:
	is_executing = false
	current_energy = max_energy
	_update_energy_ui()
	player_entity.reset_turn()
	queued_cards.clear()
	_update_queue_ui()
	
	# Draw 5 cards
	_draw_cards(5)
	_render_hand_ui()
	btn_execute.disabled = false
	_log("Fase Perencanaan: Pilih kartu untuk dimasukkan ke antrean slot.")

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
		card_ui.card_clicked.connect(_on_hand_card_clicked)

func _update_energy_ui() -> void:
	var total_queued_cost = 0
	for c in queued_cards:
		total_queued_cost += c.cost
	var remaining = current_energy - total_queued_cost
	lbl_energy.text = "Energy: %d / %d" % [remaining, max_energy]

func _on_hand_card_clicked(card_ui) -> void:
	if is_executing or not card_ui or not card_ui.card_data:
		return
	var card = card_ui.card_data
	
	# Calculate remaining energy
	var used_energy = 0
	for c in queued_cards:
		used_energy += c.cost
	
	if used_energy + card.cost > current_energy:
		_log("Energy tidak cukup untuk kartu " + card.name)
		return
		
	if queued_cards.size() >= 3:
		_log("Slot antrean sudah penuh (Maksimal 3 kartu).")
		return
		
	# Move card from hand to queued_cards
	hand.erase(card)
	queued_cards.append(card)
	_render_hand_ui()
	_update_queue_ui()
	_update_energy_ui()

func _on_queue_slot_clicked(slot_index: int) -> void:
	if is_executing or slot_index < 0 or slot_index >= queued_cards.size():
		return
	# Remove card from queue back to hand
	var card = queued_cards[slot_index]
	queued_cards.remove_at(slot_index)
	hand.append(card)
	_render_hand_ui()
	_update_queue_ui()
	_update_energy_ui()

func _update_queue_ui() -> void:
	var slots = container_queue.get_children()
	for i in range(slots.size()):
		if i < queued_cards.size():
			slots[i].set_queued_card(queued_cards[i])
		else:
			slots[i].clear_slot()

func _on_btn_execute_pressed() -> void:
	if is_executing or queued_cards.size() == 0:
		_log("Pilih minimal 1 kartu sebelum menekan tombol Padamkan!")
		return
	_start_execution_phase()

func _start_execution_phase() -> void:
	is_executing = true
	btn_execute.disabled = true
	_log("=== FASE EKSEKUSI PADAMKAN! ===")
	
	var target_enemy = enemy_entities[target_enemy_index] if target_enemy_index < enemy_entities.size() else null
	
	for i in range(queued_cards.size()):
		var card = queued_cards[i]
		_log("Eksekusi Slot %d: Kartu [%s]" % [i + 1, card.name])
		await get_tree().create_timer(0.6).timeout
		
		_execute_card_effect(card, target_enemy)
		
		# Check if target died -> switch to next alive target
		if target_enemy and target_enemy.current_hp <= 0:
			_auto_select_alive_target()
			target_enemy = enemy_entities[target_enemy_index] if target_enemy_index < enemy_entities.size() else null
			
		if _check_all_enemies_dead():
			_on_battle_victory()
			return
			
	queued_cards.clear()
	_update_queue_ui()
	
	# Discard remaining hand
	for card in hand:
		discard_pile.append(card.id)
	hand.clear()
	_render_hand_ui()
	
	await get_tree().create_timer(0.8).timeout
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
		_log("Blood Pact: Pengorbanan 3 HP.")
	if card.energy_gain > 0:
		current_energy += card.energy_gain
		_update_energy_ui()
		_log("Blood Pact: Mendapatkan +2 Energy!")

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
					_log("Pemain mendapatkan bonus +10 Block!")
					
			elif card.combo_req_status == CardData.StatusType.MUDDY and target.is_muddy:
				final_damage = card.combo_damage
				is_combo_triggered = true
				_log(">>> REAKSI BERANTAI [MUDDY] TERPICU! <<<")
				
		# Drought's End Coin Flip Logic
		if card.is_coin_flip:
			if target.is_muddy:
				final_damage = 45
				_log("Drought's End: Target [Muddy], Pasti Berhasil 45 Damage!")
			else:
				var success = (randi() % 2 == 0)
				if success:
					final_damage = 45
					_log("Drought's End: Lempar Koin BERHASIL! (45 Damage)")
				else:
					final_damage = card.coin_flip_fail_damage
					_log("Drought's End: Lempar Koin Gagal (15 Damage).")

		if final_damage > 0:
			var dealt = target.take_damage(final_damage)
			_log("%s memberikan %d damage pada %s." % [card.name, dealt, target.entity_name])

		# Apply Primer status
		if card.applies_status == CardData.StatusType.WET:
			target.apply_status_wet()
			_log("Target menampung status [Wet]. Siap dipicu oleh kartu Igniter!")
		elif card.applies_status == CardData.StatusType.MUDDY:
			target.apply_status_muddy()
			_log("Target menampung status [Muddy]. Siap dipicu oleh kartu Igniter!")

	# Consumable Item Handling (Hancur / removed from active deck)
	if card.is_consumable:
		_log("Kartu [%s] hancur (dihapus dari deck) setelah digunakan." % card.name)
		GameManager.player_deck.erase(card.id)

func _enemy_turn_phase() -> void:
	_log("=== GILIRAN MUSUH ===")
	for enemy in enemy_entities:
		if enemy.current_hp <= 0:
			continue
		if enemy.is_stunned:
			_log("%s terkena [Stun] dan tidak dapat bergerak giliran ini!" % enemy.entity_name)
			enemy.is_stunned = false
			enemy.status_changed.emit()
			continue
			
		enemy.reset_turn()
		var dmg = randi_range(6, 12)
		var dealt = player_entity.take_damage(dmg)
		_log("%s menyerang Pemain sebesar %d damage." % [enemy.entity_name, dealt])
		await get_tree().create_timer(0.5).timeout
		
		if player_entity.current_hp <= 0:
			_on_battle_defeat()
			return
			
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
	_log("=== KEMENANGAN! SELURUH MUSUH DIKALAHKAN! ===")
	GameManager.player_current_hp = player_entity.current_hp
	GameManager.unlock_next_level()
	
	await get_tree().create_timer(0.6).timeout
	# Show Reward Popup with 3 random card options
	var reward_options = [
		CardDatabase.get_card("gale_wind"),
		CardDatabase.get_card("thunder_strike"),
		CardDatabase.get_card("droughts_end")
	]
	reward_popup.setup(reward_options)
	reward_popup.visible = true

func _on_reward_selected(card_id: String) -> void:
	GameManager.add_card_to_deck(card_id)
	reward_popup.visible = false
	
	lbl_win_loss_title.text = "VICTORY!\nLevel %d Selesai" % GameManager.current_level
	win_loss_panel.visible = true

func _on_battle_defeat() -> void:
	_log("=== KEKALAHAN... Pemain Gugur ===")
	lbl_win_loss_title.text = "DEFEAT...\nKamu telah gugur"
	win_loss_panel.visible = true

func _on_btn_continue_pressed() -> void:
	if player_entity.current_hp > 0:
		GameManager.load_scene("res://scenes/level_select/level_select.tscn")
	else:
		GameManager.reset_to_act1_starter_deck()
		GameManager.load_scene("res://scenes/level_select/level_select.tscn")

func _log(msg: String) -> void:
	lbl_battle_log.text = msg
