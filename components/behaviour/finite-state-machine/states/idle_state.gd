@icon("res://components/behaviour/finite-state-machine/state.png")
class_name IdleState extends CharacterState


@export var IDLE_DURATION = 0.2
var idle_time = 0.0



func enter(previous_state_path: String, data := {}) -> void:
	pass

func exit() -> void:
	pass
	


func physics_update(_delta: float):
	pass
	
	
func update(_delta: float):
	idle_time += _delta
	#if Engine.get_process_frames() % 15 == 0:
	if idle_time >= IDLE_DURATION:
		#Log.pr("idle", idle_time)
		idle_time = 0.0
		finished.emit(ROAM)
	#	FSM.state_ended.emit(self)
	#move(_delta)
