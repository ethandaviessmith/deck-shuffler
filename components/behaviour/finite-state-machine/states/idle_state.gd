@icon("res://components/behaviour/finite-state-machine/state.png")
class_name IdleState extends CharacterState


@export var IDLE_DURATION = 1.0
var idle_time = 0.0
@export var anim: AnimationPlayer


func enter(previous_state_path: String, data := {}) -> void:
	if not anim == null:
		anim.play("run")
		anim.seek(randf_range(0, anim.get_animation("run").length))

func exit() -> void:
	pass

func physics_update(_delta: float):
	decelerate(_delta)

func new_target(node: Node2D):
	target = node


func update(_delta: float):
	if not character.get_spawn_type() == Character.Spawn.NA:
		if character.get_spawn_type() == Character.Spawn.WRAP:
			finished.emit(CharacterState.CHASE,  {"key": character.player})
		idle_time += _delta
		#if Engine.get_process_frames() % 15 == 0:
		if idle_time >= IDLE_DURATION:
			idle_time = 0.0
			finished.emit(ROAM)
