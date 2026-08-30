extends Node

var cards: Dictionary = {}

func _ready() -> void:
	_init_database()

func _init_database() -> void:
	# 1. Dewblade
	var dewblade = CardData.new()
	dewblade.id = "dewblade"
	dewblade.name = "Dewblade"
	dewblade.type = CardData.CardType.ATTACK
	dewblade.cost = 1
	dewblade.damage = 5
	dewblade.description = "Memberikan 5 Damage."
	dewblade.texture_path = "res://assets/card/Dewblade.png"
	cards["dewblade"] = dewblade

	# 2. Root Shield
	var root_shield = CardData.new()
	root_shield.id = "root_shield"
	root_shield.name = "Root Shield"
	root_shield.type = CardData.CardType.DEFENSE
	root_shield.cost = 1
	root_shield.block = 5
	root_shield.description = "Memberikan 5 Block."
	root_shield.texture_path = "res://assets/card/Root shield card.png"
	cards["root_shield"] = root_shield

	# 3. Douse (Primer)
	var douse = CardData.new()
	douse.id = "douse"
	douse.name = "Douse"
	douse.type = CardData.CardType.PRIMER
	douse.cost = 1
	douse.damage = 2
	douse.applies_status = CardData.StatusType.WET
	douse.description = "Memberikan 2 Damage. Meninggalkan status [Wet]."
	cards["douse"] = douse

	# 4. Cooling Mud (Primer)
	var cooling_mud = CardData.new()
	cooling_mud.id = "cooling_mud"
	cooling_mud.name = "Cooling Mud"
	cooling_mud.type = CardData.CardType.PRIMER
	cooling_mud.cost = 1
	cooling_mud.block = 8
	cooling_mud.applies_status = CardData.StatusType.MUDDY
	cooling_mud.description = "Memberikan 8 Block. Meninggalkan status [Muddy]."
	cards["cooling_mud"] = cooling_mud

	# 5. Gale Wind (Igniter)
	var gale_wind = CardData.new()
	gale_wind.id = "gale_wind"
	gale_wind.name = "Gale Wind"
	gale_wind.type = CardData.CardType.IGNITER
	gale_wind.cost = 2
	gale_wind.damage = 8
	gale_wind.combo_req_status = CardData.StatusType.WET
	gale_wind.combo_damage = 20
	gale_wind.combo_applies_status = CardData.StatusType.STUN
	gale_wind.description = "8 Damage. Jika target [Wet]: 20 Damage + [Stun]."
	gale_wind.texture_path = "res://assets/card/Gale wind card.png"
	cards["gale_wind"] = gale_wind

	# 6. Thunder Strike (Igniter)
	var thunder_strike = CardData.new()
	thunder_strike.id = "thunder_strike"
	thunder_strike.name = "Thunder Strike"
	thunder_strike.type = CardData.CardType.IGNITER
	thunder_strike.cost = 2
	thunder_strike.damage = 10
	thunder_strike.combo_req_status = CardData.StatusType.MUDDY
	thunder_strike.combo_damage = 25
	thunder_strike.description = "10 Damage. Jika target [Muddy]: 25 Damage."
	cards["thunder_strike"] = thunder_strike

	# 7. Whirlwind (Igniter)
	var whirlwind = CardData.new()
	whirlwind.id = "whirlwind"
	whirlwind.name = "Whirlwind"
	whirlwind.type = CardData.CardType.IGNITER
	whirlwind.cost = 3
	whirlwind.damage = 12
	whirlwind.combo_req_status = CardData.StatusType.WET
	whirlwind.combo_damage = 30
	whirlwind.combo_block = 10
	whirlwind.description = "12 Damage. Jika target [Wet]: 30 Damage + 10 Block."
	cards["whirlwind"] = whirlwind

	# 8. Rain Dance (Utility)
	var rain_dance = CardData.new()
	rain_dance.id = "rain_dance"
	rain_dance.name = "Rain Dance"
	rain_dance.type = CardData.CardType.UTILITY
	rain_dance.cost = 0
	rain_dance.draw_cards = 2
	rain_dance.discard_cards = 1
	rain_dance.description = "Tarik 2 kartu, lalu buang 1 kartu dari tangan."
	cards["rain_dance"] = rain_dance

	# 9. Blood Pact (Utility Consumable)
	var blood_pact = CardData.new()
	blood_pact.id = "blood_pact"
	blood_pact.name = "Blood Pact"
	blood_pact.type = CardData.CardType.UTILITY
	blood_pact.cost = 0
	blood_pact.self_hp_cost = 3
	blood_pact.energy_gain = 2
	blood_pact.is_consumable = true
	blood_pact.description = "Korbankan 3 HP untuk dapat 2 Energy. Kartu hancur setelah dipakai."
	cards["blood_pact"] = blood_pact

	# 10. Drought's End (Ultimate)
	var droughts_end = CardData.new()
	droughts_end.id = "droughts_end"
	droughts_end.name = "Drought's End"
	droughts_end.type = CardData.CardType.ULTIMATE
	droughts_end.cost = 3
	droughts_end.damage = 45
	droughts_end.is_coin_flip = true
	droughts_end.coin_flip_fail_damage = 15
	droughts_end.combo_req_status = CardData.StatusType.MUDDY
	droughts_end.description = "Lempar Koin: Berhasil = 45 Damage, Gagal = 15 Damage. (Pasti Berhasil jika target [Muddy])."
	cards["droughts_end"] = droughts_end

	# 11. Broken Axe (Item Consumable)
	var broken_axe = CardData.new()
	broken_axe.id = "broken_axe"
	broken_axe.name = "Broken Axe"
	broken_axe.type = CardData.CardType.ITEM
	broken_axe.cost = 0
	broken_axe.damage = 15
	broken_axe.is_consumable = true
	broken_axe.description = "Memberikan 15 Damage. Kartu hancur setelah dipakai."
	cards["broken_axe"] = broken_axe

	# 12. Medkit (Item Consumable)
	var medkit = CardData.new()
	medkit.id = "medkit"
	medkit.name = "Medkit"
	medkit.type = CardData.CardType.ITEM
	medkit.cost = 0
	medkit.heal = 10
	medkit.is_consumable = true
	medkit.description = "Memulihkan 10 HP Pemain. Kartu hancur setelah dipakai."
	cards["medkit"] = medkit

func get_card(id: String) -> CardData:
	if cards.has(id):
		return cards[id]
	return null
