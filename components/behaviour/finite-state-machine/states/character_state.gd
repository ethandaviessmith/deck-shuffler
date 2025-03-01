class_name CharacterState extends State


const IDLE = "IdleState"
const ROAM = "RoamState"
const CHASE = "ChaseState"
const DEATH = "DieState"
const ATTACK = "AttackState"
const TELEPORT = "TeleportState"
const ORBIT = "OrbitState"
const REPOSITION = "RepositionState"

var character: Character

var target: Node2D
var origin_position: Vector2
var target_offset: Vector2 = Vector2.ZERO

const DISTANCE_BESIDE = 10
const DISTANCE_CLOSE = 30
const DISTANCE_NEAR = 60

func _ready() -> void:
	await owner.ready
	character = owner as Character
	assert(character != null, "The PlayerState state type must be used only in the character scene. It needs the owner to be a Character node.")
	origin_position = character.position
	character.new_target.connect(_new_target)
	character.lost_target.connect(_lost_target)


func move_position(position: Vector2, delta: float = get_physics_process_delta_time()) -> void:
	if not position == Vector2.ZERO:
		accelerate(position, delta)
		character.face_target(get_position())
	else:
		decelerate(delta)
	character.move_and_slide()

func move(delta: float) -> void:
	if _is_target_valid(target):
		move_position(target.global_position, delta)
	else:
		decelerate(delta)

func get_position() -> Vector2:
	return target.global_position + target_offset

func _is_target_valid(node):
	return not (node == null or not is_instance_valid(node) or node.global_position == Vector2.ZERO)

func dir_to_target(pos):
	if pos == Vector2.ZERO:
		return Vector2.ZERO
	return character.global_position.direction_to(get_position()).normalized()

func accelerate(pos: Vector2, delta: float = get_physics_process_delta_time()) -> void:
	if character.acceleration > 0:
		character.velocity = character.velocity.lerp(dir_to_target(pos) * character.speed, character.acceleration * delta)
	else:
		character.velocity =  dir_to_target(pos) * character.speed

func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if character.friction > 0:
		character.velocity = character.velocity.lerp(Vector2.ZERO, character.friction * delta)
	else:
		character.velocity = Vector2.ZERO
		
func _new_target(node: Node2D):
	target = node
	finished.emit(CHASE, {"target": target})

func _lost_target():
	target = null
	finished.emit(IDLE)
