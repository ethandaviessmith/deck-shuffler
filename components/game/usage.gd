class_name Usage extends Resource

# Enumerations for types of usage
enum UsageType { PERMANENT, CHARGES, DURATION, SIGNAL_NAME }
enum WeaponType { NA, DAGGER, SWORD, AXE, BOW, ROCK, SCARECROW }

# Properties for the usage resource
@export var usage_type: UsageType = UsageType.PERMANENT
@export var charges: int = 0         # Only used if usage_type is CHARGES
@export var duration: float = 0.0    # Only used if usage_type is DURATION
@export var signal_name: String = "" # Only used if usage_type is SIGNAL_NAME
@export var weapon_type: WeaponType = WeaponType.NA ## Weapons from cards to being thrown by player

# Method to describe the usage
func describe_usage() -> String:
	match usage_type:
		UsageType.PERMANENT:
			return "Usage: Permanent"
		UsageType.CHARGES:
			return "Usage: Charges (%d)" % charges
		UsageType.DURATION:
			return "Usage: Duration (%.2f seconds)" % duration
		UsageType.SIGNAL_NAME:
			return "Usage: Signal Name (%s)" % signal_name
		_:
			return "Unknown Usage"

static func get_weapon_type(weapon_type:WeaponType) -> String:
	match weapon_type:
		WeaponType.DAGGER:
			return "Dagger"
		WeaponType.AXE:
			return "Axe"
		WeaponType.SWORD:
			return "Sword"
	return "NA"

func get_weapon_type_name() -> String:
	return Usage.get_weapon_type(self.weapon_type)
