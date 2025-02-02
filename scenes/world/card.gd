class_name Card extends Sprite2D

@export var suit: String
@export var number: int
@export var fade_duration: float = 1.0  # Default fade duration

var fade_mat: ShaderMaterial

func _ready():
	fade_mat = get_material()
	#ShaderMaterial = load("res://shaders/CardMaterial.tres")
	randomize_card()
	print(suit)
	show_card()

func show_card():
	# Initialize transparency and scale for appearance
	modulate = Color(modulate.r, modulate.g, modulate.b, 0)
	scale = Vector2(0, 0)

	# Create a tween for show animation
	var tween = create_tween()

	# Fade in effect with sweep in
	tween.tween_property(
		self, "modulate:a", 1, fade_duration
	).as_relative().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self, "scale", Vector2(1, 1), fade_duration
	).as_relative().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "hide_card"))
	
	
	# Configure shader parameters for wipe effect
	fade_mat.set_shader_parameter("wipe_amount", 0.0)
	# Create a tween for show animation
	tween.tween_property(
		self.material, "shader_parameter/wipe_amount", 1.0, fade_duration
	).as_relative().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func hide_card():
	# Create a tween for hide animation
	var tween = create_tween()

	# Fade out and shrink (sweep out) effect
	tween.tween_property(
		self, "modulate:a", 0, fade_duration
	).as_relative().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self, "scale", Vector2(0, 0), fade_duration
	).as_relative().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	# Callback for removal after animation
	tween.tween_callback(Callable(self, "_remove_card"))

func _remove_card():
	# Remove the card after animation
	queue_free()


func randomize_card():
	var suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
	var numbers = range(1, 14)  # Ace to King

	suit = suits[randi() % suits.size()]
	number = numbers[randi() % numbers.size()]

	# Optionally set texture based on suit and number here
	


func _on_timer_timeout() -> void:
	pass # Replace with function body.
