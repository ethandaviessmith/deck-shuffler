extends CharacterBody2D

@export var movement_speed = 30.0
@export var hp = 3
@export var knockback_recovery = 2
@export var experience = 1
@export var enemy_damage = 1
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $AnimatedSprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer;
#@onready var anim = 
#@onready var snd_hit = $snd_hit
@onready var hitBox = $Hitbox2D

#var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://scenes/world/experience_gem.tscn")

signal remove_from_array(object)

var can_move = true

const run = "run";

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play(run)
	print(randf_range(0, anim.get_animation(run).length))
	anim.seek(randf_range(0, anim.get_animation(run).length))
	
	hitBox.damage = enemy_damage
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _physics_process(_delta):
	
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = Vector2.ZERO;
	if(can_move):
		direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x < 0.1:
		sprite.flip_h = true
	elif direction.x > -0.1:
		sprite.flip_h = false




func death():
	emit_signal("remove_from_array",self)
	can_move = false;
	anim.play("die")
	#var enemy_death = death_anim.instantiate()
	#enemy_death.scale = sprite.scale
	#enemy_death.global_position = global_position
	#get_parent().call_deferred("add_child",enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child",new_gem)
	await get_tree().create_timer($AnimationPlayer.current_animation_length).timeout
	queue_free()

func _on_hurtbox_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	print(angle)
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		pass
		#snd_hit.play()
