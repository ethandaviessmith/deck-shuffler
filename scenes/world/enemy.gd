class_name Character extends CharacterBody2D

@export var movement_speed = 30.0
@export var hp = 3
@export var experience = 1
@export var enemy_damage = 1
@export var knockback_recovery = 2
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $AnimatedSprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer;
@onready var state: StateMachine = $FiniteStateMachine;

@onready var hitBox = $Hitbox2D
@onready var damage_label = $DamageLabel
var normal_color = Color(1, 1, 1) 
var hit_color = Color(1, .7, .7)

@onready var sfx_audio:AudioStreamPlayer2D = $SFXAudioStream
@export var pitch_variance: float = 0.1  # Pitch variance range
@export var volume_variance: float = 0.1  # Volume variance range

#var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://scenes/world/experience_gem.tscn")

signal remove_from_array(object)

var can_move = true
var targets:Array[Node2D] = []

signal new_target(node: Node2D)


# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("run")
	anim.seek(randf_range(0, anim.get_animation("run").length))
	hitBox.damage = enemy_damage
	
	#state.change_state_to(IdleState)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move_towards_target(_delta: float, target:Vector2):
	if(can_move):
		var direction = global_position.direction_to(target)
		velocity = direction * movement_speed
	

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = Vector2.ZERO;
	#if(can_move):
		#direction = global_position.direction_to(player.global_position)
	#velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x < 0.1:
		sprite.flip_h = true
	elif direction.x > -0.1:
		sprite.flip_h = false


func death():
	emit_signal("remove_from_array",self)
	can_move = false;
	anim.play("die")
	play_with_randomized_audio(sfx_audio)
	#var enemy_death = death_anim.instantiate()
	#enemy_death.scale = sprite.scale
	#enemy_death.global_position = global_position
	#get_parent().call_deferred("add_child",enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child",new_gem)
	await get_tree().create_timer($AnimationPlayer.current_animation_length).timeout
	queue_free()

func play_with_randomized_audio(sound: AudioStreamPlayer2D):
	sound.pitch_scale = sound.pitch_scale * (1.0 + randf_range(-pitch_variance, pitch_variance))
	sound.volume_db = sound.volume_db + randf_range(-volume_variance, volume_variance)
	sound.play()

func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	match state.name:
		"idle":
			Log.pr("idle", "finished")
		"TopDownWalk":
			pass#animation_player.play("walk")

func _on_hurtbox_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	Log.pr("angle", angle, "knockback", knockback_amount)
	damage_label.text = str(hp)
	damage_label.modulate.a = 1
	var tween = create_tween()
	tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)
	
	var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(sprite, "modulate", hit_color, 0.1)
	tween2.tween_property(sprite, "modulate", normal_color, 0.1) 
	if hp <= 0:
		death()
	else:
		pass
		#snd_hit.play()


# Body and Area Signals connected
func _on_chase_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("target"):
		targets.append(body)
		new_target.emit(body)
	Log.pr("enter", body.name)

func _on_chase_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("target"): # keep in list of targets for now
		targets.erase(body) 
		Log.pr("exit", body.name)


func _on_chase_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("target"):
		targets.append(area)
		new_target.emit(area)
	Log.pr("enter", area.name)


func _on_chase_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("target"): # keep in list of targets for now
		targets.erase(area) 
		Log.pr("exit", area.name)
