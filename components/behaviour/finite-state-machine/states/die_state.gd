@icon("res://components/behaviour/finite-state-machine/state.png")
class_name DieState extends CharacterState

@export var FRICTION = 100
@export var anim: AnimationPlayer
@export var sfx_audio: AudioStreamPlayer2D
@export var hurtbox: Hurtbox2D

@onready var loot_base = get_tree().get_first_node_in_group("loot")
var exp_gem = preload("res://scenes/world/experience_gem.tscn")


var idle_time = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	death()

func exit() -> void:
	pass

func physics_update(_delta: float):
	decelerate(_delta)

func update(_delta: float):
	pass

func death():
	character.friction = FRICTION
	character.knockback = Vector2.ZERO
	character.lock_state.emit(true)
	if not hurtbox == null:
		hurtbox.disable()
	if not anim == null:
		anim.play("die")
	if not sfx_audio == null:
		Util.play_with_randomized_audio(sfx_audio)
	#var enemy_death = death_anim.instantiate()
	#enemy_death.scale = sprite.scale
	#enemy_death.global_position = global_position
	#get_parent().call_deferred("add_child",enemy_death)
	
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = character.global_position
	new_gem.experience = character.experience
	loot_base.call_deferred("add_child", new_gem)
	
	await get_tree().create_timer(anim.current_animation_length).timeout
	if not character.get_spawn_type() == Character.Spawn.NA:
		character.queue_free()

func _new_target(node: Node2D):
	pass
