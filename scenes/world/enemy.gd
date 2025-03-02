class_name Enemy extends Character

@onready var damage_label = $DamageLabel
@export var nest:Resource

var spawn_nest: Node2D
#var death_anim = preload("res://Enemy/explosion.tscn")
@onready var enemy_base = get_tree().get_first_node_in_group("enemy")
@export var sfx_audio: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	if get_spawn_type() == Character.Spawn.WRAP:
		targets.append(player)
	if not nest == null and nest.can_instantiate():
		spawn_nest = nest.instantiate()
		spawn_nest.global_position = global_position
		enemy_base.call_deferred("add_child", spawn_nest)

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

func _on_hurtbox_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	#Log.pr("angle", angle, "knockback", knockback_amount)
	
	show_amount(damage, Util.hit_color)
	if hp <= 0:
		next_state.emit(CharacterState.DEATH)
	else:
		if not is_priority_state(): # list of states not to interupt
			next_state.emit(CharacterState.CHASE, {"target": player})

func recover_health(amount: int) -> int:
	Log.pr("recover char", amount)
	show_amount(amount, Util.heal_color)
	return super.recover_health(amount)


func show_amount(amount: int, color: Color):
	if not damage_label == null:
		damage_label.text = str(amount)
		damage_label.modulate.a = 1
		damage_label.set("theme_override_colors/font_color", color)
		var tween = create_tween()
		tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)
		var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween2.tween_property(sprite, "modulate", color, 0.5)
		tween2.tween_property(sprite, "modulate", Util.normal_color, 0.1) 

func on_enemy_hit(charge = 1):
	if spawn_type == Character.Spawn.GUARD: 
		next_state.emit(CharacterState.REPOSITION)
	else:
		next_state.emit(CharacterState.IDLE)
	if not sfx_audio == null:
		Util.play_with_randomized_audio(sfx_audio)

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
