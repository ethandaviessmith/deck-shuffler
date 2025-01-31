extends Node

@export_file("*.tscn") var next_scene: String = ""

@onready var content_warnings: ContentWarnings = $ContentWarnings

@onready var skip_warning = true

func _ready() -> void:
	if skip_warning:
		on_all_content_warnings_displayed()
	else:
		content_warnings.all_content_warnings_displayed.connect(on_all_content_warnings_displayed)
	
func on_all_content_warnings_displayed() -> void:
	if not next_scene.is_empty():
		SceneTransitionManager.transition_to_scene(next_scene)
