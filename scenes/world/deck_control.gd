@icon("res://components/cards/2D/icons/deck.svg")
class_name CardDeck extends Control

# The actual deck containing Card resources
var deck: Array[Card] = []
var draw_pile: Array[Card] = []
var hand: Array[Card] = []

@onready var draw_audio = $DrawAudio
@onready var shuffle_audio = $ShuffleAudio
@export var card_scene = preload("res://scenes/world/card_deck.tscn")

signal shuffle_complete
#unused
signal deck_updated
signal card_added(card: Card)
signal card_removed(card: Card)

# Cache the ScrollContainer node for easy access
@onready var deck_control = $Control
@onready var scroll_container = $Control/ScrollContainer
@onready var grid_container = $Control/ScrollContainer/GridContainer

func _process(delta):
	if Input.is_action_just_pressed("toggle_inventory"):
		deck_control.visible = !deck_control.visible
	if Input.is_action_pressed("move_back"):
		scroll_container.scroll_vertical += 10 # Modify as needed for smooth scrolling
	elif Input.is_action_pressed("move_forward"):
		scroll_container.scroll_vertical -= 10

func set_deck(cards: Array[Card]):
	deck = cards
	draw_pile = cards.duplicate()
	for card in deck:
		var card_instance = card_scene.instantiate() as CardDeckSprite
		grid_container.add_child(card_instance)
		card_instance.set_card(card)
		Log.pr("add_card", card.name)
	emit_signal("deck_updated")

func shuffle():
	Log.pr("shuffle on deck")
	shuffle_audio.play()
	$ShuffleTimer.start()

func _on_shuffle_complete():
	#hand.clear()
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	emit_signal("shuffle_complete")
	Log.pr("shuffle_complete")

# Function to draw a random card from the draw_pile
func draw_card() -> Card:
	
	if draw_pile.size() > 0:
		draw_audio.play()
		var random_index = randi() % draw_pile.size()
		var drawn_card = draw_pile[random_index]
		hand.append(drawn_card)
		draw_pile.remove_at(random_index)
		#emit_signal("card_removed", drawn_card)  # Signal removal
		#Log.pr(drawn_card.get_card_type_name() + "drawn")
		return drawn_card
	else:
		Log.pr("Draw pile is empty!")
		return null

func has_draw() -> bool:
	return draw_pile.size() > 0

func get_hand() -> Array[Card]:
	return hand

func get_last_drawn_card() -> Card:
	if hand.size() == 0:
		return null
	return hand.back()

func resolve_hand() -> PlayerStats:
	var hand_buff = PlayerStats.new()
	for card in hand:
		Log.pr("new " + card.get_card_type_name())
		match(card.card_type):
			Card.CardType.ATTACK:
				if not card.attack.weapon_type == AttackStats.WeaponType.NA:
					hand_buff.attacks.append(card.attack)
				else:
					hand_buff.add_buff(card.attack)
				#elemental
			Card.CardType.SPELL:
				pass
				# drop gold/xp
				# split
			Card.CardType.ACTION:
				Log.pr("not implemented actions")

	hand.clear() # Discard hand
	return hand_buff

# Function to add a card to the deck
func add_card(card: Card):
	deck.append(card)
	var card_instance = card_scene.instantiate() as CardDeckSprite
	grid_container.add_child(card_instance)
	
	card_instance.set_card(card)
	emit_signal("card_added", card)

# Example function to demonstrate setting and drawing from the deck
func _ready():
	# Connect signals to custom handlers
	#connect("shuffle_complete", Callable(self, "_on_shuffle_complete"))
	connect("card_added",  Callable(self, "_on_card_added"))
	connect("card_removed",  Callable(self, "_on_card_removed"))

# Custom signal handlers
func _on_card_added(card: Card):
	Log.pr("Card added:", card)

func format_hand_stats() -> String:
	var stats = ""
	for card in hand:
		stats += "[c:" + card.name + "]"
	return stats
