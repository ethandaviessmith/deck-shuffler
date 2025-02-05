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

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		pass
		#sprite.texture = spr_blue
	else:
		pass
		#sprite.texture = spr_red

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 3 * delta

func collect():
	sound.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return experience

func _on_snd_play_finished() -> void:
	queue_free()
