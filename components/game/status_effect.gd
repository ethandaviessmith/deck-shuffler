class_name StatusEffect extends Node2D


@export var effect_stats: EffectStats

var statusEffects = {}
var procTimers = {}

signal effect_proc(effect:EffectStats)
signal effect_duration(effect:EffectStats)



func _ready() -> void:
	Log.pr("status effect node", effect_stats)
	if not effect_stats == null:
		play_animation()
		$DurationTimer.start(effect_stats.duration)
		$Timer.start(effect_stats.proc)
	pass


func play_animation():
	if not effect_stats == null:
		match(effect_stats.status_type):
			EffectStats.StatusType.NA: pass
			EffectStats.StatusType.BURN: 
				$AnimationPlayer.play("burn")
				pass
			EffectStats.StatusType.FREEZE: pass
			EffectStats.StatusType.POISON: pass
			EffectStats.StatusType.SHOCK: pass
	

func setStatusEffect(effect: EffectStats):
	effect_stats = effect

func applyStatusEffect(effectType, level):
	# Create an entry in statusEffects for the new effect
	#var duration = defaultDurations[effectType][level]
	#statusEffects[effectType] = {
		#"duration": duration,
		#"timer": 0,
		#"visuals": loadPulsingVisuals(effectType)
	#}
	## Start the proc timer for this effect
	#procTimers[effectType] = 0
	#get_node(effectType + "_Timer").start()
	pass

func _process(delta):
	pass
	## Iterate over active status effects and update their timers
	#for effect in statusEffects.keys():
		#statusEffects[effect]["timer"] += delta
		#updatePulsingVisuals(effect, statusEffects[effect]["timer"], statusEffects[effect]["duration"])
#
		## If the effect duration has elapsed, remove the effect
		#if statusEffects[effect]["timer"] > statusEffects[effect]["duration"]:
			#removeStatusEffect(effect)

func _on_timer_timeout():
	play_animation()
	effect_proc.emit(effect_stats)
	pass
	## Proc the effects based on the proc timers
	#for effect in procTimers.keys():
		#procTimers[effect] += 1
		#if procTimers[effect] >= getProcFrequency(effect):
			#procTimers[effect] = 0
			#applyEffectProc(effect)

func _on_duration_timer_timeout() -> void:
	effect_duration.emit(effect_stats)
	#signal to remove
	pass # Replace with function body.


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
