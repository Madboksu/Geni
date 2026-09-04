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
	douse.texture_path = "res://assets/card/douse.png"
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
	cooling_mud.texture_path = "res://assets/card/cooling_mud.png"
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
	thunder_strike.texture_path = "res://assets/card/thunder_strike-export.png"
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
	whirlwind.texture_path = "res://assets/card/whirlwind.png"
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
	rain_dance.texture_path = "res://assets/card/rain_dance.png"
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
	blood_pact.texture_path = "res://assets/card/blood_pack.png"
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
	droughts_end.description = "Koin: Sukses 45 Dmg, Gagal 15 Dmg. (Pasti Sukses jika [Muddy])."
	droughts_end.texture_path = "res://assets/card/dourght_end.png"
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
	broken_axe.texture_path = "res://assets/card/broken_axe.png"
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
	medkit.texture_path = "res://assets/card/Medkit.png"
	cards["medkit"] = medkit

	# 13. Bucket of Mud (Primer)
	var bucket_of_mud = CardData.new()
	bucket_of_mud.id = "bucket_of_mud"
	bucket_of_mud.name = "Bucket of Mud"
	bucket_of_mud.type = CardData.CardType.PRIMER
	bucket_of_mud.cost = 1
	bucket_of_mud.block = 5
	bucket_of_mud.applies_status = CardData.StatusType.MUDDY
	bucket_of_mud.description = "Memberikan 5 Block. Meninggalkan status [Muddy]."
	bucket_of_mud.texture_path = "res://assets/card/Bucket_of_mud.png"
	cards["bucket_of_mud"] = bucket_of_mud

	# 14. Static Jar (Primer)
	var static_jar = CardData.new()
	static_jar.id = "static_jar"
	static_jar.name = "Static Jar"
	static_jar.type = CardData.CardType.PRIMER
	static_jar.cost = 1
	static_jar.damage = 4
	static_jar.description = "Memberikan 4 Damage listrik."
	static_jar.texture_path = "res://assets/card/static_jar.png"
	cards["static_jar"] = static_jar

func get_card(id: String) -> CardData:
	if cards.has(id):
		return cards[id]
	return null

func get_all_cards() -> Array:
	return cards.values()
