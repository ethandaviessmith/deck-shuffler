class_name Card extends Resource

enum CardType { ATTACK, SPELL, WEAPON }
enum PowerType { AMOUNT, STRENGTH, NA }
enum Rarity { COMMON }
enum WeaponType {DAGGER, AXE, SWORD, NA}


@export var name: String
@export var hp: float # durability
@export var texture_id: String
@export var card_type: CardType
@export var weapon_type: WeaponType
@export var power_type: PowerType
@export var rarity: Rarity

@export var damage: float # amount

static func get_card_type(card_type:CardType) -> String:
	match card_type:
		CardType.ATTACK:
			return "Attack"
		CardType.SPELL:
			return "Spell"
		CardType.WEAPON:
			return "Weapon"
	return "Unknown"

func get_card_type_name() -> String:
	return get_card_type(self.card_type)
	
func get_power_type(power_type:PowerType) -> String:
	match power_type:
		PowerType.AMOUNT:
			return "Amount"
		PowerType.STRENGTH:
			return "Strength"
		PowerType.NA:
			return "NA"
	return "Unknown"

func get_power_type_name() -> String:
	return get_power_type(self.power_type)

func get_weapon_type(weapon_type:WeaponType) -> String:
	match weapon_type:
		WeaponType.DAGGER:
			return "Dagger"
		WeaponType.AXE:
			return "Axe"
		WeaponType.SWORD:
			return "Sword"
	return "NA"

func get_weapon_type_name() -> String:
	return get_weapon_type(self.weapon_type)

func get_rarity() -> String:
	return "COMMON"
