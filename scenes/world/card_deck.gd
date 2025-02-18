class_name CardDeckSprite extends ColorRect

@onready var label_node = $Card/CardLabel
@onready var sprite = $Card

var card: Card
const col = 0.95 # give hue to cards by type


func set_card(set_card: Card):
	if not set_card == null:
		card = set_card

		if label_node:
			label_node.text = set_card.description
		if set_card.texture:
			sprite.texture = set_card.texture
		match set_card.card_type:
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

func _ready():
	pass

func show_card():
	
	if not card == null:
		match card.card_type:
			Card.CardType.ATTACK:
				#self.modulate = Color(1, col, col) 
				#fade_mat.set_shader_parameter("reveal_progress", Vector4(1.0, col, col, 1.0))
				pass

	# Initialize transparency and scale for appearance
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.3)

func _remove_card():
	# Remove the card after animation
	queue_free()
