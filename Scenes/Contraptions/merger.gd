extends Grabbable
class_name Merger


@export
var processing_item_left: Item = null
@export
var processing_item_right: Item = null
@export
var frontContraption: Contraption = null
@export
var frontContraptionSide: Constants.Sides = Constants.Sides.RIGHT
var product_item_buffer: Item = null

var processingTimer : Timer = null
var dropTimer: Timer = null
var dropLabel: Label = null
var waitingForPair: bool = false

func can_append_item(_item: Item, side: Constants.Sides) -> bool:
	if product_item_buffer != null:
		return false

	if side == Constants.Sides.TOP:
		return processing_item_left == null
	elif side == Constants.Sides.BOTTOM:
		return processing_item_right == null
	else:
		return false

func try_push_out_item()-> void:
	if (frontContraption == null):
		start_drop_process()
		return
	
	if (frontContraption.can_append_item(product_item_buffer, frontContraptionSide)):
		if dropTimer.is_stopped() == false:
			dropTimer.stop()
		# no need remove item parent here
		frontContraption.append_item(product_item_buffer, frontContraptionSide)
		product_item_buffer = null
	else:
		pass #start_drop_process() disabled for now, we don't want to drop items if the front contraption cannot accept them


func start_drop_process() -> void:
	if dropTimer.is_stopped() == false:
		return


	if dropTimer.is_stopped() == true:
		dropTimer.start()


func _ready() -> void:
	super()
	processingTimer = get_node("Timer")
	dropTimer = Timer.new()
	dropTimer.one_shot = true
	dropTimer.wait_time = Constants.DropTime
	dropTimer.timeout.connect(_on_drop_timer_timeout)
	add_child(dropTimer)

	dropLabel = %DropLabel
	pass


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
	

func append_item(item: Item, side: Constants.Sides) -> void:
	if side == Constants.Sides.TOP:
		processing_item_left = item
	else:
		processing_item_right = item

	if processing_item_left != null and processing_item_right != null:
		# Both items are present: process them.
		waitingForPair = false
		processingTimer.wait_time = Constants.MachineSpeed
	
		if processingTimer != null:
			processingTimer.start()
	else:
		# A single item is waiting for its pair. If the pair does not arrive in time,
		# the item is ejected unprocessed.
		waitingForPair = true
		processingTimer.wait_time = Constants.DropTime
		if processingTimer != null:
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

	var left_type = str(processing_item_left.get_meta("type"))
	var right_type = str(processing_item_right.get_meta("type"))

	product.set_meta("type", Constants.json_as_dict["fusion"][left_type][right_type])

	processingTimer.stop()

	product_item_buffer = product
	processing_item_left.queue_free()
	processing_item_right.queue_free()
	processing_item_left = null
	processing_item_right = null


func _on_drop_timer_timeout() -> void:
	if product_item_buffer != null:
		product_item_buffer.queue_free()
		product_item_buffer = null
