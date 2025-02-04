# SpellStats.gd
extends PlayerStats

class_name SpellStats

enum Trajectory { LINEAR, ARC, HOMING, RANDOM }
@export var trajectory: Trajectory = Trajectory.LINEAR
@export var drops: bool = false
