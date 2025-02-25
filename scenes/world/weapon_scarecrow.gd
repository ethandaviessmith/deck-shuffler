extends WeaponAttack

var level = 1
@export var damage = 1

@export var knockback = 100
@export var speed = 200
@export var size = 1.0


var angle = Vector2.ZERO

var movement_duration = 0.2
var time_moving = 0.0
var normal_color = Color(1, 1, 1) 
var hit_color = Color(1, .7, .7)

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var hit_audio:AudioStreamPlayer2D = $HitAudioStream
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var anim_effect: AnimationPlayer = $EffectAnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready(): 
	#angle = global_position.direction_to(target)
	#rotation = angle.angle()
	
	anim.play("idle")
	anim.animation_set_next("thump","idle")
	anim_effect.animation_set_next("thump","blank")
	
	if not buff == null:
		hp += buff.durability
		damage += buff.damage
		
		knockback *= buff.knockback
		speed *= buff.speed
		size *= buff.size
		$FadeTimer.start(buff.fade)

	#play_with_randomized_audio(start_audio)

func _physics_process(delta):
	if time_moving <= movement_duration:
		position += angle * speed * delta
		time_moving += delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		$CollisionShape2D.call_deferred("set","disabled",true)
		_play_death_effect()

func _on_hurtbox_2d_hurt(damage: Variant, angle: Variant, knockback_amount: Variant) -> void:
	knockback = angle * knockback_amount
	hp -= clamp(damage, 1.0, 999.0)
	
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate", hit_color, 0.1)
	tween.tween_property(sprite, "modulate", normal_color, 0.1) 
	if hp <= 0:
		pass#death()

func _on_timer_timeout():
	anim.play("thump")
	anim_effect.play("thump")
	Util.play_with_randomized_audio(hit_audio)

func _on_fade_timer_timeout() -> void:
	_play_death_effect()
