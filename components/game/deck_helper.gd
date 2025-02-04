@icon("res://components/cards/2D/icons/deck.svg")
class_name DeckHelper extends Node

@export var deck:Array[Card]

func get_random_card() -> Card:
	return deck.pick_random()
