extends Grabbable
class_name Merger


@export
var processing_item_left: Item = null
@export
var processing_item_right: Item = null
var product_item_buffer: Item = null

var processingTimer : Timer = null
var dropTimer: Timer = null
var dropLabel: Label = null
var waitingForPair: bool = false

signal dropped_item(item: Item)


func get_facing_output_position() -> Vector2i:
	var output_offset = rotate_vector(Vector2i(1, 0))
	return core_position + output_offset


func get_facing_contraption() -> Contraption:
	var target = Grid.get_contraption_at(get_facing_output_position())
	return target


func can_append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> bool:
	if item == null or product_item_buffer != null:
		return false

	var local_slot = slot - core_position
	var rotated_slots = get_rotated_input_slots()
	var input_index = rotated_slots.find(local_slot)
	if input_index == 0:
		return processing_item_left == null
	if input_index == 1:
		return processing_item_right == null
	return false

func try_push_out_item() -> void:
	if product_item_buffer == null:
		return

	var target_contraption = get_facing_contraption()
	if target_contraption == null:
		start_drop_process()
		return

	if target_contraption.can_append_item(product_item_buffer, core_position):
		if dropTimer.is_stopped() == false:
			dropTimer.stop()
		target_contraption.append_item(product_item_buffer, core_position)
		product_item_buffer = null


func start_drop_process() -> void:
	if dropTimer.is_stopped() == false:
		return
	dropTimer.start()


func _ready() -> void:
	base_occupied_offsets = [
		Vector2i(0, 0)
	]
	base_input_slots = [Vector2i(0, -1), Vector2i(0,1)]
	super()
	processingTimer = get_node("Timer")
	dropTimer = Timer.new()
	dropTimer.one_shot = true
	dropTimer.wait_time = Constants.DropTime
	dropTimer.timeout.connect(_on_drop_timer_timeout)
	add_child(dropTimer)

	dropLabel = get_node("DropLabel")


func _process(delta: float) -> void:
	_process_oil(delta)
	if processingTimer != null:
		processingTimer.paused = not is_oil_available()
	if not is_oil_available():
		return

	if product_item_buffer != null:
		try_push_out_item()

	if processingTimer.is_stopped() == false:
		var progress = processingTimer.time_left / processingTimer.wait_time
		var progress_bar = %TextureProgressBar

		progress_bar.value = progress * 100
		# Update the progress bar offset position
		progress_bar.position.x = position.x
		progress_bar.position.y = position.y

	if dropTimer.is_stopped() == false:
		dropLabel.visible = true
		dropLabel.text = str(round(dropTimer.time_left * 10) / 10)
		dropLabel.position.x = position.x
		dropLabel.position.y = position.y
	else:
		dropLabel.visible = false
	

func append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> void:
	if not can_append_item(item, slot):
		return

	var local_slot = slot - core_position
	var rotated_slots = get_rotated_input_slots()
	var input_index = rotated_slots.find(local_slot)
	if input_index == 0:
		processing_item_left = item
	elif input_index == 1:
		processing_item_right = item
	else:
		return

	if processing_item_left != null and processing_item_right != null:
		waitingForPair = false
		processingTimer.wait_time = Constants.MachineSpeed
		processingTimer.start()
	else:
		waitingForPair = true
		processingTimer.wait_time = Constants.DropTime
		processingTimer.start()

func clear_items() -> void:
	if processing_item_left != null:
		processing_item_left.queue_free()
		processing_item_left = null

	if processing_item_right != null:
		processing_item_right.queue_free()
		processing_item_right = null

	if product_item_buffer != null:
		product_item_buffer.queue_free()
		product_item_buffer = null

func _on_timer_timeout() -> void:
	if waitingForPair:
		var waiting_item: Item = null
		if processing_item_left != null:
			waiting_item = processing_item_left
			processing_item_left = null
		elif processing_item_right != null:
			waiting_item = processing_item_right
			processing_item_right = null

		waitingForPair = false
		if waiting_item != null:
			product_item_buffer = waiting_item
		return

	# free the two items if they are not null
	if processing_item_left == null or processing_item_right == null:
		push_error("Processing processingTimer timeout called but one or both items are null.")
		return

	var scene: PackedScene = preload("res://Scenes/Item/item.tscn")
	var product: Item = scene.instantiate() as Item
	if product == null:
		return

	var left_type = str(processing_item_left.get_meta("type"))
	var right_type = str(processing_item_right.get_meta("type"))
	var fused_type = ""

	var fusion_table = Constants.json_as_dict["fusion"] as Dictionary
	if fusion_table.has(left_type):
		var left_recipes = fusion_table[left_type] as Dictionary
		if left_recipes.has(right_type):
			fused_type = str(left_recipes[right_type])

	if fused_type.is_empty():
		push_warning("No fusion recipe for %s + %s. Pair dropped unprocessed." % [left_type, right_type])
		product.queue_free()
		processing_item_left.queue_free()
		processing_item_right.queue_free()
		processing_item_left = null
		processing_item_right = null
		processingTimer.stop()
		return

	product.set_meta("type", fused_type)
	product.update_sprite()

	processingTimer.stop()
	product_item_buffer = product
	processing_item_left.queue_free()
	processing_item_right.queue_free()
	processing_item_left = null
	processing_item_right = null


func _on_drop_timer_timeout() -> void:
	if product_item_buffer != null:
		emit_signal("dropped_item", product_item_buffer)
		product_item_buffer.queue_free()
		product_item_buffer = null
