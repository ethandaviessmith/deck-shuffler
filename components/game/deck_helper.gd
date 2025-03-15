@icon("res://components/cards/2D/icons/deck.svg")
class_name DeckHelper extends Node

@export var deck:Array[Card]

@export var player_upgrades:Array[Card]


func rng_list(numbers: Array) -> int:
	var rng = RandomNumberGenerator.new() #rng.randomize()
	var random_index = rng.randi_range(0, numbers.size() - 1)
	return numbers[random_index]

func get_random_card() -> Card:
	return deck[rng_list([0,1,2,3,5,7,9])]
	#return deck.pick_random()

func get_random_cards(count:int) -> Array[Card]:
	var array = deck # + player_3upgrades # only deck for now as we focus on deck building first
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
	#for i in count:
	#for i in 3:
		#cards.append(get_random_card())
	 
	var random_number = randi_range(0, 3)
	cards.append(deck[random_number])
	cards.append(deck[random_number])
	# set hand manually
	#cards.append(deck[0])
	#cards.append(deck[1])
	#cards.append(deck[2])
	cards.append(deck[10])
	cards.append(deck[9])
	cards.append(deck[3])
	cards.append(deck[4]) # extra draw card
	#cards.append(deck[8]) # scarecrow
	return cards
