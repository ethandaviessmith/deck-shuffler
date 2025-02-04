class_name Card extends Resource

enum CardType { ATTACK, SPELL, ACTION }
enum Rarity { COMMON }

@export var name: String
@export var texture: Texture2D
@export var card_type: CardType
@export var attack: AttackStats = AttackStats.new()
@export var spell: SpellStats = SpellStats.new()
@export var rarity: Rarity

static func get_card_type(card_type:CardType) -> String:
	match card_type:
		CardType.ATTACK:
			return "Attack"
		CardType.SPELL:
			return "Spell"
		CardType.ACTION:
			return "Action"
	return "Unknown"

func get_card_type_name() -> String:
	return get_card_type(self.card_type)

func get_rarity() -> String:
	return "COMMON"
