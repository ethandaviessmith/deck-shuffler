@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name Player extends CharacterBody2D

const GroupName: StringName = &"player"

var motion_input: TransformedInput = TransformedInput.new(self)

@export var card_scene = preload("res://scenes/world/card.tscn")
#var card: Card

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var attacks = get_node("/root/World/Attacks")
@onready var healthBar = get_node("%HealthBar")
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var manaBar = get_node("%ManaBar")
@onready var manaTimer = get_node("%ManaTimer")
@onready var buff_label = get_node("%buff_label")

var mana = 100
var max_mana = 100
var draw_mana = 20

@export var deck: CardDeck
var active_buffs: Array[StatsBuff] = []

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
	#card = Card.new()
	var buff = StatsBuff.new()
	active_buffs.append(buff)
	animation_player.play("idle")
	set_deck()
	attack()
	
	set_expbar(experience, calculate_experiencecap())
	set_manabar()
	_on_hurt_box_2d_hurt(0,0,0)

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
	
	var buff:StatsBuff = StatsBuff.new()
	for i in active_buffs:
		buff.add_buff(i)
	
	
	display_buffs()
	if knife_ammo > 0:
		if not get_random_enemy() == null:
			var knife_attack = knife.instantiate()
			knife_attack.position = position
			knife_attack.target = get_random_enemy().global_position
			knife_attack.add_buff(buff)
			knife_attack.level = knife_level
			attacks.call_deferred("add_child",knife_attack)
			knife_ammo -= 1
			if knife_ammo > 0:
				knifeAttackTimer.start()
			else:
				knifeAttackTimer.stop()
	# for weapon draw
	# pick random weapon
	# use stats on attack
	
	if false and knife_ammo > 0:
		if not get_random_enemy() == null:
			var knife_attack = knife.instantiate()
			knife_attack.position = position
			knife_attack.target = get_random_enemy().global_position
			knife_attack.level = knife_level
			attacks.call_deferred("add_child",knife_attack)
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


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		print("loot")
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required-experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		#levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap
		
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func set_deck():
	var cards = CardLoader.load_cards_from_csv("res://assets/cards.csv")
	deck.set_deck(cards)

func set_manabar(set_value = 100, set_max_value = 100):
	manaBar.value = mana
	manaBar.max_value = max_mana

func _on_mana_timer_timeout() -> void:
	mana = clamp((mana - draw_mana), 0, 999.0)
	set_manabar(mana, max_mana)
	if mana < draw_mana:
		summon_hand()
		mana = max_mana
	else:
		draw_card()
	pass

func draw_card():
	if deck.has_draw():
		var card = deck.draw_card()
		var card_instance = card_scene.instantiate() as CardSprite
		card_instance.set_card(card)
		card_instance.position = Vector2(0, -80.0)
		call_deferred("add_child",card_instance)
	else:
		print("player shuffling")
		shuffle_deck()

func summon_hand():
	print(deck.get_hand())
	var buff = deck.resolve_hand()
	active_buffs.append(buff)
	print(buff)
	var debuff = Callable(self,"debuff").bind(buff)
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", debuff)
	
	
func debuff(buff: StatsBuff):
	active_buffs.erase(buff)
	pass

func shuffle_deck():
	manaTimer.stop()
	deck.shuffle()	
	#indicate player is shuffling
	
func display_buffs():
	var label_text = ""
	for buff in active_buffs:
		label_text += buff.format_stats()

	if buff_label and label_text:
		buff_label.text = label_text
	#weapons.append(weapon_add)
	#time += time_add


func _on_card_deck_shuffle_complete() -> void:
	manaTimer.start()
	draw_card()
