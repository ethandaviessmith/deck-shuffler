@icon("res://components/behaviour/finite-state-machine/state.png")
class_name OrbitState extends CharacterState

@export var DURATION = Vector2(0.0,2.0)
const OFFSET = 50
var orbit_speed: float = 90.0
var current_angle: float = 0.0
var desired_distance: float = 0.0
var adjustment_speed: float = 2.0

func enter(previous_state_path: String, data := {}) -> void:
	if target == null:
		finished.emit(IDLE)
	else:
		desired_distance = character.global_position.distance_to(get_position())
		await get_tree().create_timer(randf_range(DURATION.x, DURATION.y), true, false, true).timeout
		finished.emit(IDLE)

func exit() -> void:
	pass

func physics_update(delta: float):
	pass


func update(delta: float):
	
	if is_instance_valid(target):
		update_circle_movement(delta)
		if character.global_position.distance_to(get_position()) < DISTANCE_CLOSE:
			pass
			#finished.emit(ATTACK)
	else:
		finished.emit(IDLE)

func update_circle_movement(delta):
	# Get current distance to target
	var current_position = character.global_position
	var target_position = target.global_position
	var current_distance = current_position.distance_to(target_position)
	
	# Update the orbit angle
	current_angle += orbit_speed * delta
	
	# Calculate the new position based on the orbit angle
	var direction = Vector2(cos(deg_to_rad(current_angle)), sin(deg_to_rad(current_angle)))
	var ideal_position = target_position + direction * desired_distance
	move_position(ideal_position, delta)
