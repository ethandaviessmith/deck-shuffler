# BaseStats.gd
extends Resource

class_name BaseStats

@export var guid: String = "res_" + str(UUID.new())

# Default addition
@export var damage: float = 0.0
@export var durability: float = 0.0

# Default Multiplier
@export var speed: float = 1.0
@export var size: float = 1.0
@export var CHARGE_LIMIT: int = 1  ## How many uses before it's gone
var charges = 0

var icon_scene: WeaponIcon


## returns remaining charges
func charge_limit(increase: int) -> int:
	charges += increase
	return clampi(CHARGE_LIMIT - charges, 0, CHARGE_LIMIT)


## Add onto buff
func add_buff(buff: BaseStats):
	damage += buff.damage
	durability += buff.durability
	speed *= buff.speed
	size *= buff.size

func print_buff() -> String:
	var stats = ">d:" + format_value(damage) + ",h:" + format_value(durability) +",s:" + format_value(speed) +",si:" + format_value(size)
	return stats

func format_value(value: float) -> String:
	# Convert to integer if there's no decimal part
	if value == int(value):
		return str(int(value))
	return str(value)
