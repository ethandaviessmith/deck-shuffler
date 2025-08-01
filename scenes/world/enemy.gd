class_name Enemy extends Character

@export var nest:Resource

var spawn_nest: Node2D
#var death_anim = preload("res://Enemy/explosion.tscn")
@onready var enemy_base = get_tree().get_first_node_in_group("enemy")
@export var sfx_audio: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	stats = preload("res://components/game/stat_enemy.tres").duplicate()
	super()
	
	if get_spawn_type() == Character.Spawn.WRAP:
		targets.append(player)
	if not nest == null and nest.can_instantiate():
		spawn_nest = nest.instantiate()
		spawn_nest.global_position = global_position
		enemy_base.call_deferred("add_child", spawn_nest)

func get_stats() -> Stats:
	Log.pr("get_stats of enemy")
	return stats

func _process(delta: float) -> void:
	pass

func teleport():
	next_state.emit(CharacterState.TELEPORT, {})

func get_retreat() -> Node2D:
	if not spawn_nest == null:
		return spawn_nest
	else:
		var node = Node2D.new()
		node.global_position = Vector2.ZERO # zero is a bad position, fix later
		return node

func recover_health(amount: int) -> int:
	Log.pr("recover char", amount)
	show_amount(amount, Util.heal_color)
	return super.recover_health(amount)

func on_enemy_hit(charge = 1):
	if spawn_type == Character.Spawn.GUARD: 
		next_state.emit(CharacterState.REPOSITION)
	else:
		next_state.emit(CharacterState.IDLE)
	if not sfx_audio == null:
		Util.play_with_randomized_audio(sfx_audio)


func _on_hurtbox_2d_status_effect(effect: SpellStats) -> void:
	Log.pr("hurtbox","spell","effect signal removed temp")
	#if not status_effect == null:
		#status_effect.add_from_spell(effect)

func _on_hurtbox_2d_hurt(hurt_stats: Stats, angle: Variant) -> void:
	Util.play_with_randomized_audio(sfx_audio)
	if hurt_stats.has(Stat.Name.DAMAGE):
		take_damage(hurt_stats.get_stat_value(Stat.Name.DAMAGE))
	if hurt_stats.has(Stat.Name.KNOCKBACK):
		knockback = angle * hurt_stats.get_stat_value(Stat.Name.KNOCKBACK)
	if hurt_stats.has(Stat.Name.STATUS_EFFECT):
		status_effect.add_from_stat(hurt_stats)
	if stats.get_stat_value(Stat.Name.HEALTH) <= 0:
		next_state.emit(CharacterState.DEATH)
	else:
		if not is_priority_state(): # list of states not to interupt
			next_state.emit(CharacterState.CHASE, {"target": player})

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
