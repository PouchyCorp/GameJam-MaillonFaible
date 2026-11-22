extends Node2D
class_name Item

func _ready() -> void:

	# account for the size of the child sprite when calculating the size of the item
	var sprite = get_node("Sprite2D")
	if sprite != null:
		var size = sprite.texture.get_size().x * sprite.get_scale().x # texture is square and using the width as the size
		set_meta("size", size)

	update_sprite()

func update_sprite() -> void:
	var sprite = get_node("Sprite2D")
	if sprite == null:
		return

	var item_type = str(get_meta("type"))
	var texture = get_item_texture(item_type)
	sprite.texture = texture if texture != null else load("res://icon.svg")


static func get_item_texture(item_type: String) -> Texture2D:
	var json_text = FileAccess.get_file_as_string("res://Assets/png.json")
	var data = JSON.parse_string(json_text)
	if data is Dictionary:
		var textures = data as Dictionary
		if item_type in textures:
			return load(str(textures[item_type])) as Texture2D
	return null
