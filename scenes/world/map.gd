extends Control

@onready var fog:ColorRect = get_node("/root/World/Fog/ParallaxLayer/ColorRect")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_fog_density(density:float):
	var tween = create_tween() # Fade in effect with sweep in
	tween.tween_property(fog.get_material(), "shader_parameter/density", density, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_rest_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		update_fog_density(0.1)

func _on_rest_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		update_fog_density(0.3)

func _on_field_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		update_fog_density(1)

func _on_field_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
	#update_fog_density(1)
