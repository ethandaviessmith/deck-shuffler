extends WeaponAttack

var level = 1
@export var damage = 1

@export var knockback = 10
@export var speed = 200
@export var size = 1.0

var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var hitbox: Hitbox2D = $Hitbox2D
@onready var start_audio:AudioStreamPlayer2D = $StartAudioStream
@onready var hit_audio:AudioStreamPlayer2D = $HitAudioStream

signal remove_from_array(object)

func _ready(): 
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	
	#if not buff == null:
		#hp += buff.durability
		#damage += buff.damage
		#
		#knockback *= buff.knockback
		#speed *= buff.speed
		#size *= buff.size
	#
	#scale = Vector2(0.2,0.2)
	#var tween = create_tween()
	#tween.tween_property(self,"scale", Vector2(1,1) * size, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	#tween.play()
	Util.play_with_randomized_audio(start_audio)

func _physics_process(delta):
	position += angle * speed * delta

func enemy_hit(charge = 1):
	hp -= charge
	Util.play_with_randomized_audio(hit_audio)
	if hp <= 0:
		$CollisionShape2D.call_deferred("set","disabled",true)
		_play_death_effect()


func _on_timer_timeout():
	_play_death_effect()

func _on_timer_death_timeout() -> void:
	_play_death_effect() # Replace with function body.
