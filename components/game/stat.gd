# Stat.gd
class_name Stat extends Resource

# Enumerations for stat names and types
enum StatName { DAMAGE, DURABILITY, SPEED, SIZE }
enum StatType { FLOAT, INT, MODIFIER, WEAPON_TYPE, EFFECT_STATUS_TYPE, TRAJECTORY }

# Specific enum types for complex stat categories
enum WeaponType { NA, SWORD, BOW, STAFF }
enum EffectStatusType { NA, POISON, BURN, FREEZE }
enum Trajectory { NA, LINEAR, CURVED, ZIGZAG }

# Properties for the stat resource
@export var stat_name: StatName ## Keys
@export var stat_type: StatType ## Value, modifier, or any other enum
@export var value: float = 0.0 ## Add remove
@export var modifier: float = 0.0 ## Multiply divide

# Properties for specific enum types
@export var weapon_type: WeaponType = WeaponType.SWORD
@export var effect_status_type: EffectStatusType = EffectStatusType.POISON
@export var trajectory: Trajectory = Trajectory.LINEAR

# Usage resource for managing stat usage logic
@export var usage: Resource

# Convenience method to create a new Stat easily
static func create(stat_name: StatName, stat_type: StatType, value: float, modifier: float = 0.0, usage: Resource = Usage.new()) -> Stat:
	var stat = Stat.new()
	stat.stat_name = stat_name
	stat.stat_type = stat_type
	stat.value = value
	stat.modifier = modifier
	stat.usage = usage
	return stat

# Example method to describe the stat
func describe_stat() -> String:
	var description = "Stat: %s, Type: %s, Value: %.2f, Modifier: %.2f%%" % [stat_name, get_stat_type_name(), value, modifier * 100]
	
	description += ", " + usage.describe_usage()
	return description

func get_value():
	match stat_type:
		StatType.FLOAT, StatType.INT:
			return value
		StatType.MODIFIER:
			return modifier
		StatType.WEAPON_TYPE:
			return weapon_type
		StatType.EFFECT_STATUS_TYPE:
			return effect_status_type
		StatType.TRAJECTORY:
			return trajectory
		_:
			return null
			
func set_value(t: StatType, val):
	stat_type = t
	match stat_type:
		StatType.FLOAT, StatType.INT:
			value = val
		StatType.MODIFIER:
			modifier = val
		StatType.WEAPON_TYPE:
			weapon_type = val
		StatType.EFFECT_STATUS_TYPE:
			effect_status_type = val
		StatType.TRAJECTORY:
			trajectory = val
		_:
			return false

func is_type(t: StatType) -> bool:
	return stat_type == t

func get_stat_type_name() -> String:
	match stat_type:
		StatType.FLOAT:
			return "Float"
		StatType.INT:
			return "Int"
		StatType.MODIFIER:
			return "Modifier"
		StatType.WEAPON_TYPE:
			return "Weapon Type"
		StatType.EFFECT_STATUS_TYPE:
			return "Effect Status Type"
		StatType.TRAJECTORY:
			return "Trajectory"
		_:
			return "Unknown"
