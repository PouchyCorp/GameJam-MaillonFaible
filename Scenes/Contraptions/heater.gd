extends Contraption

class_name Heater

@export
var frontContraption: Contraption = null
@export
var frontContraptionSide: Constants.Sides = Constants.Sides.BACK

var processing_item: Item = null
var product_item_buffer: Item = null

var processingTimer: Timer = null
var dropTimer: Timer = null
var dropLabel: Label = null


func _ready() -> void:
	processingTimer = Timer.new()
	processingTimer.one_shot = true
	processingTimer.wait_time = Constants.MachineSpeed
	processingTimer.timeout.connect(_on_processing_timer_timeout)
	add_child(processingTimer)

	dropTimer = Timer.new()
	dropTimer.one_shot = true
	dropTimer.wait_time = Constants.DropTime
	dropTimer.timeout.connect(_on_drop_timer_timeout)
	add_child(dropTimer)

	dropLabel = get_node_or_null("DropLabel") as Label


func can_append_item(item: Item, side: Constants.Sides) -> bool:
	if item == null:
		return false

	if side != Constants.Sides.BACK:
		return false

	if processing_item != null:
		return false

	if product_item_buffer != null:
		return false

	return true


func append_item(item: Item, side: Constants.Sides) -> void:
	if can_append_item(item, side) == false:
		return

	processing_item = item
	processingTimer.start()

func clear_items() -> void:
	if processing_item != null:
		processing_item.queue_free()
		processing_item = null

	if product_item_buffer != null:
		product_item_buffer.queue_free()
		product_item_buffer = null


func _process(delta: float) -> void:
	_process_oil(delta)
	if processingTimer != null:
		processingTimer.paused = not is_oil_available()
	if not is_oil_available():
		return

	if product_item_buffer != null:
		_try_push_out_item()

	if dropLabel != null:
		if dropTimer.is_stopped() == false:
			dropLabel.visible = true
			dropLabel.text = str(round(dropTimer.time_left * 10) / 10)
		else:
			dropLabel.visible = false


func _on_processing_timer_timeout() -> void:
	if processing_item == null:
		return

	var scene: PackedScene = preload("res://Scenes/Item/item.tscn")
	var product: Item = scene.instantiate() as Item
	if product == null:
		return

	if (Constants.json_as_dict != null and Constants.json_as_dict["four"].has(processing_item.get_meta("type"))):
		product.set_meta("type", str(Constants.json_as_dict["four"][processing_item.get_meta("type")]))

	else:
		push_warning("No product type defined for input item type: " + str(processing_item.get_meta("type")) + ". Using the same type as input.")
		product.set_meta("type", processing_item.get_meta("type"))

	product.update_sprite()

	processing_item.queue_free()
	processing_item = null
	product_item_buffer = product


func _try_push_out_item() -> void:
	if product_item_buffer == null:
		return

	if frontContraption == null:
		_start_drop_process()
		return

	if frontContraption.can_append_item(product_item_buffer, frontContraptionSide):
		if dropTimer.is_stopped() == false:
			dropTimer.stop()
		frontContraption.append_item(product_item_buffer, frontContraptionSide)
		product_item_buffer = null


func _start_drop_process() -> void:
	if dropTimer.is_stopped() == false:
		return
	dropTimer.start()


func _on_drop_timer_timeout() -> void:
	if product_item_buffer != null:
		product_item_buffer.queue_free()
		product_item_buffer = null
