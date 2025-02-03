@icon("res://components/cards/2D/icons/deck.svg")
class_name CardDeck extends Node

# The actual deck containing Card resources
var deck: Array[Card] = []
var draw_pile: Array[Card] = []
var hand: Array[Card] = []


signal shuffle_complete
#unused
signal deck_updated
signal card_added(card: Card)
signal card_removed(card: Card)

func set_deck(cards: Array[Card]):
	deck = cards
	draw_pile = cards.duplicate()
	emit_signal("deck_updated")

func shuffle():
	print("shuffle on deck")
	$ShuffleTimer.start()

func _on_shuffle_complete():
	#hand.clear()
	draw_pile = deck.duplicate()
	draw_pile.shuffle()
	emit_signal("shuffle_complete")
	print("shuffle_complete")

# Function to draw a random card from the draw_pile
func draw_card() -> Card:
	if draw_pile.size() > 0:
		var random_index = randi() % draw_pile.size()
		var drawn_card = draw_pile[random_index]
		hand.append(drawn_card)
		draw_pile.remove_at(random_index)
		#emit_signal("card_removed", drawn_card)  # Signal removal
		print(drawn_card.get_card_type_name() + "drawn")
		return drawn_card
	else:
		print("Draw pile is empty!")
		return null

func has_draw() -> bool:
	return draw_pile.size() > 0

func get_hand() -> Array[Card]:
	return hand
	
func resolve_hand() -> StatsBuff:
	var buff = StatsBuff.new()
	buff.time = 4
	for card in hand:
		print("new " + card.get_card_type_name())
		match(card.card_type):
			Card.CardType.ATTACK:
				buff.hp += card.hp
				#elemental
			Card.CardType.SPELL:
				buff.damage += card.damage
				# drop gold/xp
				# split
			Card.CardType.WEAPON:
				print("weapon", card.get_weapon_type_name())
				buff.weapons.append(StatsWeapon.create_new_weapon(card.weapon_type))
	hand.clear()
	return buff
	

# Function to add a card to the deck
func add_card(card: Card):
	deck.append(card)
	emit_signal("card_added", card)

# Example function to demonstrate setting and drawing from the deck
func _ready():
	# Connect signals to custom handlers
	#connect("shuffle_complete", Callable(self, "_on_shuffle_complete"))
	connect("card_added",  Callable(self, "_on_card_added"))
	connect("card_removed",  Callable(self, "_on_card_removed"))

# Custom signal handlers
func _on_card_added(card: Card):
	print("Card added:", card)

func format_hand_stats() -> String:
	var stats = ""
	for card in hand:
		stats += "[c:" + card.name + "]"
	return stats
