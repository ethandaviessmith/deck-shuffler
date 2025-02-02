class_name CardLoader extends Node

static func load_cards_from_csv(file_path: String) -> Array:
	var cards: Array[Card] = []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		# Skip the header line
		file.get_line()
		# Loop through each line in the CSV
		while not file.eof_reached():
			var line = file.get_line()
			if line == "":
				continue
			
			var fields = line.split(",")
			var card = Card.new()
			# Set card properties based on CSV data
			card.name = fields[0].strip_edges()
			card.texture_id = fields[1].strip_edges()
			match fields[2].strip_edges():
				"ATTACK": card.card_type = Card.CardType.ATTACK
				"SPELL": card.card_type = Card.CardType.SPELL
				"WEAPON": card.card_type = Card.CardType.WEAPON
			card.damage = fields[3].to_float()
			match fields[4].strip_edges():
				"AMOUNT": card.power_type = Card.PowerType.AMOUNT
				"STRENGTH": card.power_type = Card.PowerType.STRENGTH
				"NA": card.power_type = Card.PowerType.NA
			match fields[5].strip_edges():
				"DAGGER": card.weapon_type = Card.WeaponType.DAGGER
				"AXE": card.weapon_type = Card.WeaponType.AXE
				"SWORD": card.weapon_type = Card.WeaponType.SWORD
				"NA": card.weapon_type = Card.WeaponType.NA
			match fields[6].strip_edges():
				"COMMON": card.rarity = Card.Rarity.COMMON

			cards.append(card)
		
		file.close()
	else:
		print("Error opening file:", file_path)
	
	return cards

# Example usage
func _ready():
	var default_cards = load_cards_from_csv("res://cards.csv")
	for card in default_cards:
		print("Card:", card.texture_id, "Type:", card.get_card_type_name(), "Damage:", card.damage, "Power Type:", card.get_power_type_name())
