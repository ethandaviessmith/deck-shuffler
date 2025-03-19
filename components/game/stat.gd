# Stat.gd
class_name Stat extends Resource

# Enumerations for stat names and types

## Order of enums matter (int, if appending will shift all keys)
enum Name { DAMAGE, HEALTH, MOVE_SPEED, SIZE, ARMOR, WEAPON_TYPE, KNOCKBACK, COOLDOWN, ATTACK_SPEED, DRAW_SPEED, SHUFFLE_SPEED, STATUS_EFFECT, MAX_HEALTH, AMOUNT, DROPS, TRAJECTORY }
enum StatType { FLOAT, INT, MODIFIER, WEAPON_TYPE, EFFECT_STATUS_TYPE, TRAJECTORY }

# Specific enum types for complex stat categories
#enum WeaponType { NA, SWORD, BOW, STAFF }
enum EffectType  {NA, BURN, FREEZE, POISON, SHOCK}
enum Trajectory { NA, LINEAR, CURVED, ZIGZAG }

# Properties for the stat resource
@export var stat_name: Name ## Keys
@export var stat_type: StatType ## Value, modifier, or any other enum
#@export_group("Value Settings")
@export var value: float = 0.0 ## Add remove
@export var modifier: float = 0.0 ## Multiply divide

# Properties for specific enum types
#@export var weapon_type: WeaponType
@export var effect_status_type: EffectType
@export var trajectory: Trajectory
# Usage resource for managing stat usage logic

func merge(stat: Stat):
	match stat_type:
		StatType.FLOAT, StatType.INT:
			if stat.stat_type == StatType.FLOAT or stat.stat_type == StatType.INT:  ## Add
				value += stat.value
			elif stat.stat_type == StatType.MODIFIER: ## Multiply
				value *= stat.modifier
		StatType.MODIFIER:
			if modifier > 0.0 and stat.modifier > 0.0:  ## Add (remove 1 to keep base modifier multiple of x1)
				modifier = modifier + (stat.modifier - 1.0)
			else:
				modifier = lerp(modifier, stat.modifier, 0.5) ## AVG


static func new_damage(value: float) -> Stat:
	var stat = Stat.new()
	stat.stat_name = Name.DAMAGE
	stat.stat_type = StatType.FLOAT
	stat.value = value
	return stat
	
static func new_health(value: float) -> Stat:
	var stat = Stat.new()
	stat.stat_name = Name.HEALTH
	stat.stat_type = StatType.FLOAT
	stat.value = value
	return stat
	

#, usage: Resource = Usage.new()
# Convenience method to create a new Stat easily
static func create(stat_name: Name, stat_type: StatType, value: float, modifier: float = 0.0) -> Stat:
	var stat = Stat.new()
	stat.stat_name = stat_name
	stat.stat_type = stat_type
	stat.value = value
	stat.modifier = modifier
	return stat

static func get_default(name: Name):
	match name:
		Name.DAMAGE: return 0
		Name.HEALTH: return 0
		Name.MOVE_SPEED: return 1.0
		Name.SIZE: return 1.0
		Name.ARMOR: return 0.0
		Name.KNOCKBACK: return 0.0
		Name.COOLDOWN: return 1.0
		Name.ATTACK_SPEED: return 1.0
		Name.DRAW_SPEED: return 1.0
		Name.SHUFFLE_SPEED: return 1.0
		Name.MAX_HEALTH: return 0.0
		Name.AMOUNT: return 0
	return 0


# Example method to describe the stat
func describe_stat() -> String:
	var description = "Stat: %s, Type: %s, Value: %.2f, Modifier: %.2f%%" % [stat_name, get_stat_type_name(), value, modifier * 100]
	
	#description += ", " + usage.describe_usage()
	return description

func is_type(t: StatType) -> bool:
	return stat_type == t

func get_value():
	match stat_type:
		StatType.FLOAT, StatType.INT: return value
		StatType.MODIFIER: return modifier
		#StatType.WEAPON_TYPE: #return weapon_type
		StatType.EFFECT_STATUS_TYPE: return effect_status_type
		StatType.TRAJECTORY: return trajectory
		_: return null

func set_value(t: StatType, val):
	stat_type = t
	match stat_type:
		StatType.FLOAT, StatType.INT:
			value = val
		StatType.MODIFIER:
			modifier = val
		#StatType.WEAPON_TYPE:
			#weapon_type = val
		StatType.EFFECT_STATUS_TYPE:
			effect_status_type = val
		StatType.TRAJECTORY:
			trajectory = val
		_:
			return false

func get_stat_type_name() -> String:
	match stat_type:
		StatType.FLOAT: return "Float"
		StatType.INT: return "Int"
		StatType.MODIFIER: return "Modifier"
		StatType.WEAPON_TYPE: return "Weapon Type"
		StatType.EFFECT_STATUS_TYPE: return "Effect  Type"
		StatType.TRAJECTORY: return "Trajectory"
		_: return "Unknown"

static func get_stat_name(name: Name) -> String:
	match name:
		Name.DAMAGE: return "DAMAGE"
		Name.HEALTH: return "HEALTH"
		Name.MOVE_SPEED: return "MOVE_SPEED"
		Name.SIZE: return "SIZE"
		Name.ARMOR: return "ARMOR"
		Name.WEAPON_TYPE: return "WEAPON_TYPE"
		Name.KNOCKBACK: return "KNOCKBACK"
		Name.COOLDOWN: return "COOLDOWN"
		Name.ATTACK_SPEED: return "ATTACK_SPEED"
		Name.DRAW_SPEED: return "DRAW_SPEED"
		Name.SHUFFLE_SPEED: return "SHUFFLE_SPEED"
		Name.STATUS_EFFECT: return "STATUS_EFFECT"
		Name.MAX_HEALTH: return "MAX_HEALTH"
		Name.AMOUNT: return "AMOUNT"
		Name.DROPS: return "DROPS"
		Name.TRAJECTORY: return "TRAJECTORY"
	return "UNKNOWN"
