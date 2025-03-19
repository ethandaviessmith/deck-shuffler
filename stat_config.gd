class_name Stats extends Resource

@export var guid: String = "res_" + str(UUID.new())
@export var stats: Dictionary[Stat.Name, Stat]
# This is a status effect (eefect has a usage)
@export var usage: Usage

func has(name: Stat.Name) -> bool:
	return stats.has(name)

func get_stat(name: Stat.Name) -> Stat:
	return stats.get(name)
	
func get_stat_value(name: Stat.Name):
	if has(name):
		return stats.get(name).get_value()
	else:
		Log.pr("get stat", Stat.get_stat_name(name), " failed because it didn't exist in", stats.keys())

func add_stat(stat: Stat):
	var old_stat = stats.get(stat.stat_name)
	if not old_stat == null:
		stat.merge(old_stat)
	stats.set(stat.stat_name, stat)
	pass

func add_stats(s: Dictionary[Stat.Name, Stat]):
	for stat in s.values():
		add_stat(stat)


## returns remaining charges
func charge_limit(drain: int) -> int:
	if usage == null: return 0
	if usage.charges == 0: return 0
	usage.charges = clampi(usage.charges - 1, 0, 100)
	return usage.charges

# into a weapon stat
# read on hit and passed into enemy (take initial damage)
# list<Stats(dict, usage)> 
# take damage over time (charge duration)
