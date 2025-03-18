class_name Usage extends Resource

# Enumerations for types of usage
enum UsageType { PERMANENT, CHARGES, DURATION, SIGNAL_NAME }

# Properties for the usage resource
@export var usage_type: UsageType = UsageType.PERMANENT
@export var charges: int = 0         # Only used if usage_type is CHARGES
@export var duration: float = 0.0    # Only used if usage_type is DURATION
@export var signal_name: String = "" # Only used if usage_type is SIGNAL_NAME

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
