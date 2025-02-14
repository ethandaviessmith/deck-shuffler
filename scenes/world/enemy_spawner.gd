extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player:Player = get_tree().get_first_node_in_group(Player.GroupName)

@export var time = 0

signal changetime(time)

func _ready():
	connect("changetime",Callable(player,"change_time"))


func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while  counter < i.enemy_num:
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
	emit_signal("changetime",time)

func get_random_position():
	var vpr = get_viewport_rect().size * (Vector2(1,1) / get_viewport().get_camera_2d().zoom) * randf_range(1.05,1.2) #$randf_range(1.1,1.4)
	var pos = player.global_position
	
	return Util.get_random_edge_pos(pos, vpr)
