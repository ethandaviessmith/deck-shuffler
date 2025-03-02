@icon("res://components/behaviour/finite-state-machine/state.png")
class_name SpawnState extends CharacterState

@export var SPAWN_COUNT = 6
@export var SPAWN_RATE = 1.1
@export var SPAWN_SCENE:Resource
@export var SPAWN_RADIUS:= 15.0
@onready var enemy_base = get_tree().get_first_node_in_group("enemy")

var idle_time := 0.0
var _spawn_count := 0
@export var anim: AnimationPlayer
@export var sfx_audio: AudioStreamPlayer2D

func enter(previous_state_path: String, data := {}) -> void:
	_spawn_count = 0
	if not anim == null:
		anim.play("breathing")

func exit() -> void:
	pass

func physics_update(delta: float):
	decelerate(delta)

func update(delta: float):
	idle_time += delta
	#if Engine.get_process_frames() % 15 == 0:
	if idle_time >= SPAWN_RATE:
		idle_time = 0.0
		var new_enemy = SPAWN_SCENE.instantiate()
		new_enemy.global_position = get_random_position_away_from_target(character, SPAWN_RADIUS)
		new_enemy.experience = character.experience
		new_enemy.spawn_type = Character.Spawn.SET
		enemy_base.call_deferred("add_child", new_enemy)
		_spawn_count += 1
		Log.pr("spawn enemy", _spawn_count, SPAWN_COUNT)
		Util.play_with_randomized_audio(sfx_audio)
	if _spawn_count >= SPAWN_COUNT:
		Log.pr("spawn idle")
		finished.emit(IDLE)
		
func new_target(node: Node2D):
	target = node
	Log.pr("in spawn", self)

func get_random_position_away_from_target(target: Node2D, radius: float) -> Vector2:
	var random_angle = randf_range(0.0, 2.0 * PI)
	var offset = Vector2(cos(random_angle), sin(random_angle)) * SPAWN_RADIUS
	return character.global_position + offset
