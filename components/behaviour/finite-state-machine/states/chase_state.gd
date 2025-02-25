@icon("res://components/behaviour/finite-state-machine/state.png")
class_name ChaseState extends CharacterState

const CHASE_DISTANCE = 80

func enter(previous_state_path: String, data := {}) -> void:
	if target == null:
		target = character.targets.pick_random() 


func physics_update(_delta: float):
	pass


func update(_delta: float):
	if is_instance_valid(target):
		Log.pr("chase", target)
		character.move_towards_target(_delta, target.position)
		if character.position.distance_to(target.position) < 10:
			finished.emit(IDLE)
	else:
		finished.emit(IDLE)
