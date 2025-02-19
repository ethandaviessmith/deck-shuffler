class_name CardSprite extends Sprite2D


var fade_mat: ShaderMaterial

@onready var label_node = get_node("%CardLabel")
const col = 0.8 # give hue to cards by type

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
	draw_speed = speed

func _ready():
	fade_mat = get_material()
	if draw_card:
		show_card()
	

func show_card():
	if label_node:
		label_node.text = name
	
	if not card == null:
		match card.card_type:
			Card.CardType.ATTACK:
				#self.modulate = Color(1, col, col) 
				#fade_mat.set_shader_parameter("reveal_progress", Vector4(1.0, col, col, 1.0))
				pass
	
	if draw_card:
		# Initialize transparency and scale for appearance
		modulate = Color(modulate.r, modulate.g, modulate.b, 0.3)
		fade_mat.set_shader_parameter("show", true)
		fade_mat.set_shader_parameter("reveal_progress", 0.0)
		#fade_mat.set_shader_parameter("wipe_amount", 1.0)

		var tween = create_tween() # Fade in effect with sweep in
		tween.tween_property(fade_mat, "shader_parameter/reveal_progress", 1.0, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		#tween.tween_property(self.material, "shader_parameter/wipe_amount", 0.0, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		#tween.tween_property(self, "modulate:a", 1, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.tween_callback(Callable(self, "hide_card")).set_delay(draw_speed)
	

func hide_card():
	if label_node:
			label_node.text = ""
	# Create a tween for hide animation
	fade_mat.set_shader_parameter("show", false)
	fade_mat.set_shader_parameter("reveal_progress", 0.0)
	modulate = Color(modulate.r, modulate.g, modulate.b, 1)
	
	var tween = create_tween()
	# Fade out and shrink (sweep out) effect
	#tween.tween_property(self, "modulate:a", 0, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	#tween.tween_property(self.material, "shader_parameter/wipe_amount", 1.0, draw_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fade_mat, "shader_parameter/reveal_progress", 1.0, draw_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "queue_free"))

func _on_timer_timeout() -> void:
	pass # Replace with function body.
