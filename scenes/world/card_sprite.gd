class_name CardSprite extends Sprite2D


var fade_mat: ShaderMaterial

@onready var label_node = get_node("%CardLabel")
const col = 0.8 # give hue to cards by type
var tween
var card: Card
var draw_card: bool = true
@export var draw_speed: float = 1.0

func set_card(_card: Card, speed: float = 1.0):
	if not _card == null:
		card = _card
		
		name = card.name
		
		if card.texture:
			texture = card.texture
		match card.card_type:
			Card.CardType.ATTACK:
				self.modulate = Color(1, col, col) 
			Card.CardType.SPELL:
				self.modulate = Color(col, 1, col)
			Card.CardType.ACTION:
				self.modulate = Color(col, col, 1)
			_:
				self.modulate = Color(1, 1, 1)  # Normal other
	else:
		print("card is null")
	draw_speed = speed/2.01 # prevents new animation starting before queue_free (otherwise tweens are messing up)

func _ready():
	fade_mat = get_material()
	show_card()

func show_card():
	if label_node:
		label_node.text = name
	
	if draw_card:
		# Initialize transparency and scale for appearance
		modulate = Color(modulate.r, modulate.g, modulate.b, 0.3)
		fade_mat.set_shader_parameter("show", true)
		fade_mat.set_shader_parameter("reveal_progress", 0.0)
		#Log.pr("start draw", card.name, draw_speed)
		
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(fade_mat, "shader_parameter/reveal_progress", 1.0, draw_speed)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.set_parallel()
		#tween.tween_property(self, "modulate:a", 1, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		#tween.tween_callback(Callable(self, "hide_card")).set_delay(draw_speed)
		$Timer.start(draw_speed)
		#Log.pr("start draw",tween)
		
	

func hide_card():
	if not draw_card:
		#Log.pr("queue_free", card.name)
		queue_free()
	else:
		draw_card = false
		if label_node:
				label_node.text = ""
		# Create a tween for hide animation
		get_material().set_shader_parameter("show", false)
		get_material().set_shader_parameter("reveal_progress", 0.0)
		modulate = Color(modulate.r, modulate.g, modulate.b, 1)
		#Log.pr("hide draw", card.name, get_material().get_shader_parameter("reveal_progress"))
		
		if tween:
			tween.kill()
		tween = create_tween()
		#tween.tween_property(self, "modulate:a", 0, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_property(get_material(), "shader_parameter/reveal_progress", 1.0, draw_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		#tween.tween_callback(queue_free)
		$Timer.start(draw_speed)

func _on_timer_timeout() -> void:
	hide_card()
