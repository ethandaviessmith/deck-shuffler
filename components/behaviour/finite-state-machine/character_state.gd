class_name CharacterStateMachine extends FiniteStateMachine

var origin_position: Vector2
var target_position: Vector2
@export var character: CharacterBody2D



func _ready():
	super()
	origin_position = character.position
	Log.pr("set_postition", origin_position)
	#_setup_roam_points()


func state_ended_change(state: MachineState):
	if state.name == "IdleState":
		change_state_to(RoamState)
	
		#current_state = State.ROAM
		#_pick_new_roam_target()
		# what to do after idle

func _on_state_ended(state: Variant) -> void:
	pass
	#Log.pr("end idle state", state)


#func _follow_state(delta):
	#if not target:
		#current_state = State.RETURN
		#_pick_random_roam_return_point()
		#return
#
#
#func _attack_state(delta):
	#_do_attack()
	#target = null
	#current_state = State.RETURN
	#_pick_random_roam_return_point()
#
#func _return_state(delta):
	#_move_towards_target(delta)
	#if position.distance_to(target_position) < 10:
		#current_state = State.IDLE
#
#func _move_towards_target(delta, custom_target: Vector2 = null):
	#var target_pos = custom_target if custom_target else target_position
	#velocity = (target_pos - position).normalized() * 100  # Speed can be adjusted
	#move_and_slide()
#
#func _find_target_in_radius(radius: float) -> Node2D:
	#var candidates = []
	#for node in get_tree().get_nodes_in_group("target"):
		#if node is Node2D and node.position.distance_to(position) <= radius:
			#candidates.append(node)
	#if candidates.size() > 0:
		#return candidates[randi() % candidates.size()]
	#return null
