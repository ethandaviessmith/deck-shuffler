@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name Player extends CharacterBody2D

const GroupName: StringName = &"player"

var motion_input: TransformedInput = TransformedInput.new(self)


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var healthBar = get_node("%HealthBar")
@onready var attacks = get_node("/root/World/Attacks")


#Player
var movement_speed = 40.0
var hp = 80
var maxhp = 80
var last_movement = Vector2.UP
var time = 0

var experience = 0
var experience_level = 1
var collected_experience = 0

#UPGRADES
#var collected_upgrades = []
#var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0


#Knife
var knife_baseammo = 1
var knife_ammo = knife_baseammo
var knife_attackspeed = .5
var knife_level = 1

var enemy_close = []

#AttackNodes
var knife = preload("res://scenes/world/weapon_dagger.tscn")
@onready var knifeTimer = get_node("%KnifeTimer")
@onready var knifeAttackTimer = get_node("%KnifeAttackTimer")



func _ready() -> void:
	animation_player.play("idle")
	_on_hurt_box_2d_hurt(0,0,0)
	attack()

func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	if motion_input.input_direction_horizontal_axis < 0.1:
		animated_sprite_2d.flip_h = true
	elif motion_input.input_direction_horizontal_axis > -0.1:
		animated_sprite_2d.flip_h = false
	
func attack():
	#print("atack")
	if knife_level > 0:
		knifeTimer.wait_time = knife_attackspeed * (1-spell_cooldown)
		if knifeTimer.is_stopped():
			knifeTimer.start()

func get_random_enemy():
	if enemy_close.size() > 0:
		return enemy_close.pick_random()
	else:
		return null


# SIGNALS
func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	match state.name:
		"TopDownIdle":
			animation_player.play("idle")
		"TopDownWalk":
			animation_player.play("walk")

func _on_hurt_box_2d_hurt(damage: Variant, angle: Variant, knockback: Variant) -> void:
	#print("player hurt")
	hp -= clamp(damage-armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		pass#death()


func _on_knife_attack_timer_timeout() -> void:
	#print("attack timer timout")
	if knife_ammo > 0:
		
		if not get_random_enemy() == null:
			var knife_attack = knife.instantiate()
			knife_attack.position = position
			knife_attack.target = get_random_enemy().global_position
			knife_attack.level = knife_level
			attacks.add_child(knife_attack)
			knife_ammo -= 1
			if knife_ammo > 0:
				knifeAttackTimer.start()
			else:
				knifeAttackTimer.stop()

func _on_knife_timer_timeout() -> void:
	#print("timer timout")
	knife_ammo += knife_baseammo + additional_attacks
	knifeAttackTimer.start()

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)
