@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name Player extends CharacterBody2D

const GroupName: StringName = &"player"

var motion_input: TransformedInput = TransformedInput.new(self)

@export var card_scene = preload("res://scenes/world/card.tscn")
@export var mana = 100
@export var max_mana = 100
@export var draw_mana = 25
@export var shuffle_mana = 50

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var attacks = get_node("/root/World/Attacks")
@onready var healthBar = get_node("%HealthBar")
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var manaBar = get_node("%ManaBar")
@onready var manaTimer = get_node("%ManaTimer")
@onready var buff_label = get_node("%buff_label")

@onready var icon_draw = get_node("%StatusIconDrawSprite2D")
@onready var icon_resolve = get_node("%StatusIconResolveSprite2D")
@onready var icon_shuffle = get_node("%StatusIconShuffleSprite2D")

var deck_animation = false

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
var axe = preload("res://scenes/world/weapon_axe.tscn")
var sword = preload("res://scenes/world/weapon_sword.tscn")
@onready var knifeTimer = get_node("%KnifeTimer")
@onready var knifeAttackTimer = get_node("%KnifeAttackTimer")



func _ready() -> void:
	#card = Card.new()
	var buff = StatsBuff.new()
	active_buffs.append(StatsWeapon.create_new_weapon(Card.WeaponType.AXE))
	animation_player.play("idle")
	set_deck()
	attack()
	
	set_expbar(experience, calculate_experiencecap())
	set_manabar()
	_on_hurt_box_2d_hurt(0,0,0)

func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	if motion_input.input_direction_horizontal_axis < 0.1:
		sprite.flip_h = true
	elif motion_input.input_direction_horizontal_axis > -0.1:
		sprite.flip_h = false
	
func attack():
	if knife_level > 0:
		knifeTimer.wait_time = knife_attackspeed * ( 1 - spell_cooldown)
		if knifeTimer.is_stopped():
			knifeTimer.start()

func get_random_enemy():
	if enemy_close.size() > 0:
		return enemy_close.pick_random()
	else:
		return null


# SIGNALS
func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	if not deck_animation:
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
	
	display_buffs(active_buffs.size())
	if knife_ammo > 0:
		if not get_random_enemy() == null:
			if not buff.weapons == null:
				var weapon_buff:StatsWeapon = buff.weapons.pick_random()
				
				var weapon: WeaponHitBox
				if not weapon_buff == null:
					match weapon_buff.type:
						Card.WeaponType.DAGGER:
							weapon = knife.instantiate()
						Card.WeaponType.AXE:
							weapon = axe.instantiate()
						Card.WeaponType.SWORD:
							weapon = sword.instantiate()
						_:
							print("no weapon")
							weapon = knife.instantiate()
				else:
					weapon = knife.instantiate() #defualt to dagger in case
				weapon.position = position
				weapon.target = get_random_enemy().global_position
				weapon.add_buff(buff)
				weapon.level = knife_level
				attacks.call_deferred("add_child",weapon)
				knife_ammo -= 1
				if knife_ammo > 0:
					knifeAttackTimer.start()
				else:
					knifeAttackTimer.stop()
	
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
	icon_resolve.visible = false
	deck_animation = false
	if use_mana(draw_mana):
		pulse_sprite(icon_draw)
		draw_card()
		set_manabar(mana, max_mana)
	else:
		summon_hand()
		mana = max_mana
		# Tween mana refill
		var tween = create_tween()
		tween.tween_property(manaBar,"value",mana,2.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.play()

func use_mana(used_mana) -> bool:
	mana = clamp((mana - draw_mana), 0, 999.0)
	return mana > draw_mana

func draw_card():
	if deck.has_draw():
		var card = deck.draw_card()
		var card_instance = card_scene.instantiate() as CardSprite
		card_instance.set_card(card)
		card_instance.position = Vector2(0, -80.0)
		call_deferred("add_child",card_instance)
	else:
		print("no draw, shuffling")
		shuffle_deck()

func idle():
	animation_player.play("idle")
	deck_animation = false
	#manaTimer.start()

func summon_hand():
	icon_resolve.visible = true
	deck_animation = true
	animation_player.play("resolve")
	#manaTimer.stop()
	
	var timer_anim = Timer.new() #janky timer to make things look nice
	timer_anim.connect("timeout", Callable(self,"idle"))
	add_child(timer_anim)
	timer_anim.start(1.3)
	
	# add buffs, and remove them later
	var buff = deck.resolve_hand()
	var timer = Timer.new()
	var debuff = Callable(self,"debuff").bind(buff, timer)
	timer.connect("timeout", debuff)
	add_child(timer)
	timer.start(buff.time)
	
	active_buffs.append(buff)

func debuff(buff: StatsBuff, timer: Timer):
	active_buffs.erase(buff)
	timer.queue_free()
	pass

func display_buffs(count:int):
	var label_text = str(count) + ">"
	for buff in active_buffs:
		label_text += buff.format_stats()
	label_text += "\n" +deck.format_hand_stats()
	if buff_label and label_text:
		buff_label.text = label_text
	#weapons.append(weapon_add)
	#time += time_add


func shuffle_deck():
	manaTimer.stop()
	deck.shuffle()
	#indicate player is shuffling
	icon_shuffle.visible = true
	deck_animation = true
	animation_player.play("shuffle")

func _on_card_deck_shuffle_complete() -> void:
	manaTimer.start()
	draw_card()
	icon_shuffle.visible = false
	deck_animation = true
	print("how much longer after")

func pulse_sprite(sprite:Sprite2D):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# Restart the tween in a loop
	#tween.connect("tween_all_completed", self, "_on_tween_completed")
