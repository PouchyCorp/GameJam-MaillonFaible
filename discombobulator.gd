extends Contraption
class_name Discombobulator


@export
var processing_time: float = 1.0 # Seconds needed for a item to be processed
@export
var processing_item_1: Item = null
@export
var processing_item_2: Item = null
@export
var frontContraption: Contraption = null

var product_item_buffer: Item = null

func can_append_item(_item: Item) -> bool:
	if (processing_item_1 != null and processing_item_2 != null) or product_item_buffer != null:
		return false
	return true

func try_push_out_item()-> void:
	if (frontContraption == null):
		# TODO : Implement dropping the item if there is no front contraption
		return
	
	if (frontContraption.can_append_item(product_item_buffer)):
		# no need remove item parent here
		frontContraption.append_item(product_item_buffer)
		product_item_buffer = null


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if product_item_buffer != null:
		try_push_out_item()

func append_item(item: Item) -> void:
	if processing_item_1 == null:
		processing_item_1 = item
	elif processing_item_2 == null:
		processing_item_2 = item

	if processing_item_1 != null and processing_item_2 != null:
		# Start the processing timer if both items are present
		var timer = get_node("Timer")
		if timer != null:
			timer.start()

	


func _on_timer_timeout() -> void:
	# free the two items if they are not null
	if processing_item_1 == null or processing_item_2 == null:
		push_error("Processing timer timeout called but one or both items are null.")
		return


	# TODO : Implement the actual processing logic here

	var scene: PackedScene = preload("res://item.tscn")
	var placeholder_product: Item = scene.instantiate() as Item

	product_item_buffer = placeholder_product
	processing_item_1.queue_free()
	processing_item_2.queue_free()
