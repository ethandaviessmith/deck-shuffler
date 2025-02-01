@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name TopDownController extends CharacterBody2D

const GroupName: StringName = &"player"

var motion_input: TransformedInput = TransformedInput.new(self)


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var healthBar = get_node("%HealthBar")


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


func _ready() -> void:
	animation_player.play("idle")
	_on_hurt_box_2d_hurt(0,0,0)

func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	if motion_input.input_direction_horizontal_axis < 0.1:
		animated_sprite_2d.flip_h = true
	elif motion_input.input_direction_horizontal_axis > -0.1:
		animated_sprite_2d.flip_h = false
	

func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	match state.name:
		"TopDownIdle":
			animation_player.play("idle")
		"TopDownWalk":
			animation_player.play("walk")

func _on_hurt_box_2d_hurt(damage: Variant, angle: Variant, knockback: Variant) -> void:
	print("player hurt")
	hp -= clamp(damage-armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		pass#death()
