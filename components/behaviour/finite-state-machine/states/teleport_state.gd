@icon("res://components/behaviour/finite-state-machine/state.png")
class_name TeleportState extends CharacterState


@export var IDLE_DURATION = 0.5
var idle_time = 0.0
@export var anim: AnimationPlayer


func enter(previous_state_path: String, data := {}) -> void:
	origin_position = character.global_position
	
	if not anim == null:
		anim.play("run")
		anim.seek(randf_range(0, anim.get_animation("run").length))

func exit() -> void:
	pass
	


func physics_update(_delta: float):
	pass

func update(_delta: float):
	idle_time += _delta
	#if Engine.get_process_frames() % 15 == 0:
	if idle_time >= IDLE_DURATION:
		idle_time = 0.0
		finished.emit(IDLE)
