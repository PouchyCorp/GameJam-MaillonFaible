extends Grabbable

class_name TrashCan


func _ready() -> void:
	base_occupied_offsets = [Vector2i(0, 0)]
	base_input_slots = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, -1),
		Vector2i(0, 1)
	]
	super()


func can_append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> bool:
	if item == null:
		return false
	var local_slot = slot - core_position
	return local_slot in get_rotated_input_slots()


func append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> void:
	if item == null:
		return
	if not can_append_item(item, slot):
		return
	item.queue_free()


func clear_items() -> void:
	pass
