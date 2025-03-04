@icon("res://components/cards/2D/icons/hand.svg")
class_name HandControl extends Node2D

var stack_positions = {}
var hand_cards = []


const CARD_DROP_DISTANCE = 5
const CARD_DROP_ROTATION = 5

const CARD_OFFSET_DISTANCE = Vector2 (10,10)


func _ready() -> void:
	stack_positions = {
		0: Vector2(0,0),
		1: $Stack1.position,
		2: $Stack2.position,
		3: $Stack3.position
	}

func resolve_hand():
	var target_position = stack_positions[0]

	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		
		# Create a tween for the card
		var position_tween = create_tween()
		position_tween.set_trans(Tween.TRANS_SINE)
		position_tween.set_ease(Tween.EASE_IN_OUT)

		# Staggered delay based on card index
		position_tween.tween_property(card, "position", target_position, 0.5).set_delay(0.1 * i)
		position_tween.tween_callback(Callable(self, "_apply_resolve_effects").bind(card)).set_delay(0.5 + 0.1 * i)

# Function to apply additional effects (fade white, shake, grow, fade out)
func _apply_resolve_effects(card: TextureRect):
	var effect_tween = create_tween()

	# Animate color to white
	effect_tween.tween_property(card, "modulate:a", 0.6, 0.5)
	# Shake effect
	effect_tween.tween_property(card, "position:x", card.position.x + 20, 0.1)
	effect_tween.tween_property(card, "position:x", card.position.x - 20, 0.2)
	effect_tween.tween_property(card, "position:x", card.position.x, 0.1)

	effect_tween.parallel().tween_property(card, "scale", card.scale * 1.2, 0.5)
	effect_tween.parallel().tween_property(card, "modulate:a", 0.0, 0.5).set_delay(0.5)

	# Optionally remove card after animation
	effect_tween.tween_callback(Callable(func() -> void:
		if is_instance_valid(card):
			remove_child(card)
			hand_cards.erase(card)
	))

func add_card_to_hand(card: Card):
	var start = stack_positions[0]
	add_card_to_stack(card.texture, start, get_stack_num(card))

func get_stack_num(card: Card):
	match(card.card_type):
		Card.CardType.ATTACK: 
			if not card.attack.weapon_type == AttackStats.WeaponType.NA:
				return 1
			else:
				return 2
		Card.CardType.SPELL: return 2
		Card.CardType.ACTION: return 3
		_: return 0

# Add a card to a specific stack with animation
func add_card_to_stack(card_texture: Texture2D, start_position: Vector2, stack_num: int):
	var card = TextureRect.new()
	card.texture = card_texture
	card.size = Vector2(100, 150)  # Example size
	add_child(card)
	hand_cards.append(card)


	card.position = start_position
	card.scale = Vector2(0.2,0.2)
	var tween = create_tween()
	tween.tween_property(card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.play()
	# Determine the final position based on the stack
	var final_position = stack_positions[stack_num] + get_random_offset()
	var random_angle = randf_range(-10, 10)
	animate_card_to_stack(card, start_position, final_position, random_angle)

# Function to create random offset for a bit of randomness in positioning
func get_random_offset():
	return Vector2(randf_range(-CARD_DROP_DISTANCE, CARD_DROP_DISTANCE), randf_range(-CARD_DROP_DISTANCE, CARD_DROP_DISTANCE))


## Create a floating animation effect using Tweens
func animate_card_to_stack(card: TextureRect, start_position: Vector2, end_position: Vector2, random_angle: float):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Animate the card's position with a wavy effect
	var random_offset = Vector2(randf_range(-CARD_OFFSET_DISTANCE.x/2 ,CARD_OFFSET_DISTANCE.x/2), randf_range(-CARD_OFFSET_DISTANCE.y/2 ,CARD_OFFSET_DISTANCE.y/2))
	#set position start_position
	tween.tween_property(card, "position", end_position + random_offset, 1.0)
	tween.parallel().tween_property(card, "rotation_degrees", random_angle, 0.5).set_delay(0.5)
	tween.tween_callback(Callable(self, "_apply_wave_effect").bind(card))

# Apply a subtle floating animation
func _apply_wave_effect(card: TextureRect):
	var tween = create_tween()
	#tween.repeat()
	var initial_position = card.position
	var random_shift = randf_range(-2, 2)
	tween.tween_property(card, "position:x", initial_position.x + random_shift, 0.2)
	tween.tween_property(card, "position:x", initial_position.x, 0.2)
