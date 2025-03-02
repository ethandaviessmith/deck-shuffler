class_name Enemy extends Character



@onready var damage_label = $DamageLabel
#var death_anim = preload("res://Enemy/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	if get_spawn_type() == Character.Spawn.WRAP:
		targets.append(player)

func _process(delta: float) -> void:
	pass

func teleport():
	next_state.emit(CharacterState.TELEPORT, {})

func _on_hurtbox_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	#Log.pr("angle", angle, "knockback", knockback_amount)
	damage_label.text = str(damage)
	damage_label.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)
	
	var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(sprite, "modulate", Util.hit_color, 0.1)
	tween2.tween_property(sprite, "modulate", Util.normal_color, 0.1) 
	if hp <= 0:
		next_state.emit(CharacterState.DEATH, {})
	else:
		pass

func on_enemy_hit(hitbox: Hitbox2D, charge = 1):
	if spawn_type == Character.Spawn.GUARD: 
		next_state.emit(CharacterState.REPOSITION)
	else:
		next_state.emit(CharacterState.IDLE)

# Body and Area Signals connected
func _on_chase_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("target"):
		targets.append(body)
		_set_target(body)

func _on_chase_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("target"): # keep in list of targets for now
		if not spawn_type == Character.Spawn.GUARD: 
			_remove_target(body)

func _on_chase_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("target"):
		targets.append(area)
		_set_target(area)

func _on_chase_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("target"): # keep in list of targets for now
		_remove_target(area)
