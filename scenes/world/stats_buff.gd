class_name StatsBuff extends Resource

@export var hp: int = 1 #add health
@export var speed: float = 50 #faster walk
@export var damage: float = 0.5 # damage per shot
@export var knockback_amount: float = 50 #enemy knockback
@export var attack_size: float = .5 #size of shot
@export var amount: float = 1.0
@export var weapons: Array[StatsWeapon] = []
@export var time: float = 4

func add_buff(add_buff:StatsBuff):
	return buff(add_buff.hp, add_buff.speed, add_buff.damage, add_buff.knockback_amount, add_buff.attack_size, add_buff.amount, add_buff.weapons, add_buff.time)

func buff(hp_add: int, speed_add: float, damage_add: float, knockback_add: float, attack_size_add: float, amount_add: float, weapon_add: Array[StatsWeapon], time_add: float):
	hp += hp_add
	speed += speed_add
	damage += damage_add
	knockback_amount += knockback_add
	attack_size += attack_size_add
	amount += amount_add
	weapons.append(weapon_add)
	time += time_add
	return self

func format_stats() -> String:
	var stats = ">h:" + format_value(hp) + ",s:" + format_value(speed) +",d:" + format_value(damage) +",k:" + format_value(knockback_amount) +",a:" + format_value(attack_size) +",t:" + format_value(time)
	#var stats = "H:%s,S:%s,D:%s,K:%s,A:%s,T:%s" % [format_value(hp),format_value(speed),format_value(damage),format_value(knockback_amount),format_value(attack_size),format_value(amount),format_value(time)]
	return stats

func format_value(value: float) -> String:
	# Convert to integer if there's no decimal part
	if value == int(value):
		return str(int(value))
	return str(value)
