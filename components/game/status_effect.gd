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
			EffectStats.StatusType.SHOCK: 
				$AnimationPlayer.play("shock")
				pass
			
	

func setStatusEffect(effect: EffectStats):
	effect_stats = effect

func _on_timer_timeout():
	play_animation()
	effect_proc.emit(effect_stats)

func _on_duration_timer_timeout() -> void:
	effect_duration.emit(effect_stats)
	#signal to remove
	pass
