@icon("res://components/behaviour/finite-state-machine/fsm.png")
class_name StateMachine extends Node

@export var initial_state: State = null

@onready var state_label = $"../Node2D/StateLabel" #debugging
@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	await owner.ready
	if owner.has_signal("next_state"):
		owner.next_state.connect(_transition_to_next_state)
	state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	#Log.pr("state", target_state_path, previous_state_path, owner)
	if(previous_state_path != CharacterState.DEATH):
		state.exit()
		state = get_node(target_state_path)
		state.enter(previous_state_path, data)
		
		if not state_label == null:
			state_label.text = target_state_path # show and hide state on change
			state_label.modulate.a = 1
			var tween = create_tween()
			tween.tween_property(state_label, "modulate:a", 0.0, 1.0)
