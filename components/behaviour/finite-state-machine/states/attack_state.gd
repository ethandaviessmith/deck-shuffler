@icon("res://components/behaviour/finite-state-machine/state.png")
class_name AttackState extends CharacterState

func enter(previous_state_path: String, data := {}) -> void:
	if target == null:
		target = character.targets.pick_random() 
	target_offset =  Vector2.ZERO

func physics_update(_delta: float):
	move(_delta)

func update(_delta: float):
	if is_instance_valid(target):
		if character.global_position.distance_to(target.global_position) < DISTANCE_BESIDE:
			pass
		if character.global_position.distance_to(get_position()) > DISTANCE_CLOSE:
			await GameGlobals.wait(randf_range(0.0, 2.0))
			finished.emit(CHASE)
	else:
		finished.emit(IDLE)
