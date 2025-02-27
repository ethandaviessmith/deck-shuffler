@icon("res://components/behaviour/finite-state-machine/state.png")
class_name RoamState extends CharacterState

@export var IDLE_DURATION = 2.0
var idle_time = 0.0

var roam_points: Array[Node2D] = []
const ROAM_RADIUS = 80


func enter(previous_state_path: String, data := {}) -> void:
	if roam_points.is_empty():
		_setup_roam_points()
	target = _pick_new_roam_target()

func physics_update(_delta: float):
	move(_delta)

func update(_delta: float):
	if character.position.distance_to(target.position) < DISTANCE_BESIDE:
		finished.emit(IDLE)

	if character.targets.size() > 0:
		finished.emit(CHASE)
	#var potential_target = _find_target_in_radius(FOLLOW_RADIUS)
	#if potential_target:
		#target = potential_target
		#current_state = State.FOLLOW
	pass

func _pick_new_roam_target() -> Node2D:
	if not roam_points.is_empty():
		return roam_points[randi() % roam_points.size()]
	return null


func _setup_roam_points():
	# Define roam points around the origin position
	for i in range(5):  # Example: 5 random spots
		var angle = randf_range(0, PI * 2)
		var distance = randf_range(0, ROAM_RADIUS)
		var point = Node2D.new()
		point.global_position = character.position + Vector2(cos(angle), sin(angle)) * distance
		roam_points.append(point)


func _pick_random_roam_return_point():
	_pick_new_roam_target()

func _move_towards_target(delta, target):
	pass
	#if position.distance_to(target.position) < ATTACK_DISTANCE:
		#current_state = State.ATTACK
	#elif position.distance_to(origin_position) > FOLLOW_RADIUS * 1.5:
		#current_state = State.RETURN
		#_pick_random_roam_return_point()
