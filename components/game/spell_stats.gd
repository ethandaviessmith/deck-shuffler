# SpellStats.gd
extends PlayerStats

class_name SpellStats

enum Trajectory { LINEAR, ARC, HOMING, RANDOM }
@export var trajectory: Trajectory = Trajectory.LINEAR
@export var drops: bool = false

@export var status_effect: StatusEffect.StautsType = StatusEffect.StautsType.NA ## Effect type
@export var status_duration: float = 0.0 ## How long it lasts
@export var status_proc: float = 0.0 ## How often it procs

## add onto spell
func add_spell(spell:SpellStats):
	add_buff(spell)
	# set until array
	trajectory = spell.trajectory 
	drops = spell.drops
	status_effect = spell.status_effect
	status_duration = spell.status_duration
	status_proc = status_proc
	
