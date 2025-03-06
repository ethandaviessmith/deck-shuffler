# PlayerStats.gd
extends BaseStats

class_name PlayerStats

@export var armor: int = 0
@export var time: float = 6.0


@export var draw_speed: float = 1.0
@export var shuffle_speed: float = 1.0
@export var attacks_per_second: float = 1.0

# for applying buffs from resolving hands
@export var attacks: Array[AttackStats] = []
@export var spells: Array[SpellStats] = []


func add_player_stats(stats):
	add_buff(stats)
	if stats is PlayerStats:
		self.armor += stats.armor
		self.time += stats.time
		
		self.draw_speed *= stats.draw_speed
		self.shuffle_speed *= stats.shuffle_speed
		self.attacks_per_second *= stats.attacks_per_second

func format_stats() -> String:
	var stats = ">h:" + format_value(durability) + ",s:" + format_value(speed) +",d:" + format_value(damage) +",a:" + format_value(attacks_per_second)
	return stats

func format_value(value: float) -> String:
	# Convert to integer if there's no decimal part
	if value == int(value):
		return str(int(value))
	return str(value)
