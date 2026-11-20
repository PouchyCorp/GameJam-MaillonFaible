extends Node2D
class_name Item

func _ready() -> void:

	# account for the size of the child sprite when calculating the size of the item
	var sprite = get_node("Sprite2D")
	if sprite != null:
		var size = sprite.texture.get_size().x * sprite.get_scale().x # texture is square and using the width as the size
		set_meta("size", size)
	
