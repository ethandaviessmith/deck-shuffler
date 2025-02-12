@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name Player extends CharacterBody2D

const GroupName: StringName = &"player"

# World
@onready var attacks = get_node("/root/World/Attacks")
@onready var deck_helper = get_node("/root/World/DeckHelper")

# GUI
@onready var gui_control = $GUI
@onready var action_anim = $"GUI/ActionAnimationPlayer"
@onready var healthBar = get_node("%HealthBar")
@onready var expBar = get_node("%ExperienceBar")
@onready var manaBar = get_node("%ManaBar")

@onready var draw_timer = get_node("%DrawTimer")
@onready var shuffle_timer = get_node("%ShuffleTimer")
@onready var lblLevel = get_node("%lbl_level")
@onready var buff_label = get_node("%buff_label")

@onready var damage_label = get_node("%damage_label")
@onready var defence_label = get_node("%defence_label")
@onready var speed_label = get_node("%speed_label")
@onready var size_label = get_node("%size_label")

@onready var icon_draw = get_node("%StatusIconDrawSprite2D")
@onready var icon_resolve = get_node("%StatusIconResolveSprite2D")
@onready var icon_shuffle = get_node("%StatusIconShuffleSprite2D")

# Player
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card_node: Node2D = $CardNode2D
@export var card_scene = preload("res://scenes/world/card.tscn")
@export var level_scene = preload("res://scenes/world/level_control.tscn")
#AttackNodes
var dagger = preload("res://scenes/world/weapon_dagger.tscn")
var axe = preload("res://scenes/world/weapon_axe.tscn")
var sword = preload("res://scenes/world/weapon_sword.tscn")


@export var deck: CardDeck
var active_buffs: Array[PlayerStats] = []
var deck_animation = false # janky anim fix for now

var motion_input: TransformedInput = TransformedInput.new(self) # TopDownController

#Player
@export var stats: PlayerStats

@export var mana = 4
@export var max_mana = 4
@export var draw_mana = 1
@export var shuffle_mana = 2
@export var hp = 20
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

var enemy_near = []
var enemy_far = []

func _ready() -> void:
	animation_player.play("idle")
	
	set_guibar(expBar,experience, calculate_experiencecap())
	set_guibar(manaBar, mana, max_mana)
	set_guibar(healthBar, hp, stats.durability)
	
	set_player_stats()
	set_deck(5)
	attack()

func set_player_stats():
	draw_timer.wait_time *= stats.draw_speed
	shuffle_timer.wait_time *= stats.shuffle_speed
	print("draw ",draw_timer.wait_time, ",shuffle ", shuffle_timer.wait_time)

# MOVEMENT
func _physics_process(_delta: float) -> void:
	#motion_input.set_speed(stats.speed)
	motion_input.update()
	velocity *= stats.speed
	
	if get_last_motion().x < 0.1:
		sprite.flip_h = true
	elif get_last_motion().x > -0.1:
		sprite.flip_h = false


func get_random_enemy():
	if enemy_near.size() > 0:
		return enemy_near.pick_random()
	elif enemy_far.size() > 0:
		return enemy_far.pick_random()
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
	deck.set_deck(deck_helper.get_starter_deck(count))

func next_action():
	icon_resolve.visible = false
	deck_animation = false
	if use_mana(draw_mana):
		pulse_sprite(icon_draw)
		draw_card()
		set_guibar(manaBar, mana, max_mana)
	else:
		summon_hand()
		mana = max_mana
		var tween = create_tween() # Tween mana refill
		tween.tween_property(manaBar,"value",mana,2.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.play()

func use_mana(used_mana) -> bool:
	if mana >= draw_mana:
		mana = clamp((mana - draw_mana), 0, max_mana)
		return true
	return false

func draw_card():
	if deck.has_draw():
		action_anim.play("card_draw")
		var card = deck.draw_card()
		var card_instance = card_scene.instantiate() as CardSprite
		card_instance.set_card(card)
		card_instance.position = Vector2(0, -40.0)
		card_node.call_deferred("add_child",card_instance)
	else:
		print("no draw, shuffling")
		shuffle_deck()

func summon_hand():
	icon_resolve.visible = true
	deck_animation = true
	animation_player.play("resolve")
	action_anim.play("resolve")
	draw_timer.stop()
	
	var timer_anim = TimeHelper.create_idle_timer(1.3, true, true)
	timer_anim.connect("timeout", Callable(self,"idle"))
	add_child(timer_anim) #janky timer to make things look nice (not cleaning up)
	
	# add buffs, and remove them later
	var buff = deck.resolve_hand()
	var timer = TimeHelper.create_idle_timer(buff.time, true, true)
	var debuff = Callable(self,"debuff").bind(buff, timer)
	timer.connect("timeout", debuff)
	add_child(timer)
	
	active_buffs.append(buff)

func debuff(buff: PlayerStats, timer: Timer):
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
	action_anim.play("shuffle")

func shuffle_complete():
	draw_timer.start()
	draw_card()
	icon_shuffle.visible = false
	deck_animation = true

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required-experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		show_level_control()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_guibar(expBar,experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	# experience levels taken from survivor clone
	if experience_level < 3:
		exp_cap = experience_level
	elif experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
	return exp_cap

func apply_upgrade(card: Card):
	if card.is_card_type_stat():
		stats.add_player_stats(card.spell)
		set_player_stats()
	else:
		deck.add_card(card)
	display_buffs(111)

#region VISUALS
func show_level_control():
	gui_control.call_deferred("add_child", level_scene.instantiate())

func set_guibar(bar: TextureProgressBar, set_value = 100, set_max_value = 100, time = 0):
	if time == 0:
		bar.value = set_value
		bar.max_value = set_max_value
	else:
		var tween = create_tween() # Tween refill
		tween.tween_property(bar,"value",set_value, time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.play()

func pulse_sprite(sprite:Sprite2D):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func idle():
	animation_player.play("idle")
	print("back to idle")
	deck_animation = false
	draw_timer.start()

func calculate_stats() -> PlayerStats:
	var disp_stats = PlayerStats.new()
	disp_stats.add_buff(stats)
	for buff in active_buffs:
		disp_stats.add_player_stats(buff)
	return disp_stats

func display_weapons(disp_stats: PlayerStats):
	var weapons = []
	for attack in disp_stats.attacks:
		if not attack.weapon_type == AttackStats.WeaponType.NA:
			# display weapon icon
			
			pass
	pass

func display_buffs(count:int):
	var disp_stats = calculate_stats()
	
	#Player numbers
	damage_label.text = str(disp_stats.damage)
	defence_label.text = str(disp_stats.durability)
	speed_label.text = str(disp_stats.speed)
	size_label.text = str(disp_stats.size)
		
	#Debug text
	var label_text = str(count) + ">"
	for buff in active_buffs:
		label_text += buff.format_stats()
	label_text += "\n" +deck.format_hand_stats() #"\n" +
	if buff_label and label_text:
		buff_label.text = label_text
		
		
#endregion

#region SIGNALS
func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	if not deck_animation:
		match state.name:
			"TopDownIdle":
				animation_player.play("idle")
			"TopDownWalk":
				animation_player.play("walk")

func _on_hurt_box_2d_hurt(damage: Variant, angle: Variant, knockback: Variant) -> void:
	print("player hurt", damage)
	hp -= clamp(damage - stats.armor, 1.0, 999.0)
	set_guibar(healthBar, hp, stats.durability)
	if hp <= 0:
		pass#death()

func _on_draw_timer_timeout() -> void:
	next_action()

func _on_attack_timer_timeout() -> void:
	attack()

func _on_card_deck_shuffle_complete() -> void:
	shuffle_complete()

func _on_enemy_near_area_body_entered(body: Node2D) -> void:
	if not enemy_near.has(body):
		enemy_near.append(body)

func _on_enemy_near_area_body_exited(body: Node2D) -> void:
	if enemy_near.has(body):
		enemy_near.erase(body)

func _on_enemy_far_area_body_entered(body: Node2D) -> void:
	if not enemy_far.has(body):
		enemy_far.append(body)

func _on_enemy_far_area_body_exited(body: Node2D) -> void:
	if enemy_far.has(body):
		enemy_far.erase(body)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
#endregion
