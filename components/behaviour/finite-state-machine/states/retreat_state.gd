@icon("res://components/behaviour/finite-state-machine/state.png")
class_name RetreatState extends CharacterState


func enter(previous_state_path: String, data := {}) -> void:
	target = character.get_retreat()

func exit() -> void:
	pass

func physics_update(delta: float):
	move(delta)

func update(delta: float):
	if is_instance_valid(target):
		if character.global_position.distance_to(get_position()) < DISTANCE_CLOSE:
			finished.emit(REST)
	else:
		finished.emit(IDLE)

func new_target(node: Node2D):
	target = node
