# PlayerStats.gd
extends BaseStats

class_name CharacterStats

@export var armor: int = 0
@export var time: float = 6.0
@export var attacks_per_second: float = 1.0


func add_player_stats(stats):
	add_buff(stats)
	if stats is CharacterStats:
		self.armor += stats.armor
		self.time += stats.time
		
		self.attacks_per_second *= stats.attacks_per_second
