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
@onready var hit_audio:AudioStreamPlayer2D = $HitAudioStream
@onready var summon_audio:AudioStreamPlayer2D = $SummonAudioStream

# GUI
@onready var healthBar = get_node("%HealthBar")
@onready var expBar = get_node("%ExperienceBar")
@onready var manaBar = get_node("%ManaBar")

@onready var draw_timer:Timer = get_node("%DrawTimer")
@onready var shuffle_timer = get_node("%ShuffleTimer")
@onready var lblLevel = get_node("%lbl_level")
@onready var buff_label = get_node("%buff_label")

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
# AttackNodes
var wpn_dagger = preload("res://scenes/world/weapon_dagger.tscn")
var wpn_axe = preload("res://scenes/world/weapon_axe.tscn")
var wpn_sword = preload("res://scenes/world/weapon_sword.tscn")
var wpn_scarecrow = preload("res://scenes/world/weapon_scarecrow.tscn")
var wpn_icon = preload("res://scenes/world/weapon_icon.tscn")

var wpn_default:Stats = preload("res://components/game/stat_weapon.tres")

@export var CAN_ATTACK: bool = true
@export var camera: Camera2D
@export var deck: CardDeck

var active_buffs: Array = []
var wpn_list: Array = []
var wpn_icons: Dictionary = {}
var next_weapon = 0
var weapon_num = 1
var weapon_list = []
var next_actions: Array[Card.ACTIONS] = []
var deck_animation = false ## janky anim fix for now
var motion_input: TransformedInput = TransformedInput.new(self) ## TopDownController

#Player

#@export var stats: PlayerStats
@export var mana = 3
@export var max_mana = 3
@export var draw_mana = 1
@export var shuffle_mana = 2

var experience_level = 1
var collected_experience = 0

var enemy_far = [] # targets to shoot at
var enemy_near = [] # prioritized targets
var enemy_touch = [] # slowing the player


func _init():
	spawn_type = Spawn.NA

func _ready() -> void:
	stats = preload("res://components/game/stat_player.tres").duplicate() # don't know why I need to load it, adding via editor being weird
	super()
	#assert(not stats == null, "Stats must be defined in a character class")
	lock_state.connect(_on_lock_finite_state_machine)
	animation_player.play("idle")
	
	set_player_stats()
	set_guibar(expBar,experience, calculate_experiencecap())
	set_guibar(manaBar, mana, max_mana)
	set_guibar(healthBar, stats.get_stat_value(Stat.Name.HEALTH), stats.get_stat_value(Stat.Name.MAX_HEALTH))
	_set_deck(5)
	next_action()

func set_player_stats():
	draw_timer.wait_time = stats.get_stat_value(Stat.Name.DRAW_SPEED)
	shuffle_timer.wait_time = stats.get_stat_value(Stat.Name.SHUFFLE_SPEED)
	#hp = stats.get_stat_value(Stat.Name.HEALTH)
	Log.pr("draw ",draw_timer.wait_time, ",shuffle ", shuffle_timer.wait_time)

func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	var adjusted_speed = max(stats.get_stat_value(Stat.Name.MOVE_SPEED) - enemy_touch.size() * 0.2, stats.get_stat_value(Stat.Name.MOVE_SPEED)/2)
	velocity *= adjusted_speed
	
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	velocity += knockback
	
	if motion_input.previous_input_direction.x > 0.1:
		sprite.flip_h = false
	elif motion_input.previous_input_direction.x < -0.1:
		sprite.flip_h = true

#region ACTIONS
func attack():
	var buff:Stats = Stats.new()
	#var spells:Array[SpellStats] =[]
	#var weapons:Array[AttackStats] = []
	var debuff := false
	
	wpn_list
	
	for active_buff in active_buffs:
		#if active_buff is PlayerStats:
		buff.add_stats(active_buff.stats)
			#if not active_buff.spells == null and active_buff.spells.size() > 0:
				#spells.append_array(active_buff.spells)
		#else:
			#pass#weapons.append(active_buff)
	if wpn_list.size() == 0:
		#weapons.append(AttackStats.new()) 
		wpn_list.append(wpn_default)
		debuff = true
	Log.pr("attacks", active_buffs, next_weapon)
	
	#hand_buff.resolve()
	
	if CAN_ATTACK and not get_random_enemy() == null:
		var weapon: WeaponAttack
		Log.pr("weapons",next_weapon, next_weapon + weapon_num, wpn_list)
		for weapon_attack:Stats in wpn_list.slice(next_weapon, next_weapon + weapon_num):
			match weapon_attack.usage.weapon_type:
				Usage.WeaponType.DAGGER:
					weapon = wpn_dagger.instantiate()
				Usage.WeaponType.AXE:
					weapon = wpn_axe.instantiate()
				Usage.WeaponType.SWORD:
					weapon = wpn_sword.instantiate()
				Usage.WeaponType.SCARECROW:
					weapon = wpn_scarecrow.instantiate()
				Usage.WeaponType.NA:
					weapon = wpn_dagger.instantiate()
			weapon.position = position
			if not get_random_enemy() == null:
				weapon.target = get_random_enemy().global_position
			# need to add buff from card (base buff)
			#weapon.set_buff(weapon_attack) ## buff from the weapon card
			#weapon.add_buff(buff) ## player buff
			
			weapon.stats = weapon_attack.duplicate()
			weapon.stats.add_stats(buff.stats)
			
			#for spell in spells:
				#weapon.add_spell(spell)
			attacks.call_deferred("add_child", weapon)
			charge_limit(weapon_attack, 1)
	
	if debuff and active_buffs.size() > next_weapon:
		var active_buff = active_buffs[next_weapon]
		charge_limit(active_buff, 1)
		
	next_weapon += weapon_num
	if next_weapon >= wpn_list.size():
		next_weapon = 0


func charge_limit(attack, amount: int):
	var limit = attack.charge_limit(amount)
	Log.pr("summon", "charge check", limit)
	if wpn_icons.has(attack.guid):
		var icon = wpn_icons[attack.guid]
		if is_instance_valid(icon):
			if limit == 0:
				icon.remove_buff()
				wpn_icons.erase(attack)
				active_buffs.erase(attack)
				wpn_list.erase(attack)
				Log.pr("summon", "remove buff", attack)
			icon.set_charge(limit)

func next_action():
	if motion_state.locked:
		return # don't attack when locked
	icon_resolve.visible = false
	deck_animation = false
	
	var action = next_actions.pop_front()
	
	if action == null: # default behaviour
		if use_mana(draw_mana):
			draw_card(stats.get_stat_value(Stat.Name.DRAW_SPEED))
		else:
			var buff = deck.resolve_hand()
			resolve_hand(buff) # add buffs, and remove them later
	else:
		match(action):
			Card.ACTIONS.DOUBLE_FINALE:
				use_mana(mana) 
				var buff = deck.resolve_hand()
				resolve_hand(buff)
				resolve_hand(buff)
			Card.ACTIONS.QUICK_DRAW:
				if not draw_card(stats.get_stat_value(Stat.Name.DRAW_SPEED) / 3):
					next_actions.append(Card.ACTIONS.QUICK_DRAW) # Add another draw if you had to shuffle
			Card.ACTIONS.GAIN_ENERGY:
				draw_card(stats.get_stat_value(Stat.Name.DRAW_SPEED)) # draw withouth spending energy
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

func resolve_hand(buff: Array):
	mana = max_mana
	summon_animation()
	
	var player_buff:Stats = buff[0]
	var weapons:Array[Stats] = buff[1]
	
	for weapon:Stats in weapons:
		add_weapon_icon(weapon)
	add_weapon_icon(player_buff)
	#active_buffs.append_array(weapons)
	active_buffs.append(player_buff)
	wpn_list.append_array(weapons)

func summon_hand(buff: PlayerStats):
	mana = max_mana
	summon_animation()

	var player_buff:PlayerStats = PlayerStats.new()
	var weapons:Array[AttackStats] = []
	var spells:Array[SpellStats] = []
	var c = 0
	for attack in buff.attacks:
		if attack is AttackStats and not attack.weapon_type == AttackStats.WeaponType.NA:
			weapons.append(attack)
			add_weapon_icon(attack)
			c += 1
		else:
			player_buff.add_buff(attack)
	for spell in buff.spells:
		if spell is SpellStats and not spell.status_effect == null:
			player_buff.spells.append(spell)
	add_weapon_icon(player_buff)
	c += 1
	active_buffs.append_array(weapons)
	active_buffs.append(player_buff)
	Log.pr("summon", c, active_buffs.size())


func shuffle_deck():
	draw_timer.stop()
	deck.shuffle()
	
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
#endregion


func get_random_enemy():
	if enemy_near.size() > 0:
		return enemy_near.pick_random()
	elif enemy_far.size() > 0:
		return enemy_far.pick_random()
	else:
		return null

func _set_deck(count):
	deck.set_deck(deck_helper.get_starter_deck(count))

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
	if experience_level < 5:
		exp_cap = experience_level + 3
	elif experience_level < 20:
		exp_cap = experience_level * 3
	elif experience_level < 40:
		exp_cap + 95 * (experience_level-19) * 5
	else:
		exp_cap = 255 + (experience_level-39) * 8
	return exp_cap

func apply_upgrade(card: Card):
	if card.is_card_type_stat():
		#stats.add_player_stats(card.spell)
		stats.add_stats(card.stats.values())
		## TODO have not tested this at all
		set_player_stats()
	else:
		deck.add_card(card)


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
	icon_resolve.visible = false
	draw_timer.start()

func summon_animation():
	icon_resolve.visible = true
	deck_animation = true
	animation_player.play("resolve")
	action_anim.play("resolve")
	draw_timer.stop()
	Util.play_with_randomized_audio(summon_audio)
	
	var tween = create_tween() # Tween mana refill
	tween.tween_property(manaBar,"value",mana,2.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	
	var timer_anim = TimeHelper.create_idle_timer(animation_player.current_animation_length, true, true)
	timer_anim.connect("timeout", Callable(self,"idle"))
	add_child(timer_anim) #janky timer to make things look nice (not cleaning up)

func add_weapon_icon(stat_config):
	var icon_type = AttackStats.WeaponType.NA
	var wpn_icon_instance = wpn_icon.instantiate() as WeaponIcon
	#if stat_config is AttackStats:
		#icon_type = stat_config.weapon_type
	if stat_config is Stats:
		if stat_config.usage:
			icon_type = stat_config.usage.weapon_type
			wpn_icon_instance.set_charge(stat_config.usage.charges)
		else:
			icon_type = Usage.WeaponType.NA
	wpn_icon_instance.add_buff(icon_type)
	Log.pr("summon", "weapon_icon", stat_config, stat_config.guid)
	
	## todo sometimes weapons have 0 charge_limit?
	
	icon_weapon_list.call_deferred("add_child", wpn_icon_instance)
	wpn_icons[stat_config.guid] = wpn_icon_instance

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


func _on_hurtbox_2d_hurt(hurt_stats: Stats, angle: Variant) -> void:
	if hurt_stats.has(Stat.Name.DAMAGE):
		take_damage(hurt_stats.get_stat_value(Stat.Name.DAMAGE))
	if hurt_stats.has(Stat.Name.KNOCKBACK):
		knockback = angle * hurt_stats.get_stat_value(Stat.Name.KNOCKBACK)

	set_guibar(healthBar, stats.get_stat_value(Stat.Name.HEALTH), stats.get_stat_value(Stat.Name.MAX_HEALTH))
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate", Util.hit_color, 0.4)
	tween.tween_property(sprite, "modulate", Util.normal_color, 0.3)
	
	Util.play_with_randomized_audio(hit_audio)
	if stats.get_stat_value(Stat.Name.HEALTH) <= 0:
		next_state.emit(CharacterState.DEATH)
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
