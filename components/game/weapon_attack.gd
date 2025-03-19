class_name WeaponAttack extends Area2D

@export var hp = 1
@onready var sprite:Sprite2D = $Sprite2D
var target = Vector2.ZERO

@export var stats: Stats
## stats going to depracate these
@export var buff: AttackStats
@export var buff_spell: SpellStats


func get_stats() -> Stats:
	Log.pr("get_stats of weapon")
	return stats

func _ready(): 
	if not buff == null:
		hp += buff.durability

		scale = Vector2(0.2,0.2)
		var tween = create_tween()
		tween.tween_property(self,"scale", Vector2(1,1) * buff.size, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.play()

	if not buff_spell == null:
		match(buff_spell.status_effect.status_type):
			EffectStats.StatusType.NA: pass
			EffectStats.StatusType.BURN: 
				modulate = Util.hit_color
				pass
			EffectStats.StatusType.FREEZE: pass
			EffectStats.StatusType.POISON: pass
			EffectStats.StatusType.SHOCK: 
				modulate = Util.shock_color
				pass

func set_buff(_buff:AttackStats):
	buff = _buff
	
func add_buff(_buff:AttackStats):
	buff.add_buff(_buff)

# todo set as override array other places
func add_spell(spell: SpellStats):
	buff_spell = spell
	
func get_spells():
	return buff_spell

## Spell effect from an attack
func get_spell_effect():
	return buff_spell


func _play_death_effect():
	#await darken_sprite()
	await jitter_and_shrink()
	queue_free()
	
# Fade animation
var darken_duration = 0.5  # Duration in seconds
var shrink_duration = 0.5  # Duration in seconds
var jitter_intensity = 5   # Pixel intensity of the jitter
var jitter_duration = 0.1  # Duration for each jitter
var total_jitter_time = 0.5  # Total time to apply jitter

func darken_sprite():
	var time_passed = 0.0
	while time_passed < darken_duration:
		var factor = time_passed / darken_duration
		sprite.modulate = Color(1 - factor, 1 - factor, 1 - factor, 1)  # Darken the sprite
		var timer = get_tree().create_timer(0.016)
		await timer.timeout
		time_passed += 0.016

func jitter_and_shrink():
	var time_passed = 0.0
	var original_scale = sprite.scale
	
	while time_passed < total_jitter_time:
		var factor = time_passed / total_jitter_time
		sprite.modulate = Color(1 - factor, 1 - factor, 1 - factor, 1)  # Darken the sprite
		# Randomize the jitter effect
		sprite.position += Vector2(
			randf_range(-jitter_intensity, jitter_intensity),
			randf_range(-jitter_intensity, jitter_intensity)
		)
		# Gradually shrink the sprite
		var shrink_factor = time_passed / shrink_duration
		sprite.scale = original_scale * (1 - shrink_factor)
		var timer = get_tree().create_timer(jitter_duration)
		await timer.timeout
		sprite.position = Vector2.ZERO  # Reset position after jitter
		time_passed += jitter_duration

	# Ensure the sprite ends up at the final scale
	sprite.scale = original_scale * (1 - total_jitter_time / shrink_duration)
