@icon("res://components/behaviour/finite-state-machine/state.png")
class_name RoamState extends CharacterMachineState


@export var IDLE_DURATION = 0.2
var idle_time = 0.0

var roam_points: Array = []
const ROAM_RADIUS = 200


func _ready():
	pass


func enter() -> void:
	if roam_points.is_empty():
		origin_position = FSM.origin_position
		_setup_roam_points()
	target_position = _pick_new_roam_target()
	

func exit(_next_state: MachineState) -> void:
	pass
	

func handle_input(_event: InputEvent):
	pass


func physics_update(_delta: float):
	pass
	
	
func update(_delta: float):
	FSM.character.move_towards_target(_delta, target_position)
	#if position.distance_to(target_position) < 10:
		#current_state = State.IDLE
#
	#var potential_target = _find_target_in_radius(FOLLOW_RADIUS)
	#if potential_target:
		#target = potential_target
		#current_state = State.FOLLOW

func _pick_new_roam_target():
	if roam_points.size() > 0:
		return roam_points[randi() % roam_points.size()]


func _setup_roam_points():
	# Define roam points around the origin position
	for i in range(5):  # Example: 5 random spots
		var angle = randf_range(0, PI * 2)
		var distance = randf_range(0, ROAM_RADIUS)
		roam_points.append(origin_position + Vector2(cos(angle), sin(angle)) * distance)


func _pick_random_roam_return_point():
	_pick_new_roam_target()

func _move_towards_target(delta, target):
	pass
	#if position.distance_to(target.position) < ATTACK_DISTANCE:
		#current_state = State.ATTACK
	#elif position.distance_to(origin_position) > FOLLOW_RADIUS * 1.5:
		#current_state = State.RETURN
		#_pick_random_roam_return_point()
