@icon("res://components/behaviour/finite-state-machine/state.png")
class_name CharacterMachineState extends MachineState

var origin_position: Vector2
var target_position: Vector2


@export var speed: float = 300.0
@export var acceleration: float = 25.0
@export var friction: float = 50.0



func move(delta: float) -> void:
	if target_position == Vector2.ZERO:
		decelerate(delta)
	else:
		accelerate(delta)
		
	FSM.character.move_and_slide()

func dir_to_target():
	if target_position == Vector2.ZERO:
		return Vector2.ZERO
	return FSM.character.global_position.direction_to(target_position).normalized()

func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	if acceleration > 0:
		FSM.character.velocity = FSM.character.velocity.lerp(dir_to_target() * speed, acceleration * delta)
	else:
		FSM.character.velocity =  dir_to_target() * speed

func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if friction > 0:
		FSM.character.velocity = FSM.character.velocity.lerp(Vector2.ZERO, friction * delta)
	else:
		FSM.character.velocity = Vector2.ZERO
