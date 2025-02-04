# AttackStats.gd
extends BaseStats

class_name AttackStats

enum WeaponType { DAGGER, SWORD, AXE, BOW, ROCK, NA }
@export var weapon_type: WeaponType = WeaponType.NA
@export var fade: float = 3.0
# multiplier
@export var knockback: float = 1.0

func add_player_buff(buff: PlayerStats):
	add_buff(buff as BaseStats)

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
