# EffectStats.gd
extends Resource

class_name EffectStats


enum StatusType {NA, BURN, FREEZE, POISON, SHOCK}

@export var defaultDurations = {
	StatusType.FREEZE: { 1: 3.0,  2: 4.0,  3: 5.0 },
	StatusType.BURN: { 1: 5.0,  2: 6.0,  3: 7.0 },
	StatusType.POISON: { 1: 7.0,  2: 8.0,  3: 9.0 },
	StatusType.SHOCK: { 1: 2.0,  2: 3.0,  3: 4.0 }
}

@export var status_type: StatusType = StatusType.NA ## Effect type
@export var duration: float = 0.0 ## How long it lasts
@export var proc: float = 0.0 ## How often it procs

@export var damage: int = 0
