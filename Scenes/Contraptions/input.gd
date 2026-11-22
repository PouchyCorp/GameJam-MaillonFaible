extends Contraption

class_name InputThingy

@export
var frontContraption: Contraption = null
@export
var thingToDispense: String = ""

@export
var frontContraptionSlot: Vector2i = Vector2i(0, 0)

var dispenseTimer: Timer = null
var dropTimer: Timer = null
var drop_time_label: Label = null
var status_sprite: Sprite2D = null
var pending_drop_item: Item = null

var emitting : bool = false

signal dropped_item(item: Item)


func can_append_item(_item: Item, _slot: Vector2i = Vector2i.ZERO) -> bool:
	return false


func append_item(_item: Item, _slot: Vector2i = Vector2i.ZERO) -> void:
	push_warning("InputThingy cannot accept items")

func clear_items() -> void:
	if pending_drop_item != null:
		pending_drop_item.queue_free()
		pending_drop_item = null


func _ready() -> void:
	base_occupied_offsets = [Vector2i(0, 0)]
	base_input_slots = []

	dispenseTimer = Timer.new()
	dispenseTimer.one_shot = false
	dispenseTimer.wait_time = Constants.DispenseTime
	dispenseTimer.timeout.connect(_on_dispense_timer_timeout)
	add_child(dispenseTimer)

	dropTimer = Timer.new()
	dropTimer.one_shot = true
	dropTimer.wait_time = Constants.DropTime
	dropTimer.timeout.connect(_on_drop_timer_timeout)
	add_child(dropTimer)

	drop_time_label = %DropLabel
	status_sprite = %InputStatusSprite
	dispenseTimer.start()

	super()


func _on_dispense_timer_timeout() -> void:
	if not emitting or thingToDispense.is_empty():
		return

	var scene: PackedScene = preload("res://Scenes/Item/item.tscn")
	var item: Item = scene.instantiate() as Item
	if item == null:
		return

	item.set_meta("type", thingToDispense)
	item.update_sprite()

	if _try_append_to_front(item):
		return

	start_drop_process(item)


func start_drop_process(itemNode: Item) -> void:
	if itemNode == null:
		return

	if dropTimer.is_stopped() == false:
		itemNode.queue_free()
		return

	add_child(itemNode)
	pending_drop_item = itemNode
	dropTimer.start()


func _on_drop_timer_timeout() -> void:
	if pending_drop_item == null:
		return

	if is_instance_valid(pending_drop_item):
		emit_signal("dropped_item", pending_drop_item)
		pending_drop_item.queue_free()

	pending_drop_item = null


func _process(_delta: float) -> void:
	if pending_drop_item != null:
		if _try_append_to_front(pending_drop_item):
			remove_child(pending_drop_item)
			pending_drop_item = null
			dropTimer.stop()

	if dropTimer.is_stopped() == false:
		drop_time_label.visible = true
		drop_time_label.text = str(round(dropTimer.time_left * 10) / 10)
	else:
		drop_time_label.visible = false

	if status_sprite == null:
		return

	status_sprite.visible = not thingToDispense.is_empty()
	if status_sprite.visible:
		var texture = Item.get_item_texture(thingToDispense)
		if texture != null:
			status_sprite.texture = texture 
		else:
			status_sprite.texture = load("res://icon.svg")
			push_warning("No texture found for item type: " + str(thingToDispense) + ". Using default icon.")


func get_facing_output_position() -> Vector2i:
	var output_offset = rotate_vector(Vector2i(1, 0))
	return core_position + output_offset


func get_facing_contraption() -> Contraption:
	if core_position.x < 0:
		return frontContraption
	var target_position = get_facing_output_position()
	var target = Grid.get_contraption_at(target_position)
	return target if target != null else frontContraption


func _try_append_to_front(item: Item) -> bool:
	var target = get_facing_contraption()
	if target == null:
		return false
	if not target.can_append_item(item, core_position):
		return false
	target.append_item(item, core_position)
	return true
