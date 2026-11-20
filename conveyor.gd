extends Contraption
class_name Conveyor

@export
var speed: float = 3; # Seconds needed for a item to go from one end to the other
@export
var frontContraption: Contraption = null

var itemsNodes: Array = []

signal dropped_item(item: Item)

func can_append_item(item: Item) -> bool:
	if item == null:
		return false

	#if there is already a PathFollow2D node with less than 50% progress, it would overlap with the previous one
	if (%MainPath.get_child_count() > 0 and itemsNodes[0].progress < item.get_meta("size")):
		return false

	return true

func append_item(item: Item) -> void:
	# Add the item with a fresh PathFollow2D node to the conveyor
	var pathFollow: PathFollow2D = PathFollow2D.new()
	pathFollow.loop = false
	%MainPath.add_child(pathFollow)
	pathFollow.add_child(item)
	pathFollow.progress_ratio = 0

	

	pathFollow.h_offset = -item.get_meta("size") / 2
	itemsNodes.insert(0, pathFollow)

func _process(delta: float) -> void:
	for i in range(itemsNodes.size()):
		var childItems = itemsNodes[i]
		if childItems is PathFollow2D:
			var pathFollow: PathFollow2D = childItems
			var itemNode: Item = pathFollow.get_child(0, true)

			if (i < itemsNodes.size() - 1):
				var nextPathFollow: PathFollow2D = itemsNodes[i + 1]
				# if the next item is too close, we don't move this one
				if (nextPathFollow.progress - pathFollow.progress < itemNode.get_meta("size")):
					continue
			# interpolation from 0 to 1 based on speed and delta time
			pathFollow.progress_ratio += delta / speed

			# at the end of the conveyor, we either pass the item to the next contraption or drop it
			if pathFollow.progress_ratio >= 1:
				if (frontContraption != null):
					if (!frontContraption.can_append_item(itemNode)):
						pass
						# if the next contraption is full, we start a countdown
						# TODO: Implement countdown
					else:
						pathFollow.remove_child(itemNode)
						pathFollow.queue_free()
						itemsNodes.remove_at(i)
						frontContraption.append_item(itemNode)
				else:
					pass
					#pathFollow.queue_free()
					emit_signal("dropped_item", itemNode)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# add an item (for testing purposes) when the conveyor is clicked
		var scene: PackedScene = preload("res://item.tscn")
		var item: Node2D = scene.instantiate() as Node2D

		print("item :", item)
		if item != null:
			append_item(item)
