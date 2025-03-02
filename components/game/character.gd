class_name Character extends CharacterBody2D

enum Spawn { NA, WRAP, SET, GUARD}

@export var movement_speed = 30.0
@export var hp = 3
@export var experience = 1
@export var damage = 1
@export var knockback_recovery = 2
var knockback = Vector2.ZERO
@export var spawn_type = Spawn.WRAP

@export_group("Movement")
@export var speed: float = 30.0
@export var acceleration: float = 5.0
@export var friction: float = 5.0


@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var sprite = $AnimatedSprite2D
@onready var state: StateMachine = $StateMachine;
@onready var hitbox: Hitbox2D = $Hitbox2D

signal next_state(next_state_path: String, data: Dictionary)
signal lock_state(lock: bool)

var can_move = true
var targets:Array[Node2D] = []
var target

signal new_target(node: Node2D)
signal lost_target()

func get_spawn_type() -> Spawn:
	return spawn_type

# Called when the node enters the scene tree for the first time.
func _ready():
	hitbox.damage = damage
	hitbox.on_enemy_hit.connect(on_enemy_hit)
	if get_spawn_type() == Character.Spawn.WRAP:
		targets.append(player)

func _process(delta: float) -> void:
	pass

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity += knockback
	move_and_slide()

func teleport():
	next_state.emit(CharacterState.TELEPORT, {})

func on_enemy_hit(hitbox: Hitbox2D, charge = 1):
	pass

func face_target(vector: Vector2):
	if global_position.direction_to(vector).x < 0.1:
		sprite.flip_h = true
	elif global_position.direction_to(vector).x > -0.1:
		sprite.flip_h = false

func _set_target(body: Node2D):
	target = body
	new_target.emit(target)
	
func _remove_target(body: Node2D):
	targets.erase(body)
	if targets.size() == 0:
		lost_target.emit()
	else:
		if target == body:
			_set_target(targets.pick_random())
