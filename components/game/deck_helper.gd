@icon("res://components/cards/2D/icons/deck.svg")
class_name DeckHelper extends Node

@export var deck:Array[Card]

func get_random_card() -> Card:
	return deck.pick_random()
	
func get_random_upgrades(count:int):
	var upgrades = []
	for i in count:
		upgrades.append(deck.pick_random())
	return upgrades
	
