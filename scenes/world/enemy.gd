extends Node2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func death():
	emit_signal("remove_from_array",self)
	#var enemy_death = death_anim.instantiate()
	#enemy_death.scale = sprite.scale
	#enemy_death.global_position = global_position
	#get_parent().call_deferred("add_child",enemy_death)
	#var new_gem = exp_gem.instantiate()
	#new_gem.global_position = global_position
	#new_gem.experience = experience
	#loot_base.call_deferred("add_child",new_gem)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	#hp -= damage
	#knockback = angle * knockback_amount
	#if hp <= 0:
	#	death()
	#else:
		#snd_hit.play()
	pass
