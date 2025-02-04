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
@onready var deck_helper = get_node("/root/World/DeckHelper")

@onready var healthBar = get_node("%HealthBar")
@onready var expBar = get_node("%ExperienceBar")
@onready var manaBar = get_node("%ManaBar")

@onready var draw_timer = get_node("%DrawTimer")
@onready var lblLevel = get_node("%lbl_level")
@onready var buff_label = get_node("%buff_label")

@onready var icon_draw = get_node("%StatusIconDrawSprite2D")
@onready var icon_resolve = get_node("%StatusIconResolveSprite2D")
@onready var icon_shuffle = get_node("%StatusIconShuffleSprite2D")

var deck_animation = false

@export var deck: CardDeck
var active_buffs: Array[PlayerStats] = []

#Player
@export var stats: PlayerStats
var hp = 80
var experience = 0
var experience_level = 1
var collected_experience = 0

#var movement_speed = 40.0
#var last_movement = Vector2.UP
#var time = 0
#var maxhp = 80


#UPGRADES
#var collected_upgrades = []
#var upgrade_options = []
var spell_cooldown = 0
var additional_attacks = 0

var enemy_close = []

#AttackNodes
var dagger = preload("res://scenes/world/weapon_dagger.tscn")
var axe = preload("res://scenes/world/weapon_axe.tscn")
var sword = preload("res://scenes/world/weapon_sword.tscn")


func _ready() -> void:
	var buff = StatsBuff.new()
	active_buffs.append(StatsWeapon.create_new_weapon(Card.WeaponType.AXE))
	animation_player.play("idle")
	draw_timer.wait_time = stats.draw_speed
	
	set_deck(5)
	attack()
	
	set_expbar(experience, calculate_experiencecap())
	set_manabar()
	_on_hurt_box_2d_hurt(0,0,0)

# MOVEMENT
func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	if motion_input.input_direction_horizontal_axis < 0.1:
		sprite.flip_h = true
	elif motion_input.input_direction_horizontal_axis > -0.1:
		sprite.flip_h = false


func get_random_enemy():
	if enemy_close.size() > 0:
		return enemy_close.pick_random()
	else:
		return null

func attack():
	var buff:AttackStats = AttackStats.new()
	var weapons:Array[AttackStats] = []
	for active_buff in active_buffs:
		buff.add_buff(active_buff)
		if not active_buff.attacks == null:
			weapons.append_array(active_buff.attacks)
	if weapons.size() == 0:
		weapons.append(AttackStats.new()) # Default attack, no weapons in buff
		print("No weapons from buff - choosing default")
	display_buffs(active_buffs.size())
	
	if not get_random_enemy() == null:
		var random_attack: AttackStats = weapons.pick_random()
		var weapon: WeaponHitBox
		
		match random_attack.weapon_type:
			AttackStats.WeaponType.DAGGER:
				weapon = dagger.instantiate()
			AttackStats.WeaponType.AXE:
				weapon = axe.instantiate()
			AttackStats.WeaponType.SWORD:
				weapon = sword.instantiate()
			_:
				print("no weapon")
				weapon = dagger.instantiate() # needed?
		weapon.position = position
		weapon.target = get_random_enemy().global_position
		
		weapon.add_buff(buff as AttackStats)
		attacks.call_deferred("add_child", weapon)
	#knifeTimer.wait_time = nife_attackspeed * ( 1 - spell_cooldown)

func set_deck(count):
	var cards:Array[Card] = []
	for i in count:
		cards.append(deck_helper.get_random_card())
	deck.set_deck(cards)

func set_manabar(set_value = 100, set_max_value = 100):
	manaBar.value = mana
	manaBar.max_value = max_mana

func next_action():
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

func shuffle_deck():
	draw_timer.stop()
	deck.shuffle()
	#indicate player is shuffling
	icon_shuffle.visible = true
	deck_animation = true
	animation_player.play("shuffle")

func shuffle_complete():
	draw_timer.start()
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

func idle():
	animation_player.play("idle")
	deck_animation = false
	#manaTimer.start()

func display_buffs(count:int):
	var label_text = str(count) + ">"
	for buff in active_buffs:
		label_text += buff.format_stats()
	label_text += "\n" +deck.format_hand_stats()
	if buff_label and label_text:
		buff_label.text = label_text
	#weapons.append(weapon_add)
	#time += time_add

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

#region SIGNALS
func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	if not deck_animation:
		match state.name:
			"TopDownIdle":
				animation_player.play("idle")
			"TopDownWalk":
				animation_player.play("walk")

func _on_hurt_box_2d_hurt(damage: Variant, angle: Variant, knockback: Variant) -> void:
	#print("player hurt")
	hp -= clamp(damage - stats.armor, 1.0, 999.0)
	healthBar.max_value = stats.durability
	healthBar.value = hp
	if hp <= 0:
		pass#death()

func _on_draw_timer_timeout() -> void:
	next_action()

func _on_attack_timer_timeout() -> void:
	attack()

func _on_card_deck_shuffle_complete() -> void:
	shuffle_complete()

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
#endregion
