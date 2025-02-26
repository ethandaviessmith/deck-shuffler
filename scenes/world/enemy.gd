class_name Character extends CharacterBody2D

enum Spawn { WRAP, SET}

@export var movement_speed = 30.0
@export var hp = 3
@export var experience = 1
@export var enemy_damage = 1
@export var knockback_recovery = 2
var knockback = Vector2.ZERO

@export var speed: float = 30.0
@export var acceleration: float = 5.0
@export var friction: float = 5.0
@export var spawn_type = Spawn.WRAP

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var sprite = $AnimatedSprite2D
@onready var state: StateMachine = $FiniteStateMachine;
@onready var hitBox = $Hitbox2D
@onready var damage_label = $DamageLabel
#var death_anim = preload("res://Enemy/explosion.tscn")

signal next_state(object:String)

var can_move = true
var targets:Array[Node2D] = []
var target

signal new_target(node: Node2D)
signal lost_target()

func get_spawn_type() -> Spawn:
	return spawn_type

# Called when the node enters the scene tree for the first time.
func _ready():
	hitBox.damage = enemy_damage

func _process(delta: float) -> void:
	pass

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity += knockback
	move_and_slide()

func teleport():
	next_state.emit(CharacterState.TELEPORT)
	
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

func _on_hurtbox_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	#Log.pr("angle", angle, "knockback", knockback_amount)
	damage_label.text = str(hp)
	damage_label.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)
	
	var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(sprite, "modulate", Util.hit_color, 0.1)
	tween2.tween_property(sprite, "modulate", Util.normal_color, 0.1) 
	if hp <= 0:
		next_state.emit(CharacterState.DEATH)
	else:
		pass

# Body and Area Signals connected
func _on_chase_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("target"):
		targets.append(body)
		_set_target(body)

func _on_chase_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("target"): # keep in list of targets for now
		_remove_target(body)

func _on_chase_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("target"):
		targets.append(area)
		new_target.emit(area)

func _on_chase_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("target"): # keep in list of targets for now
		_remove_target(area)
