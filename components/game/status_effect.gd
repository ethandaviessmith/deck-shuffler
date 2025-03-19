class_name StatusEffect extends Node2D

signal effect_proc(effect:EffectStats)
signal effect_duration(effect:EffectStats)

@export var effect_stats: EffectStats

@export var stats: Stats

func _ready() -> void:
	Log.pr("status effect node", stats)
	if not stats == null:
		play_animation()
		$DurationTimer.start(stats.usage.duration * stats.usage.charges)
		$Timer.start(stats.usage.charges)

func play_animation():
	if not stats == null:
		match(stats.get_stat_value(Stat.Name.STATUS_EFFECT)):
			Stat.EffectType.NA: pass
			Stat.EffectType.BURN: 
				$AnimationPlayer.play("burn")
				pass
			Stat.EffectType.FREEZE: pass
			Stat.EffectType.POISON: pass
			Stat.EffectType.SHOCK: 
				$AnimationPlayer.play("shock")
				pass

func setStatusEffect(effect: EffectStats):
	effect_stats = effect

func _on_timer_timeout():
	play_animation()
	effect_proc.emit(stats)

func _on_duration_timer_timeout() -> void:
	effect_duration.emit(stats)
	queue_free()
