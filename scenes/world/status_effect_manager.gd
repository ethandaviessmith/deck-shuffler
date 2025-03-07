class_name StatusEffectManager extends Node2D

@export var defaultDurations = {
	"frozen": { 1: 3.0,  2: 4.0,  3: 5.0 },
	"burnt": { 1: 5.0,  2: 6.0,  3: 7.0 },
	"poisoned": { 1: 7.0,  2: 8.0,  3: 9.0 },
	"shocked": { 1: 2.0,  2: 3.0,  3: 4.0 }
}


var statusEffect = preload("res://components/game/status_effect.gd")

# Function to instantiate the scene and obtain references
func instantiateStatusEffectVisuals():
	var instance = statusEffect.instance()
	# Get references to the nodes within the instantiated scene
	add_child(instance)


var statusEffects = {}
var procTimers = {}

func applyStatusEffect(effectType, level):
	# Create an entry in statusEffects for the new effect
	var duration = defaultDurations[effectType][level]
	statusEffects[effectType] = {
		"duration": duration,
		"timer": 0,
		"visuals": loadPulsingVisuals(effectType)
	}
	# Start the proc timer for this effect
	procTimers[effectType] = 0
	get_node(effectType + "_Timer").start()

func _process(delta):
	# Iterate over active status effects and update their timers
	for effect in statusEffects.keys():
		statusEffects[effect]["timer"] += delta
		updatePulsingVisuals(effect, statusEffects[effect]["timer"], statusEffects[effect]["duration"])

		# If the effect duration has elapsed, remove the effect
		if statusEffects[effect]["timer"] > statusEffects[effect]["duration"]:
			removeStatusEffect(effect)

func _on_timer_timeout(timerName):
	# Proc the effects based on the proc timers
	for effect in procTimers.keys():
		procTimers[effect] += 1
		if procTimers[effect] >= getProcFrequency(effect):
			procTimers[effect] = 0
			applyEffectProc(effect)

func getProcFrequency(effectType):
	pass

func applyEffectProc(effectType):
	pass

func loadPulsingVisuals(effectType):
	pass
	# Load and return the pulsing visuals specific to the effect (from AnimatedSprite or other visual nodes)

func updatePulsingVisuals(effectType, timer, duration):
	pass
	# Update the pulsing visuals based on the timer and effect duration

func removeStatusEffect(effectType):
	pass
	# Remove the effect from statusEffects and clean up its visuals
