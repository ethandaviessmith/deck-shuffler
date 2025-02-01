@icon("res://components/collisions/hurtbox.svg")
class_name Hurtbox2D extends Area2D

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

#signal hitbox_detected(hitbox: Hitbox2D)
signal hurt(damage, angle, knockback)

func _init() -> void:
	monitoring = true
	monitorable = false
	collision_mask = GameGlobals.hitboxes_collision_layer
	

func _ready():
	area_entered.connect(on_area_entered)


func enable():
	set_deferred("monitoring", true)
	

func disable():
	set_deferred("monitoring", false)


func on_area_entered(hitbox: Hitbox2D) -> void:
	#hitbox_detected.emit(hitbox)
	if not hitbox.get("damage") == null:
		collision.call_deferred("set","disabled",true)
		disableTimer.start()
		var damage = hitbox.damage
		var angle = Vector2.ZERO
		var knockback = 1
		if not hitbox.get("angle") == null:
			angle = hitbox.angle
		if not hitbox.get("knockback_amount") == null:
			knockback = hitbox.knockback_amount
		
		emit_signal("hurt",damage, angle, knockback)

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)
