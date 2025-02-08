extends Control

@onready var player = get_tree().get_first_node_in_group(Player.GroupName)
@onready var option_nodes = [
	$"Panel/BoxContainer/VBoxContainer1",
	$"Panel/BoxContainer/VBoxContainer2",
	$"Panel/BoxContainer/VBoxContainer3"
]
@onready var deck_helper = get_node("/root/World/DeckHelper")
@onready var card_highlight: TextureRect = $Panel/Highlight

var upgrade_options = []
var current_selection = 1
var highlight_mat
var visual_offset = Vector2(42, 40)

func _ready():
	print("level_scene added")
	highlight_mat = card_highlight.get_material()
	upgrade_options = deck_helper.get_random_upgrades(3)  # Get 3 random upgrades

	for i in range(3):
		update_option_ui(option_nodes[i], upgrade_options[i])
		
	highlight_selected()  # Initial highlight on the default selection
	get_tree().paused = true

func _process(delta):
	if highlight_mat is ShaderMaterial:
		highlight_mat.set_shader_parameter("time", Time.get_ticks_usec() / 1000000.0)
	#card_highlight.position = option_nodes[current_selection].position + visual_offset

func update_option_ui(option_node, card_data:Card):
	if not card_data == null:
		option_node.get_node("NameLabel").text = card_data.name
		option_node.get_node("TextureRect").texture = card_data.texture
		option_node.get_node("DescriptionLabel").text = card_data.get_card_type_name()

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_left"):
			change_selection(-1)
		elif event.is_action_pressed("ui_right"):
			change_selection(1)
		elif event.is_action_pressed("ui_accept"):
			apply_upgrade()

func change_selection(delta):
	option_nodes[current_selection].modulate = Color(1, 1, 1)  # Remove highlight
	current_selection = (current_selection + delta) % 3  # Cycle through options
	var targer_position = option_nodes[current_selection].position + visual_offset
	highlight_selected()

 	# Tween to smoothly animate the card position
	var tween = create_tween()
	tween.tween_property(card_highlight, "position", targer_position, 0.3)
	
	if highlight_mat is ShaderMaterial:
		highlight_mat.set_shader_parameter("smudge_on", true)
		highlight_mat.set_shader_parameter("ghost_effect_on", false)

		tween.tween_property(highlight_mat, "shader_parameter/smudge_intensity", 0.1, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		
		tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished():
	if highlight_mat is ShaderMaterial:
		highlight_mat.set_shader_parameter("smudge_on", false)
		highlight_mat.set_shader_parameter("ghost_effect_on", true)

	## Smudge effect animation
	#var highlight_mat = card_highlight.highlight_mat
	#if highlight_mat is ShaderMaterial:
		#highlight_mat.set_shader_parameter("smudge_on", true)
		#tween.tween_property(highlight_mat, "shader_parameter/smudge_intensity", 0.1, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		#tween.set_tween_done_callback(tween, func() -> void:highlight_mat.set_shader_parameter("smudge_on", false))


func highlight_selected():
	pass
	#tween.kill()  # Ensure no running tweens interfere
	# Initial position of card_highlight
	#card_highlight.position = option_nodes[current_selection].position + visual_offset
	
#func highlight_selected():
#	card_highlight.position = option_nodes[current_selection].position + Vector2(0, -10)
#	option_nodes[current_selection].modulate = Color(0.8, 0.8, 1)  # Apply highlight

func apply_upgrade():
	player.apply_upgrade(upgrade_options[current_selection])
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.connect("finished", Callable(self, "_on_fade_completed"))

func _on_fade_completed():
	get_tree().paused = false
	queue_free()
