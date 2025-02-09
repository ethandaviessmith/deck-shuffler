extends Area2D

@export var experience = 1

#var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
#var spr_blue= preload("res://Textures/Items/Gems/Gem_blue.png")
#var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")

var target = null
var speed = -0.5

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_play
var lifetime = 3.0  # Total time before the sprite destroys itself in seconds
var jitter_start_time = 2.5
var jitter_intensity = 1.8  # Intensity of the jitter effect
var fade_duration = 0.4  # Duration of the fade-out effect in seconds
var time_elapsed = 0.0

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		pass
		#sprite.texture = spr_blue
	else:
		pass
		#sprite.texture = spr_red
	sprite.material.set_shader_parameter("time", Time.get_ticks_usec() / 1000000.0)

func _process(delta):
	time_elapsed += delta
	
	# Handle jitter effect
	if time_elapsed > jitter_start_time and time_elapsed < lifetime - fade_duration:
		var jitter_offset = Vector2(randf_range(-jitter_intensity, jitter_intensity),randf_range(-jitter_intensity, jitter_intensity)/2)
		position += jitter_offset

	# Handle fade-out and destruction
	if time_elapsed > lifetime - fade_duration:
		var fade_factor = 1.0 - (time_elapsed - (lifetime - fade_duration)) / fade_duration
		sprite.modulate.a = max(fade_factor, 0.0)   # Fade out using the alpha channel

	# Destroy the sprite after its lifetime
	if time_elapsed >= lifetime:
		queue_free()

func update_frame_info():
	var frame_size = Vector2(1.0 / 5, 1.0 / 5)  # Assuming known number of columns & rows
	sprite.material.set_shader_parameter("sprite_frame_size", frame_size)
	sprite.material.set_shader_parameter("current_frame", sprite.frame)

func _physics_process(delta):
	update_frame_info()
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		$AnimationPlayer.play("spin")
		speed += 3 * delta

func collect():
	sound.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return experience

func _on_snd_play_finished() -> void:
	queue_free()
