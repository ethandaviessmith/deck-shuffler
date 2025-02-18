class_name Card extends Resource

enum CardType { ATTACK, SPELL, ACTION, STAT }
enum ACTIONS { NA, QUICK_DRAW, DOUBLE_FINALE, MIRRAGE}
enum Rarity { COMMON }

@export var name: String
@export var description: String
@export var texture: Texture2D
@export var card_type: CardType
@export var attack: AttackStats = AttackStats.new()
@export var spell: SpellStats = SpellStats.new()
@export var action: ACTIONS = ACTIONS.NA
@export var rarity: Rarity

static func get_card_type(card_type:CardType) -> String:
	match card_type:
		CardType.ATTACK:
			return "Attack"
		CardType.SPELL:
			return "Spell"
		CardType.ACTION:
			return "Action"
		CardType.STAT:
			return "Stat"
	return "Unknown"

func is_card_type_stat() -> bool:
	return card_type == CardType.STAT

func get_card_type_name() -> String:
	return get_card_type(self.card_type)

func get_rarity() -> String:
	return "COMMON"
	
