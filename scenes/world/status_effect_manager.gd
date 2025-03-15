class_name StatusEffectManager extends Node2D

signal effect_proc(effect_stats: EffectStats)
signal effect_duration(effect_stats: EffectStats)

var status_effect_scene = preload("res://scenes/world/status_effect.tscn")

var effect_list: Array[EffectStats] = []

@export var defaultDurations = {
	"frozen": { 1: 3.0,  2: 4.0,  3: 5.0 },
	"burnt": { 1: 5.0,  2: 6.0,  3: 7.0 },
	"poisoned": { 1: 7.0,  2: 8.0,  3: 9.0 },
	"shocked": { 1: 2.0,  2: 3.0,  3: 4.0 }
}

func _ready() -> void:
	await owner.ready
	if owner.has_signal("effect_proc"):
		owner.effect_proc.connect(on_effect_proc)

func add_from_spell(spell: SpellStats):
	var status_effect = status_effect_scene.instantiate()
	status_effect.setStatusEffect(spell.status_effect)
	status_effect.effect_proc.connect(on_effect_proc)
	status_effect.effect_duration.connect(on_effect_duration)
	status_effect.effect_duration
	
	add_child(status_effect)
	effect_list.append(spell.status_effect)

func on_effect_proc(status_effect: EffectStats):
	effect_proc.emit(status_effect)
	pass
	
func on_effect_duration(status_effect: EffectStats):
	effect_list.erase(status_effect)
	pass
