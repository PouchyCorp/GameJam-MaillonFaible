extends Grabbable
class_name Conveyor

@export
var frontContraption: Contraption = null
@export
var frontContraptionSide: Constants.Sides = Constants.Sides.LEFT

var itemsNodes: Array = []

var dropTimer: Timer = null
var drop_time_label: Label = null
var pending_drop_parent: PathFollow2D = null
var pending_drop_item: Item = null

signal dropped_item(item: Item)

func can_append_item(item: Item, side: Constants.Sides) -> bool:
	if item == null:
		return false

	if side == Constants.Sides.RIGHT:
		return false

	if side == Constants.Sides.TOP or side == Constants.Sides.BOTTOM:
		if (itemsNodes.size() > 0 and itemsNodes[0].progress < item.get_meta("size") * 2):
			return false

	if side == Constants.Sides.LEFT and itemsNodes.size() > 0 and itemsNodes[0].progress < item.get_meta("size"):
		return false

	return true

func append_item(item: Item, side: Constants.Sides) -> void:
	# Add the item with a fresh PathFollow2D node to the conveyor

	var pathFollow: PathFollow2D = PathFollow2D.new()
	pathFollow.loop = false

	if side == Constants.Sides.LEFT:
		pathFollow.progress_ratio = 0
	elif side == Constants.Sides.TOP or side == Constants.Sides.BOTTOM:
		pathFollow.progress_ratio = 0.5
	else:
		push_error("Invalid side for appending an item on a conveyor: " + str(side))
		return # invalid side for appending an item

	%MainPath.add_child(pathFollow)
	pathFollow.add_child(item)

	pathFollow.h_offset = -item.get_meta("size") / 2
	itemsNodes.insert(0, pathFollow)

func _ready() -> void:
	dropTimer = Timer.new()
	dropTimer.one_shot = true
	dropTimer.wait_time = Constants.DropTime
	dropTimer.timeout.connect(_on_drop_timer_timeout)
	add_child(dropTimer)
	
	drop_time_label = %DropLabel
	
	super()

func start_drop_process(parent: Node, itemNode: Item) -> void:
	if parent == null or itemNode == null:
		return

	if dropTimer.is_stopped() == false:
		return

	pending_drop_parent = parent as PathFollow2D
	pending_drop_item = itemNode
	dropTimer.start()


func _on_drop_timer_timeout() -> void:
	if pending_drop_parent == null or pending_drop_item == null:
		return

	if is_instance_valid(pending_drop_parent) and is_instance_valid(pending_drop_item) and pending_drop_item.get_parent() == pending_drop_parent:
		pending_drop_parent.remove_child(pending_drop_item)

	if is_instance_valid(pending_drop_parent):
		var item_index = itemsNodes.find(pending_drop_parent)
		if item_index >= 0:
			itemsNodes.remove_at(item_index)
		pending_drop_parent.queue_free()

	if is_instance_valid(pending_drop_item):
		emit_signal("dropped_item", pending_drop_item)
		pending_drop_item.queue_free()

	pending_drop_parent = null
	pending_drop_item = null

func _process(delta: float) -> void:
	super(delta)
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
			pathFollow.progress_ratio += delta / Constants.MachineSpeed

			# at the end of the conveyor, we either pass the item to the next contraption or drop it
			if pathFollow.progress_ratio >= 1:
				if (frontContraption != null):
					if (!frontContraption.can_append_item(itemNode, frontContraptionSide)):
						pass
						# if the front contraption cannot accept the item, we drop it after a delay (disabled for now)
						#start_drop_process(pathFollow, itemNode)
					else:

						if dropTimer.is_stopped() == false:
							dropTimer.stop()
							pending_drop_parent = null
							pending_drop_item = null

						pathFollow.remove_child(itemNode)
						pathFollow.queue_free()
						itemsNodes.remove_at(i)
						frontContraption.append_item(itemNode, frontContraptionSide)
				else:
					# if there is no front contraption, we drop the item after a delay					
					start_drop_process(pathFollow, itemNode)

					

	if dropTimer.is_stopped() == false:
		drop_time_label.visible = true
		drop_time_label.text = str(round(dropTimer.time_left*10)/10)

		# Update the progress bar offset position
		#drop_time_label.position.x = position.x
		#drop_time_label.position.y = position.y
	else:
		drop_time_label.visible = false

func clear_items() -> void:
	for i in range(itemsNodes.size()):
		var childItems = itemsNodes[i]
		if childItems is PathFollow2D:
			var pathFollow: PathFollow2D = childItems
			pathFollow.queue_free()
	itemsNodes.clear()


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# add an item (for testing purposes) when the conveyor is clicked
		var scene: PackedScene = preload("res://Scenes/Item/item.tscn")
		var item: Node2D = scene.instantiate() as Node2D

		if item != null:
			append_item(item, Constants.Sides.LEFT)
			
