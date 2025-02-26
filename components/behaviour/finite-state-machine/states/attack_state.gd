@icon("res://components/behaviour/finite-state-machine/state.png")
class_name AttackState extends CharacterState

@export var ATTACK_RADIUS = 30
@export var CHASE_RADIUS = 15

func enter(previous_state_path: String, data := {}) -> void:
	if target == null:
		target = character.targets.pick_random() 
	target_offset =  Vector2.ZERO

func physics_update(_delta: float):
	pass

func update(_delta: float):
	move(_delta)
	if is_instance_valid(target):
		if character.global_position.distance_to(target.global_position) < ATTACK_RADIUS:
			finished.emit(IDLE)
		if character.global_position.distance_to(get_position()) > CHASE_RADIUS:
			await GameGlobals.wait(randf_range(0.0, 2.0))
			finished.emit(CHASE)
	else:
		finished.emit(IDLE)
