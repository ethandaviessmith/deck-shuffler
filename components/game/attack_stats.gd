# AttackStats.gd
extends BaseStats

class_name AttackStats

enum WeaponType { DAGGER, SWORD, AXE, BOW, ROCK, SCARECROW, NA }
@export var weapon_type: WeaponType = WeaponType.NA
@export var fade: float = 3.0
# multiplier
@export var knockback: float = 1.0

func add_attack(attack: AttackStats):
	add_buff(attack)
	weapon_type = attack.weapon_type
	fade = attack.fade
	knockback = attack.knockback


func add_player_buff(buff: PlayerStats):
	add_buff(buff as BaseStats)

static func get_weapon_type(weapon_type:WeaponType) -> String:
	match weapon_type:
		WeaponType.DAGGER:
			return "Dagger"
		WeaponType.AXE:
			return "Axe"
		WeaponType.SWORD:
			return "Sword"
	return "NA"

func get_weapon_type_name() -> String:
	return AttackStats.get_weapon_type(self.weapon_type)
