@icon("res://components/cards/2D/icons/deck.svg")
class_name DeckHelper extends Node

@export var deck:Array[Card]

@export var player_upgrades:Array[Card]

func get_random_card() -> Card:
	return deck.pick_random()

func get_random_cards(count:int) -> Array[Card]:
	var array = deck + player_upgrades
	array.shuffle()
	return array.slice(0,count)

func get_random_upgrades(count:int):
	return get_random_cards(count)
	#var upgrades = []
	#for i in count:
		#upgrades.append(deck.pick_random())
	#return upgrades
	
func get_starter_deck(count) -> Array[Card]:
	var cards:Array[Card] = []
	for i in count:
		cards.append(get_random_card())
	cards.append(deck[4])
	return cards
