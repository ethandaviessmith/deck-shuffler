@icon("res://components/behaviour/finite-state-machine/state.png")
class_name RepositionState extends CharacterState

@export var RADIUS = 200

func enter(previous_state_path: String, data := {}) -> void:
	if not data.get("target") == null:
		target = data.get("target")
	else:
		if target == null:
			if _is_target_valid(character):
				target = character.targets.pick_random()
	if not target == null:
		target = get_random_position_away_from_target(target, RADIUS)

func exit() -> void:
	pass

func get_random_position_away_from_target(target: Node2D, radius: float) -> Node2D:
	var direction_to_target = (target.global_position - character.global_position).normalized()
	var normal_direction = Vector2(-direction_to_target.y, direction_to_target.x)
	var random_angle = randf() * PI - (PI / 2)  # [-PI/2, PI/2] range for semi-circle
	var rotated_vector = normal_direction.rotated(random_angle)

	var node = Node2D.new()
	node.position =  character.global_position + rotated_vector * radius
	return node
	
	
func physics_update(delta: float):
	move(delta)

func update(delta: float):
	if is_instance_valid(target):
		if character.global_position.distance_to(get_position()) < DISTANCE_CLOSE:
			finished.emit(IDLE)
	else:
		finished.emit(IDLE)
