class_name StatusEffectManager extends Node2D

signal effect_applied(effect_name: String)
signal effect_removed(effect_name: String)
var statusEffect = preload("res://components/game/status_effect.gd")

var status_effects := {}
var procTimers = {}

@export var defaultDurations = {
	"frozen": { 1: 3.0,  2: 4.0,  3: 5.0 },
	"burnt": { 1: 5.0,  2: 6.0,  3: 7.0 },
	"poisoned": { 1: 7.0,  2: 8.0,  3: 9.0 },
	"shocked": { 1: 2.0,  2: 3.0,  3: 4.0 }
}


#func applyStatusEffect(effectType, level):
	#
	## Create an entry in statusEffects for the new effect
	#var duration = defaultDurations[effectType][level]
	#statusEffects[effectType] = {
		#"duration": duration,
		#"timer": 0,
		#"visuals": loadPulsingVisuals(effectType)
	#}
	## Start the proc timer for this effect
	#procTimers[effectType] = 0
	#get_node(effectType + "_Timer").start()

#func _process(delta):
	## Iterate over active status effects and update their timers
	#for effect in statusEffects.keys():
		#statusEffects[effect]["timer"] += delta
		#updatePulsingVisuals(effect, statusEffects[effect]["timer"], statusEffects[effect]["duration"])
#
		## If the effect duration has elapsed, remove the effect
		#if statusEffects[effect]["timer"] > statusEffects[effect]["duration"]:
			#removeStatusEffect(effect)

func _process(delta: float):
	for name in status_effects.keys():
		status_effects[name].duration -= delta
		if status_effects[name].duration <= 0:
			remove_status_effect(name)



#func _on_timer_timeout(timerName):
	## Proc the effects based on the proc timers
	#for effect in procTimers.keys():
		#procTimers[effect] += 1
		#if procTimers[effect] >= getProcFrequency(effect):
			#procTimers[effect] = 0
			#applyEffectProc(effect)


# Called when an effect's timer timeout
func _on_timer_timeout(name: String):
	apply_effect_proc(name)

# Called to apply a status effect
func apply_status_effect(name: String, duration_in_seconds: float, frequency_in_seconds: float):
	if status_effects.has(name):
		return # Already applied

	var effect_timer = Timer.new()
	effect_timer.wait_time = frequency_in_seconds
	effect_timer.one_shot = false
	effect_timer.connect("timeout", Callable(self, "_on_timer_timeout").bind(name))
	add_child(effect_timer)
	effect_timer.start()
	
	status_effects[name] = { "duration": duration_in_seconds, "timer": effect_timer }
	emit_signal("effect_applied", name)

	load_pulsing_visuals(name)

# Called each frame

# Simulate a proc frequency 
func get_proc_frequency(name: String) -> float:
	if !status_effects.has(name):
		return 0.0
	return status_effects[name].timer.wait_time

# Apply effect's impact or proc on character
func apply_effect_proc(name: String):
	# Placeholder: Apply the effect (e.g., damage over time)
	print("Effect proc applied:", name)

# Load visual effects for the status effect
func load_pulsing_visuals(name: String):
	var visual_effect = statusEffect.instantiate()
	visual_effect.name = name + "_visual"
	add_child(visual_effect)
	update_pulsing_visuals(name)

# Update visual effects (e.g., making it pulse or glow)
func update_pulsing_visuals(name: String):
	var visual_effect = get_node_or_null(name + "_visual")
	if visual_effect:
		# Modify properties to cause pulsing
		# Example: Adjust modulate, scale, etc.
		pass

# Remove a status effect
func remove_status_effect(name: String):
	if !status_effects.has(name):
		return

	var effect_data = status_effects[name]
	effect_data.timer.stop()
	remove_child(effect_data.timer)
	effect_data.timer.queue_free()
	status_effects.erase(name)
	
	var visual_effect = get_node_or_null(name + "_visual")
	if visual_effect:
		remove_child(visual_effect)
		visual_effect.queue_free()

	emit_signal("effect_removed", name)
