extends Control

@onready var fog = $Fog
@onready var darken = $Darken
@onready var try_again_button = $Button


func _ready():
	modulate.a = 0 # hide
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().paused = true
	# Configure initial properties
	fog.color = Color(1, 1, 1, 0)  # White fog with 0 initial opacity
	darken.color = Color(0, 0, 0, 0)  # Black overlay with 0 initial opacity
	
	try_again_button.grab_focus()
	_start_fog_and_darken_animation()

func _start_fog_and_darken_animation():
	# Tween animations for a smooth transition
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)  # Tween fog opacity to 0.5 over 2 seconds
	tween.tween_property(darken, "color:a", 0.5, 2.0)  # Tween darken overlay opacity to 0.5 over 2 seconds


func _on_button_pressed() -> void:
	try_again_button.set_visible(false)
	await get_tree().create_timer(2.0, true, false, true).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
