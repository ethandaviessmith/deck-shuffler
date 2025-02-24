@icon("res://components/behaviour/finite-state-machine/state.png")
class_name IdleState extends CharacterMachineState


@export var IDLE_DURATION = 0.2
var idle_time = 0.0


func ready() -> void:
	pass


func enter() -> void:
	pass
	

func exit(_next_state: MachineState) -> void:
	pass
	

func handle_input(_event: InputEvent):
	pass


func physics_update(_delta: float):
	pass
	
	
func update(_delta: float):
	idle_time += _delta
	#if Engine.get_process_frames() % 15 == 0:
	if idle_time >= IDLE_DURATION:
		Log.pr("idle", idle_time)
		idle_time = 0.0
		FSM.state_ended.emit(self)
