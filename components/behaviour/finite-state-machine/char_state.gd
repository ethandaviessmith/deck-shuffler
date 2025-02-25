class_name CharacterState extends State


const IDLE = "IdleState"
const ROAM = "RoamState"
const CHASE = "ChaseState"
const JUMPING = "Jumping"
const FALLING = "Falling"

@export var speed: float = 300.0
@export var acceleration: float = 25.0
@export var friction: float = 50.0


var character: Character


var target: Node2D
var origin_position: Vector2
var target_position: Vector2

func _ready() -> void:
	await owner.ready
	character = owner as Character
	assert(character != null, "The PlayerState state type must be used only in the character scene. It needs the owner to be a Character node.")
	origin_position = character.position
	character.new_target.connect(_new_target)


func move(delta: float) -> void:
	if target_position == Vector2.ZERO:
		decelerate(delta)
	else:
		accelerate(delta)
		
	character.move_and_slide()

func dir_to_target():
	if target_position == Vector2.ZERO:
		return Vector2.ZERO
	return character.global_position.direction_to(target_position).normalized()

func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	if acceleration > 0:
		character.velocity = character.velocity.lerp(dir_to_target() * speed, acceleration * delta)
	else:
		character.velocity =  dir_to_target() * speed

func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if friction > 0:
		character.velocity = character.velocity.lerp(Vector2.ZERO, friction * delta)
	else:
		character.velocity = Vector2.ZERO
		
func _new_target(node: Node2D):
	target = node
	finished.emit(CHASE)
