@icon("res://components/behaviour/finite-state-machine/state.png")
class_name RestState extends CharacterState


@export var REST_DURATION = 1.0
var rest_time = 0.0
@export var anim: AnimationPlayer
@export var sfx_audio: AudioStreamPlayer2D


func enter(previous_state_path: String, data := {}) -> void:
	if not anim == null:
		anim.play("breathing")
		#anim.seek(randf_range(0, anim.get_animation("run").length))

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
		rest_time += _delta
		#if Engine.get_process_frames() % 15 == 0:
		if rest_time >= REST_DURATION:
			Util.play_with_randomized_audio(sfx_audio)
			rest_time = 0.0
			var healed = character.recover_health(1)
			if healed == 0:
				finished.emit(ROAM)
