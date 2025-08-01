@icon("res://components/behaviour/finite-state-machine/state.png")
class_name ChaseState extends CharacterState

const CHASE_DISTANCE = 80
const OFFSET = 50
var positions = [ Vector2.ZERO, Vector2(0, -CHASE_DISTANCE), Vector2(0, CHASE_DISTANCE), Vector2(-CHASE_DISTANCE, 0), Vector2(CHASE_DISTANCE, 0) ]

@export var anim: AnimationPlayer

func enter(previous_state_path: String, data := {}) -> void:
	if not data.get("target") == null:
		target = data.get("target")
	else:
		if target == null:
			if _is_target_valid(character):
				target = character.targets.pick_random() 
	if not character.spawn_type == Character.Spawn.GUARD: 
		target_offset =  positions[randi() % positions.size()]
	
	if not anim == null:
		anim.play("run")

func exit() -> void:
	target_offset = positions[0]
	

func physics_update(_delta: float):
	move(_delta)

func new_target(node: Node2D):
	target = node


func update(_delta: float):
	if is_instance_valid(target):
		if character.spawn_type == Character.Spawn.GUARD:
			if character.has_low_health():
				finished.emit(RETREAT)
			if character.global_position.distance_to(get_position()) < DISTANCE_NEAR:
				finished.emit(ATTACK)
		else:
			if character.global_position.distance_to(get_position()) < DISTANCE_CLOSE:
				finished.emit(ATTACK)
				pass
		#var direction = character.global_position.direction_to(target.global_position)
		#character.velocity = direction * character.movement_speed * _delta
		#character.move_towards_target(_delta, target.global_position)
			#finished.emit(ATTACK)
	else:
		finished.emit(IDLE)
