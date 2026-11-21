extends Contraption

class_name Cutter

@export
var leftContraption: Contraption = null
@export
var leftContraptionSide: Constants.Sides = Constants.Sides.BACK
@export
var rightContraption: Contraption = null
@export
var rightContraptionSide: Constants.Sides = Constants.Sides.BACK

var processing_item: Item = null
var product_item_left_buffer: Item = null
var product_item_right_buffer: Item = null

var processingTimer: Timer = null
var leftDropTimer: Timer = null
var rightDropTimer: Timer = null


func _ready() -> void:
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


func can_append_item(item: Item, side: Constants.Sides) -> bool:
	if item == null:
		return false

	if side != Constants.Sides.BACK:
		return false

	if processing_item != null:
		return false

	if product_item_left_buffer != null or product_item_right_buffer != null:
		return false

	return true


func append_item(item: Item, side: Constants.Sides) -> void:
	if can_append_item(item, side) == false:
		return

	processing_item = item
	processingTimer.start()


func _process(_delta: float) -> void:
	_try_push_left_item()
	_try_push_right_item()


func _on_processing_timer_timeout() -> void:
	if processing_item == null:
		return

	var input_type = str(processing_item.get_meta("type"))

	var scene: PackedScene = preload("res://item.tscn")
	var left_product: Item = scene.instantiate() as Item
	var right_product: Item = scene.instantiate() as Item

	if left_product == null or right_product == null:
		if left_product != null:
			left_product.queue_free()
		if right_product != null:
			right_product.queue_free()
		return

	# TODO : Fetch recipe from a json, for now it just duplicates the input type
	var processed_type = input_type

	left_product.set_meta("type", processed_type)
	right_product.set_meta("type", processed_type)
	left_product.update_sprite()
	right_product.update_sprite()

	processing_item.queue_free()
	processing_item = null

	product_item_left_buffer = left_product
	product_item_right_buffer = right_product


func _try_push_left_item() -> void:
	if product_item_left_buffer == null:
		return

	if leftContraption == null:
		_start_left_drop_process()
		return

	if leftContraption.can_append_item(product_item_left_buffer, leftContraptionSide):
		if leftDropTimer.is_stopped() == false:
			leftDropTimer.stop()
		leftContraption.append_item(product_item_left_buffer, leftContraptionSide)
		product_item_left_buffer = null


func _try_push_right_item() -> void:
	if product_item_right_buffer == null:
		return

	if rightContraption == null:
		_start_right_drop_process()
		return

	if rightContraption.can_append_item(product_item_right_buffer, rightContraptionSide):
		if rightDropTimer.is_stopped() == false:
			rightDropTimer.stop()
		rightContraption.append_item(product_item_right_buffer, rightContraptionSide)
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