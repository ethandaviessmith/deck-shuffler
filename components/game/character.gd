class_name Character extends CharacterBody2D

enum Spawn { NA, WRAP, SET, GUARD}

#@export var movement_speed = 30.0
#@export var hp = 3
#@export var damage = 1.0
@export var stats: Stats

@export var experience = 1
@export var knockback_recovery = 2


var knockback = Vector2.ZERO
@export var LOW_HEALTH = 1
@export var spawn_type = Spawn.WRAP

@export_group("Movement")
@export var speed: float = 30.0
@export var acceleration: float = 5.0
@export var friction: float = 5.0
## states that won't interupt action when hurt
@export var PRIORITY_STATES: Array[String] = [CharacterState.REPOSITION, CharacterState.SPAWN, CharacterState.RETREAT, CharacterState.REST]

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var sprite = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine;
@onready var hitbox: Hitbox2D = $Hitbox2D
@onready var status_effect: StatusEffectManager = $StatusEffectManager
@onready var damage_label = get_node("%damage_label")

signal next_state(next_state_path: String, data: Dictionary)
signal lock_state(lock: bool)
signal new_target(node: Node2D)
signal lost_target()

var max_health: int
var can_move = true
var targets:Array[Node2D] = []
var target


# Called when the node enters the scene tree for the first time.
func _ready():
	#max_health = hp
	#hitbox.damage = damage
	if hitbox:
		hitbox.on_enemy_hit.connect(on_enemy_hit)
		hitbox.stats = stats
	if get_spawn_type() == Character.Spawn.WRAP:
		targets.append(player)
	
	if not status_effect == null:
		pass
		status_effect.effect_proc.connect(on_effect_proc)
		status_effect.effect_duration.connect(on_effect_duration)
	

func _process(delta: float) -> void:
	pass

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity += knockback
	move_and_slide()

func on_effect_proc(stats: Stats):
	take_damage(stats.get_stat_value(Stat.Name.DAMAGE), Util.hit_color)
	Log.pr("character", "damage from effect", stats.get_stat_value(Stat.Name.DAMAGE))
	
	match(stats.get_stat_value(Stat.Name.STATUS_EFFECT)):
		Stat.EffectType.NA: pass
		Stat.EffectType.BURN: pass
		Stat.EffectType.FREEZE: pass
		Stat.EffectType.POISON: pass
		Stat.EffectType.SHOCK: 
			# add slow to buff 
			speed *= 0.9
			pass
	
	#if not status_effect == null:
	#status_effect.apply_effect(effect)
	pass

#bad example, should be damage not effect
func on_effect_duration(effect: EffectStats):
	pass


func get_spell_effect():
	Log.pr("char", "get spell effect")


func get_spawn_type() -> Spawn:
	return spawn_type
	
func is_priority_state():
	return PRIORITY_STATES.has(state_machine.state.name)

func teleport():
	next_state.emit(CharacterState.TELEPORT, {})

func take_damage(damage: int, color: Color = Util.hit_color):
	var hp: Stat = Stat.new_health(clamp(-damage + stats.get_stat_value(Stat.Name.ARMOR), -99.0, 0.0)) ## negative hp stat
	stats.add_stat(hp)
	
	if stats.get_stat_value(Stat.Name.HEALTH) <= 0:
		next_state.emit(CharacterState.DEATH)
	show_amount(damage, color)

## hitting others
func on_enemy_hit(charge = 1):
	pass

func get_stats() -> Stats:
	Log.pr("get_stats of hitbox")
	return stats

func has_low_health() -> bool:
	return stats.get_stat_value(Stat.Name.HEALTH) <= LOW_HEALTH

func recover_health(amount: int) -> int:
	var recovered = amount if stats.get_stat_value(Stat.Name.HEALTH) + amount <= stats.get_stat_value(Stat.Name.MAX_HEALTH) else 0
	var hp: Stat = Stat.new_health(clamp(stats.get_stat_value(Stat.Name.HEALTH) + amount, 0, stats.get_stat_value(Stat.Name.MAX_HEALTH)))
	stats.add_stat(hp)
	
	Log.pr("recover char", amount, stats.get_stat_value(Stat.Name.HEALTH), recovered)
	return recovered

func face_target(vector: Vector2):
	if global_position.direction_to(vector).x < 0.1:
		sprite.flip_h = true
	elif global_position.direction_to(vector).x > -0.1:
		sprite.flip_h = false

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

func _set_target(body: Node2D):
	target = body
	new_target.emit(target)
	
func _remove_target(body: Node2D):
	targets.erase(body)
	if targets.size() == 0:
		lost_target.emit()
	else:
		if target == body:
			_set_target(targets.pick_random())
