class_name Card extends Sprite2D

@export var suit: String
@export var number: int
@export var fade_duration: float = 1.0  # Default fade duration

var fade_mat: ShaderMaterial

var card_path = "res://components/cards/2D/database/spanish_decks/pixel_deck/%s%d.png"
var card_faces = ["clubs/basto","cups/copa","golds/oro","swords/espada"];


func _ready():
	fade_mat = get_material()
	randomize_card()
	show_card()

func show_card():
	# Initialize transparency and scale for appearance
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.3)
	fade_mat.set_shader_parameter("wipe_amount", 1.0)

	var tween = create_tween() # Fade in effect with sweep in
	tween.tween_property(self.material, "shader_parameter/wipe_amount", 0.0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "hide_card"))
	

func hide_card():
	
	# Create a tween for hide animation
	fade_mat.set_shader_parameter("wipe_amount", 0.0)
	modulate = Color(modulate.r, modulate.g, modulate.b, 1)
	
	var tween = create_tween()
	# Fade out and shrink (sweep out) effect
	#tween.tween_property(self, "modulate:a", 0, fade_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self.material, "shader_parameter/wipe_amount", 1.0, fade_duration).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)

	# Callback for removal after animation
	tween.tween_callback(Callable(self, "_remove_card"))
	#_remove_card()

func _remove_card():
	print("remove %d"  % [number] + suit)
	# Remove the card after animation
	queue_free()
	

func randomize_card():
	suit = card_faces[randi() % card_faces.size()]
	var numbers = range(1, 12)  # Ace to King
	number = numbers[randi() % numbers.size()]
	var texture_path = card_path % [suit, number]
	print(texture_path)
	texture = load(texture_path)


func _on_timer_timeout() -> void:
	pass # Replace with function body.
