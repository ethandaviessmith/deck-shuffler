class_name WeaponHitBox extends Node2D

var level = 1
@export var hp = 1
@export var speed = 200
@export var damage = 1
@export var knockback_amount = 100
@export var attack_size = 1.0

@export var buff: StatsBuff

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var hitbox: Hitbox2D = $Hitbox2D
@onready var snd_play:AudioStreamPlayer2D = $snd_play
@onready var sprite:Sprite2D =$Sprite2D

signal remove_from_array(object)

func _ready(): 
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	
	if not buff == null:
		hp = buff.hp
		speed = buff.speed
		damage = buff.damage
		knockback_amount = buff.knockback_amount
		attack_size = buff.attack_size
	
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle*speed*delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		_play_death_effect()

func add_buff(add_buff:StatsBuff):
	buff = add_buff

func _play_death_effect():
	snd_play.play()
	#await darken_sprite()
	await jitter_and_shrink()
	emit_signal("remove_from_array",self)
	queue_free()
	
# Fade animation
var darken_duration = 0.5  # Duration in seconds
var shrink_duration = 0.5  # Duration in seconds
var jitter_intensity = 5   # Pixel intensity of the jitter
var jitter_duration = 0.1  # Duration for each jitter
var total_jitter_time = 0.5  # Total time to apply jitter

func darken_sprite():
	var time_passed = 0.0
	while time_passed < darken_duration:
		var factor = time_passed / darken_duration
		sprite.modulate = Color(1 - factor, 1 - factor, 1 - factor, 1)  # Darken the sprite
		var timer = get_tree().create_timer(0.016)
		await timer.timeout
		time_passed += 0.016

func jitter_and_shrink():
	var time_passed = 0.0
	var original_scale = sprite.scale
	
	while time_passed < total_jitter_time:
		var factor = time_passed / total_jitter_time
		sprite.modulate = Color(1 - factor, 1 - factor, 1 - factor, 1)  # Darken the sprite
		# Randomize the jitter effect
		sprite.position += Vector2(
			randf_range(-jitter_intensity, jitter_intensity),
			randf_range(-jitter_intensity, jitter_intensity)
		)
		# Gradually shrink the sprite
		var shrink_factor = time_passed / shrink_duration
		sprite.scale = original_scale * (1 - shrink_factor)
		var timer = get_tree().create_timer(jitter_duration)
		await timer.timeout
		sprite.position = Vector2.ZERO  # Reset position after jitter
		time_passed += jitter_duration

	# Ensure the sprite ends up at the final scale
	sprite.scale = original_scale * (1 - total_jitter_time / shrink_duration)

func _on_timer_timeout():
	_play_death_effect()

func _on_timer_death_timeout() -> void:
	_play_death_effect() # Replace with function body.
