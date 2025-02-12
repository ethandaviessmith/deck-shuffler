class_name WeaponHitBox extends Node2D

var level = 1
@export var hp = 1
@export var damage = 1

@export var knockback = 100
@export var speed = 200
@export var size = 1.0

@export var buff: AttackStats

@export var pitch_variance: float = 0.1  # Pitch variance range
@export var volume_variance: float = 0.1  # Volume variance range

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var hitbox: Hitbox2D = $Hitbox2D
@onready var start_audio:AudioStreamPlayer2D = $StartAudioStream
@onready var hit_audio:AudioStreamPlayer2D = $HitAudioStream
@onready var sprite:Sprite2D =$Sprite2D

signal remove_from_array(object)

func _ready(): 
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	
	if not buff == null:
		hp += buff.durability
		damage += buff.damage
		
		knockback *= buff.knockback
		speed *= buff.speed
		size *= buff.size
	
	scale = Vector2(0.2,0.2)
	var tween = create_tween()
	tween.tween_property(self,"scale", Vector2(1,1) * size, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.play()
	play_with_randomized_audio(start_audio)

func _physics_process(delta):
	position += angle * speed * delta

func enemy_hit(charge = 1):
	hp -= charge
	play_with_randomized_audio(hit_audio)
	if hp <= 0:
		$CollisionShape2D.call_deferred("set","disabled",true)
		_play_death_effect()
		

func set_buff(_buff:AttackStats):
	buff = _buff
	
# Randomize pitch slightly by adjusting the pitch scale and volume slightly by adjusting the volume in dB
func play_with_randomized_audio(sound: AudioStreamPlayer2D):
	sound.pitch_scale = sound.pitch_scale * (1.0 + randf_range(-pitch_variance, pitch_variance))
	sound.volume_db = sound.volume_db + randf_range(-volume_variance, volume_variance)
	sound.play()


func _play_death_effect():
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
