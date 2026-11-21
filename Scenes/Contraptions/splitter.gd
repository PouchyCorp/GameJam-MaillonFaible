extends Contraption

class_name Splitter

@export
var contraptionLeft: Contraption = null
@export
var contraptionRight: Contraption = null
@export
var contraptionRightSide: Constants.Sides = Constants.Sides.BACK
@export
var contraptionLeftSide: Constants.Sides = Constants.Sides.BACK

var pointingLeft: bool = true
var itemsNodesLeft: Array = []
var itemsNodesRight: Array = []

var dropTimer: Timer = null
var dropLabel: Label = null
var pending_drop_parent: PathFollow2D = null
var pending_drop_item: Item = null

func _ready() -> void:
	dropTimer = Timer.new()
	dropTimer.one_shot = true
	dropTimer.wait_time = Constants.DropTime
	dropTimer.timeout.connect(_on_drop_timer_timeout)
	add_child(dropTimer)

	dropLabel = %DropLabel

func can_append_item(item: Item, side: Constants.Sides) -> bool:
	if item == null:
		return false

	if side == Constants.Sides.FRONT or side == Constants.Sides.LEFT or side == Constants.Sides.RIGHT:
		return false

	if side == Constants.Sides.BACK and _is_back_entry_blocked(item):
		return false

	return true

func clear_items() -> void:
	for i in range(itemsNodesLeft.size()):
		var childItems = itemsNodesLeft[i]
		if childItems is PathFollow2D:
			var pathFollow: PathFollow2D = childItems
			pathFollow.queue_free()
	itemsNodesLeft.clear()

	for i in range(itemsNodesRight.size()):
		var childItems = itemsNodesRight[i]
		if childItems is PathFollow2D:
			var pathFollow: PathFollow2D = childItems
			pathFollow.queue_free()
	itemsNodesRight.clear()


func append_item(item: Item, side: Constants.Sides) -> void:
	var pathFollow: PathFollow2D = PathFollow2D.new()
	pathFollow.loop = false

	if pointingLeft:
		%MainPathLeft.add_child(pathFollow)
		itemsNodesLeft.insert(0, pathFollow)
	else:
		%MainPathRight.add_child(pathFollow)
		itemsNodesRight.insert(0, pathFollow)

	pathFollow.add_child(item)

	if side == Constants.Sides.BACK:
		pathFollow.progress_ratio = 0
	elif side == Constants.Sides.LEFT or side == Constants.Sides.RIGHT:
		pathFollow.progress_ratio = 0.5
	else:
		pathFollow.progress_ratio = 0

	pathFollow.h_offset = -item.get_meta("size") / 2


func _is_back_entry_blocked(item: Item) -> bool:
	var item_size = item.get_meta("size")
	if pointingLeft:
		if itemsNodesRight.size() > 0:
			return true
		if itemsNodesLeft.size() > 0 and itemsNodesLeft[0].progress < item_size:
			return true
	else:
		if itemsNodesLeft.size() > 0:
			return true
		if itemsNodesRight.size() > 0 and itemsNodesRight[0].progress < item_size:
			return true
	return false
		


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
		var item_index = itemsNodesLeft.find(pending_drop_parent)
		if item_index >= 0:
			itemsNodesLeft.remove_at(item_index)
		else:
			item_index = itemsNodesRight.find(pending_drop_parent)
			if item_index >= 0:
				itemsNodesRight.remove_at(item_index)
		pending_drop_parent.queue_free()

	if is_instance_valid(pending_drop_item):
		pending_drop_item.queue_free()

	pending_drop_parent = null
	pending_drop_item = null


func _process(delta: float) -> void:
	_process_oil(delta)
	if not is_oil_available():
		return

	_process_path(itemsNodesLeft, delta, contraptionLeft, contraptionLeftSide)
	_process_path(itemsNodesRight, delta, contraptionRight, contraptionRightSide)

	if dropTimer.is_stopped() == false:
		dropLabel.visible = true
		dropLabel.text = str(round(dropTimer.time_left * 10) / 10)
	else:
		dropLabel.visible = false


func _process_path(itemsNodes: Array, delta: float, targetContraption: Contraption, targetSide: Constants.Sides) -> void:
	for i in range(itemsNodes.size()):
		var childItems = itemsNodes[i]
		if childItems is PathFollow2D:
			var pathFollow: PathFollow2D = childItems
			var itemNode: Item = pathFollow.get_child(0, true)

			if i < itemsNodes.size() - 1:
				var nextPathFollow: PathFollow2D = itemsNodes[i + 1]
				if nextPathFollow.progress - pathFollow.progress < itemNode.get_meta("size"):
					continue

			pathFollow.progress_ratio += delta / Constants.MachineSpeed

			if pathFollow.progress_ratio >= 1:
				if targetContraption != null:
					if targetContraption.can_append_item(itemNode, targetSide):
						if dropTimer.is_stopped() == false and pending_drop_item == itemNode:
							dropTimer.stop()
							pending_drop_parent = null
							pending_drop_item = null

						pathFollow.remove_child(itemNode)
						pathFollow.queue_free()
						itemsNodes.remove_at(i)
						targetContraption.append_item(itemNode, targetSide)
					else:
						pass
						# if the front contraption cannot accept the item, we drop it after a delay (disabled for now)
						#start_drop_process(pathFollow, itemNode)
				else:
					start_drop_process(pathFollow, itemNode)


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pointingLeft = !pointingLeft

		if pointingLeft:
			%LeftArrow.color = Color(0, 1, 0)  # Green
			%RightArrow.color = Color(1, 1, 1)  # White
		else:
			%LeftArrow.color = Color(1, 1, 1)  # White
			%RightArrow.color = Color(0, 1, 0)  # Green
