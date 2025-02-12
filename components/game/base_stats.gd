# BaseStats.gd
extends Resource

class_name BaseStats

# Default addition
@export var damage: float = 0.0
@export var durability: float = 0.0

# Default Multiplier
@export var speed: float = 1.0
@export var size: float = 1.0


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
