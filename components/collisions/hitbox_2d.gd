@icon("res://components/collisions/hitbox.svg")
class_name Hitbox2D extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer


func _init() -> void:
	collision_mask = 0
	collision_layer = GameGlobals.hitboxes_collision_layer
	monitoring = false
	monitorable = true
	
func _ready():
	pass

func enable():
	set_deferred("monitorable", true)
	

func disable():
	set_deferred("monitorable", false)


func tempdisable():
	collision.call_deferred("set","disabled",true)
	disableTimer.start()


func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set","disabled",false)
