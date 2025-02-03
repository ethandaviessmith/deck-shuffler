# StatsWeapon.gd
class_name StatsWeapon extends Resource

@export var damage: float = 10.0
@export var size: float = 1.0
@export var speed: float = 100.0
@export var amount: int = 1
@export var knockback: float = 50.0
@export var type: Card.WeaponType = Card.WeaponType.DAGGER  # Default type

static func create_weapon(damage: float, size: float, speed: float, amount: int, knockback: float, type: Card.WeaponType) -> StatsWeapon:
	var stats_weapon = StatsWeapon.new()
	stats_weapon.set("damage", damage)
	stats_weapon.set("size", size)
	stats_weapon.set("speed", speed)
	stats_weapon.set("amount", amount)
	stats_weapon.set("knockback", knockback)
	stats_weapon.set("type", type)
	return stats_weapon

static func create_new_weapon(weapon_type:Card.WeaponType) -> StatsWeapon:
	match weapon_type:
		Card.WeaponType.DAGGER:
			return create_weapon(1, 0.5, 100, 1, 50, Card.WeaponType.DAGGER)
		Card.WeaponType.AXE:
			return create_weapon(1, 2, 50, 1, 70, Card.WeaponType.AXE)
		Card.WeaponType.SWORD:
			return create_weapon(2, 1, 80, 1, 80, Card.WeaponType.SWORD)
	return create_weapon(1, 1, 100, 1, 50, Card.WeaponType.DAGGER)
