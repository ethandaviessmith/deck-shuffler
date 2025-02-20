class_name WeaponIcon extends TextureRect

const REGION_SIZE = 32

var time = 1.0
var fade_time = 1.5

func add_buff(weapon_type: AttackStats.WeaponType, _time: float):
	time = _time
	set_weapon_type(weapon_type)

func set_weapon_type(weapon_type: AttackStats.WeaponType):
	var region_offset = int(weapon_type) * REGION_SIZE + (REGION_SIZE * 4)
	var old_atlas = texture as AtlasTexture
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = old_atlas.atlas
	atlas_texture.margin = old_atlas.margin
	atlas_texture.region = Rect2(region_offset, 0, REGION_SIZE, REGION_SIZE)
	texture = atlas_texture
	Log.pr("weapon icon", atlas_texture.region)

func _ready():
	$Timer.start(time - fade_time)

func _on_timer_timeout() -> void:
	Log.pr("starting fade")
	start_fade_and_remove(fade_time,0.375)


func start_fade_and_remove(total_duration: float, fade_duration: float):
	var fade_count = total_duration / (fade_duration * 2)
	recursive_fade(int(fade_count), fade_duration)

func _on_fade_out_complete(remaining_fades: int, fade_duration: float):
	recursive_fade(remaining_fades, fade_duration)

func recursive_fade(remaining_fades: int, fade_duration: float):
	if remaining_fades <= 0:
		queue_free()
		return
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, "_on_fade_in_complete").bind(remaining_fades - 1, fade_duration)).set_delay(fade_duration)

func _on_fade_in_complete(remaining_fades: int, fade_duration: float):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.2, fade_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(Callable(self, "_on_fade_out_complete").bind(remaining_fades, fade_duration)).set_delay(fade_duration)
