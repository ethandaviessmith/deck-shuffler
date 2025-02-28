@icon("res://components/motion/2D/top-down-controller/top_down_controller.svg")
class_name Player extends Character

const GroupName: StringName = &"player"

# World
@onready var attacks = get_node("/root/World/Attacks")
@onready var deck_helper = get_node("/root/World/DeckHelper")

@onready var action_anim = $"GUI/ActionAnimationPlayer"
@onready var motion_state: FiniteStateMachine = $FiniteStateMachine;
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card_node: Node2D = $CardNode2D
@onready var gui_control = $GUI
@onready var hurtbox:Hurtbox2D = $Hurtbox2D

# GUI
@onready var healthBar = get_node("%HealthBar")
@onready var expBar = get_node("%ExperienceBar")
@onready var manaBar = get_node("%ManaBar")

@onready var draw_timer:Timer = get_node("%DrawTimer")
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
@onready var icon_weapon_list = get_node("%WeaponHFlowContainer")

# Player
@export var card_scene = preload("res://scenes/world/card.tscn")
@export var level_scene = preload("res://scenes/world/level_control.tscn")
@export var restart_scene = preload("res://scenes/world/restart_control.tscn")


#AttackNodes
var wpn_dagger = preload("res://scenes/world/weapon_dagger.tscn")
var wpn_axe = preload("res://scenes/world/weapon_axe.tscn")
var wpn_sword = preload("res://scenes/world/weapon_sword.tscn")
var wpn_scarecrow = preload("res://scenes/world/weapon_scarecrow.tscn")
var wpn_icon = preload("res://scenes/world/weapon_icon.tscn")

@export var camera: Camera2D
@export var deck: CardDeck
var active_buffs: Array[PlayerStats] = []
var next_actions: Array[Card.ACTIONS] = []
var deck_animation = false # janky anim fix for now

var motion_input: TransformedInput = TransformedInput.new(self) # TopDownController

#Player
@export var stats: PlayerStats

@export var mana = 4
@export var max_mana = 4
@export var draw_mana = 1
@export var shuffle_mana = 2
#@export var hp = 20
#var experience = 0
var experience_level = 1
var collected_experience = 0

#@export var knockback_recovery = 2
#var knockback = Vector2.ZERO
var normal_color = Color(1, 1, 1) 
var hit_color = Color(1, .7, .7)

#var movement_speed = 40.0
#var last_movement = Vector2.UP
#var time = 0
#var maxhp = 80


#UPGRADES
#var collected_upgrades = []
#var upgrade_options = []
var spell_cooldown = 0
var additional_attacks = 0

var enemy_far = [] # targets to shoot at
var enemy_near = [] # prioritized targets
var enemy_touch = [] # slowing the player

func _init():
	spawn_type = Spawn.NA

func _ready() -> void:
	lock_state.connect(_on_lock_finite_state_machine)
	animation_player.play("idle")
	
	set_guibar(expBar,experience, calculate_experiencecap())
	set_guibar(manaBar, mana, max_mana)
	set_guibar(healthBar, hp, stats.durability)
	
	set_player_stats()
	set_deck(5)
	next_action()

func set_player_stats():
	draw_timer.wait_time *= stats.draw_speed
	shuffle_timer.wait_time *= stats.shuffle_speed
	hp = stats.durability
	Log.pr("draw ",draw_timer.wait_time, ",shuffle ", shuffle_timer.wait_time)


# MOVEMENT
func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	var adjusted_speed = max(stats.speed - enemy_touch.size() * 0.2, stats.speed/2)
	velocity *= adjusted_speed
	
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity += knockback
	
	#face_target(velocity)
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

var next_weapon = 0
var weapon_num = 1


func attack():
	var buff:AttackStats = AttackStats.new()
	var weapons:Array[AttackStats] = []
	
	for active_buff in active_buffs:
		if active_buff.attacks == null: # general buff or specific weapon
			buff.add_buff(active_buff)
		else:
			weapons.append_array(active_buff.attacks)
	if weapons.size() == 0:
		weapons.append(AttackStats.new()) # Default attack, no weapons in buff
		#print("No weapons from buff - choosing default")
	display_buffs(active_buffs.size())
	
	# attacking DISABLED
	if false or not get_random_enemy() == null: # true or
		var weapon: WeaponAttack
		#Log.pr("attack",next_weapon, next_weapon + weapon_num)
		for weapon_attack in weapons.slice(next_weapon, next_weapon + weapon_num):
			match weapon_attack.weapon_type:
				AttackStats.WeaponType.DAGGER:
					weapon = wpn_dagger.instantiate()
				AttackStats.WeaponType.AXE:
					weapon = wpn_axe.instantiate()
				AttackStats.WeaponType.SWORD:
					weapon = wpn_sword.instantiate()
				AttackStats.WeaponType.SCARECROW:
					weapon = wpn_scarecrow.instantiate()
				AttackStats.WeaponType.NA:
					weapon = wpn_dagger.instantiate()
			weapon.position = position
			if not get_random_enemy() == null:
				weapon.target = get_random_enemy().global_position
			# need to add buff from card (base buff)
			weapon.set_buff(weapon_attack) # player buff
			weapon.add_buff(buff) # player buff
			attacks.call_deferred("add_child", weapon)
	next_weapon += weapon_num
	if next_weapon >= weapons.size():
		next_weapon = 0

func set_deck(count):
	deck.set_deck(deck_helper.get_starter_deck(count))

func next_action():
	if motion_state.locked:
		return # don't attack when locked
	icon_resolve.visible = false
	deck_animation = false
	
	var action = next_actions.pop_front()
	
	if action == null: # default behaviour
		if use_mana(draw_mana):
			draw_card(stats.draw_speed)
		else:
			var buff = deck.resolve_hand()
			summon_hand(buff) # add buffs, and remove them later
	else:
		match(action):
			Card.ACTIONS.DOUBLE_FINALE:
				use_mana(mana) 
				var buff = deck.resolve_hand()
				summon_hand(buff)
				summon_hand(buff)
			Card.ACTIONS.QUICK_DRAW:
				if not draw_card(stats.draw_speed / 3):
					next_actions.append(Card.ACTIONS.QUICK_DRAW) # Add another draw if you had to shuffle
			Card.ACTIONS.GAIN_ENERGY:
				draw_card(stats.draw_speed) # draw withouth spending energy
				#mana += draw_mana
			_: pass

func draw_card(draw_speed: float) -> bool:
	pulse_sprite(icon_draw)
	var has_draw = deck.has_draw()
	if has_draw:
		action_anim.play("card_draw")
		var card = deck.draw_card()
		set_next_action(card.action)
		var card_instance = card_scene.instantiate() as CardSprite
		card_instance.set_card(card, draw_speed)
		card_instance.position = Vector2(0, -43.0) # place above head
		card_node.call_deferred("add_child",card_instance)
		draw_timer.start(draw_speed)
	else:
		shuffle_deck()
	set_guibar(manaBar, mana, max_mana)
	return has_draw
	
func set_next_action(action: Card.ACTIONS):
	if not action == Card.ACTIONS.NA:
		if action == Card.ACTIONS.DOUBLE_FINALE:
			next_actions = [action] # remove other actions
		else:
			next_actions.append(action)
		# not sure how to approach mirage (maybe spell?)
		if action == Card.ACTIONS.QUICK_DRAW:
			next_actions.append(action) # add 2 quick draws

func summon_hand(buff: PlayerStats):
	mana = max_mana
	summon_animation()
	## add buffs, and remove them later
	var timer = TimeHelper.create_idle_timer(buff.time, true, true)
	var debuff = Callable(self,"debuff").bind(buff, timer)
	timer.connect("timeout", debuff)
	add_child(timer)
	
	active_buffs.append(buff)
	show_weapon_icons(buff)

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
	next_action()
	icon_shuffle.visible = false
	deck_animation = true

func use_mana(used_mana) -> bool:
	if mana >= draw_mana:
		mana = clamp((mana - draw_mana), 0, max_mana)
		return true
	return false

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

func summon_animation():
	icon_resolve.visible = true
	deck_animation = true
	animation_player.play("resolve")
	action_anim.play("resolve")
	draw_timer.stop()
	
	var tween = create_tween() # Tween mana refill
	tween.tween_property(manaBar,"value",mana,2.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	
	var timer_anim = TimeHelper.create_idle_timer(1.3, true, true)
	timer_anim.connect("timeout", Callable(self,"idle"))
	add_child(timer_anim) #janky timer to make things look nice (not cleaning up)

func calculate_stats() -> PlayerStats:
	var disp_stats = PlayerStats.new()
	disp_stats.add_buff(stats)
	for buff in active_buffs:
		disp_stats.add_player_stats(buff)
	return disp_stats

func show_weapon_icons(buff: PlayerStats):
	if not buff.attacks == null:
		for weapon in buff.attacks:
			var wpn_icon_instance = wpn_icon.instantiate() as WeaponIcon
			Log.pr("icon", weapon.weapon_type, weapon.damage)
			wpn_icon_instance.add_buff(weapon.weapon_type, buff.time)
			icon_weapon_list.call_deferred("add_child",wpn_icon_instance)

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


func _on_lock_finite_state_machine(lock: bool):
	if lock:
		motion_state.lock_state_machine()
	else:
		motion_state.unlock_state_machine()
	
func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	if not deck_animation:
		match state.name:
			"TopDownIdle":
				animation_player.play("idle")
			"TopDownWalk":
				animation_player.play("walk")

func _on_hurt_box_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	knockback = angle * knockback_amount
	hp -= clamp(damage - stats.armor, 1.0, 999.0)
	set_guibar(healthBar, hp, stats.durability)
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate", hit_color, 0.1)
	tween.tween_property(sprite, "modulate", normal_color, 0.1) 
	if hp <= 0:
		animation_player.play("die")
		next_state.emit(CharacterState.DEATH, {"target": self})
		hurtbox.disable()
		gui_control.call_deferred("add_child", restart_scene.instantiate())

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

func _on_enemy_touch_area_2d_body_entered(body: Node2D) -> void:
	if not enemy_touch.has(body):
		enemy_touch.append(body)


func _on_enemy_touch_area_2d_body_exited(body: Node2D) -> void:
	if enemy_touch.has(body):
		enemy_touch.erase(body)

func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		if not motion_state.locked:
			var gem_exp = area.collect()
			calculate_experience(gem_exp)

func _on_enemy_despawn_area_2d_body_exited(body: Node2D) -> void:
	# When off the screen wrap enemies back onto the opposite side
	
	if body.has_method("get_spawn_type"):
		if body.get_spawn_type() == Character.Spawn.WRAP:
			var vpr = get_viewport_rect().size * (Vector2(1,1) / get_viewport().get_camera_2d().zoom)
			var pos: Vector2 = Vector2(int(clamp(velocity.x, -1,1)), int(clamp(velocity.y, -1,1)))
			
			if body.position.x < global_position.x - (vpr.x/2):
				body.position.x += vpr.x*1.3
			elif body.position.x > global_position.x + (vpr.x/2):
				body.position.x -= vpr.x*1.3
			if body.position.y < global_position.y - (vpr.y/2):
				body.position.y += vpr.y*1.3
			elif body.position.y > global_position.y + (vpr.y/2):
				body.position.y -= vpr.y*1.3
				
			if body.has_method("teleport"):
				body.teleport()

#endregion
