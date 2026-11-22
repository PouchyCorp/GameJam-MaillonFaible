extends Grabbable

class_name Cutter

var processing_item: Item = null

var product_item_left_buffer: Item = null
var product_item_right_buffer: Item = null

var processingTimer: Timer = null
var leftDropTimer: Timer = null
var rightDropTimer: Timer = null


func get_left_output_position() -> Vector2i:
	var output_offset = rotate_vector(Vector2i(2, 0))
	return core_position + output_offset


func get_right_output_position() -> Vector2i:
	var output_offset = rotate_vector(Vector2i(2, 1))
	return core_position + output_offset


func get_left_contraption() -> Contraption:
	if core_position.x < 0:
		return null
	return Grid.get_contraption_at(get_left_output_position())


func get_right_contraption() -> Contraption:
	if core_position.x < 0:
		return null
	return Grid.get_contraption_at(get_right_output_position())


func _ready() -> void:
	base_input_slots = [Vector2i(-1, 0)]
	super()
	processingTimer = Timer.new()
	processingTimer.one_shot = true
	processingTimer.wait_time = Constants.MachineSpeed
	processingTimer.timeout.connect(_on_processing_timer_timeout)
	add_child(processingTimer)

	leftDropTimer = Timer.new()
	leftDropTimer.one_shot = true
	leftDropTimer.wait_time = Constants.DropTime
	leftDropTimer.timeout.connect(_on_left_drop_timer_timeout)
	add_child(leftDropTimer)

	rightDropTimer = Timer.new()
	rightDropTimer.one_shot = true
	rightDropTimer.wait_time = Constants.DropTime
	rightDropTimer.timeout.connect(_on_right_drop_timer_timeout)
	add_child(rightDropTimer)


func can_append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> bool:
	if item == null:
		return false
	if (slot - core_position) not in get_rotated_input_slots():
		return false
	if processing_item != null:
		return false
	if product_item_left_buffer != null or product_item_right_buffer != null:
		return false
	return true


func append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> void:
	if can_append_item(item, slot) == false:
		return
	processing_item = item
	processingTimer.start()


func _process(delta: float) -> void:
	_process_oil(delta)
	if processingTimer != null:
		processingTimer.paused = not is_oil_available()
	if not is_oil_available():
		return

	_try_push_left_item()
	_try_push_right_item()

func clear_items() -> void:
	if processing_item != null:
		processing_item.queue_free()
		processing_item = null

	if product_item_left_buffer != null:
		product_item_left_buffer.queue_free()
		product_item_left_buffer = null

	if product_item_right_buffer != null:
		product_item_right_buffer.queue_free()
		product_item_right_buffer = null


func _on_processing_timer_timeout() -> void:
	if processing_item == null:
		return

	var scene: PackedScene = preload("res://Scenes/Item/item.tscn")
	var left_product: Item = scene.instantiate() as Item
	var right_product: Item = scene.instantiate() as Item

	if left_product == null or right_product == null:
		if left_product != null:
			left_product.queue_free()
		if right_product != null:
			right_product.queue_free()
		return

	# TODO : Determine the product type based on the input item type (json) for now it is an identical item
	if (Constants.json_as_dict != null and Constants.json_as_dict["decoupeur"].has(processing_item.get_meta("type"))):
		left_product.set_meta("type", str(Constants.json_as_dict["decoupeur"][processing_item.get_meta("type")]))
		right_product.set_meta("type", str(Constants.json_as_dict["decoupeur"][processing_item.get_meta("type")]))

	else:
		push_warning("No product type defined for input item type: " + str(processing_item.get_meta("type")) + ". Using the same type as input.")
		left_product.set_meta("type", processing_item.get_meta("type"))
		right_product.set_meta("type", processing_item.get_meta("type"))

	left_product.update_sprite()
	right_product.update_sprite()

	processing_item.queue_free()
	processing_item = null

	product_item_left_buffer = left_product
	product_item_right_buffer = right_product


func _try_push_left_item() -> void:
	if product_item_left_buffer == null:
		return

	var leftContraption = get_left_contraption()
	if leftContraption == null:
		_start_left_drop_process()
		return

	if leftContraption.can_append_item(product_item_left_buffer, core_position):
		if leftDropTimer.is_stopped() == false:
			leftDropTimer.stop()
		leftContraption.append_item(product_item_left_buffer, core_position)
		product_item_left_buffer = null


func _try_push_right_item() -> void:
	if product_item_right_buffer == null:
		return

	var rightContraption = get_right_contraption()
	if rightContraption == null:
		_start_right_drop_process()
		return

	if rightContraption.can_append_item(product_item_right_buffer, core_position):
		if rightDropTimer.is_stopped() == false:
			rightDropTimer.stop()
		rightContraption.append_item(product_item_right_buffer, core_position)
		product_item_right_buffer = null


func _start_left_drop_process() -> void:
	if leftDropTimer.is_stopped() == false:
		return
	leftDropTimer.start()


func _start_right_drop_process() -> void:
	if rightDropTimer.is_stopped() == false:
		return
	rightDropTimer.start()


func _on_left_drop_timer_timeout() -> void:
	if product_item_left_buffer != null:
		product_item_left_buffer.queue_free()
		product_item_left_buffer = null


func _on_right_drop_timer_timeout() -> void:
	if product_item_right_buffer != null:
		product_item_right_buffer.queue_free()
		product_item_right_buffer = null
