extends StaticBody2D

class_name Contraption

var facing:Constants.Directions = Constants.Directions.RIGHT

var oil_max: float = 100.0
var oil_drain_per_second: float = 1.5
var oil_recovery: float = 25.0
@export var base_input_sides: Array[Constants.Sides] = []
@export var base_output_sides: Array[Constants.Sides] = []

var oil_level: float = 100.0
var oil_bar: ProgressBar = null
var oil_system_ready: bool = false

func _setup_oil_system() -> void:
	if oil_system_ready:
		return
	oil_system_ready = true
	oil_level = oil_max

	oil_bar = ProgressBar.new()
	oil_bar.name = "OilBar"
	oil_bar.min_value = 0.0
	oil_bar.max_value = oil_max
	oil_bar.value = oil_level
	oil_bar.show_percentage = false
	oil_bar.z_index = 100
	oil_bar.position = Vector2(-45, -72)
	oil_bar.size = Vector2(90, 12)
	oil_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(oil_bar)

	for child in get_children():
		if child is Area2D:
			if not child.input_event.is_connected(_on_machine_input_event):
				child.input_event.connect(_on_machine_input_event)


func _process_oil(delta: float) -> void:
	_setup_oil_system()
	if oil_level > 0.0:
		oil_level = maxf(0.0, oil_level - oil_drain_per_second * delta)
	if oil_bar != null:
		oil_bar.value = oil_level
		oil_bar.visible = true


func is_oil_available() -> bool:
	return oil_level > 0.0


func recover_oil() -> void:
	_setup_oil_system()
	oil_level = minf(oil_max, oil_level + oil_recovery)
	if oil_bar != null:
		oil_bar.value = oil_level


func _on_machine_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		recover_oil()


func append_item(item: Item, _side: Constants.Sides) -> void:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	pass

func can_append_item(item: Item, _side: Constants.Sides) -> bool:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	return false

func notify_change(contraption:Contraption, side:Constants.Sides):
	print("got contraption ",contraption," with side ",side)
func clear_items() -> void:
	pass

func accepts_side(side:Constants.Sides) -> bool:
	return side in base_input_sides

func rotate_side(side:Constants.Sides) -> Constants.Sides:
	var vector = side_vector(side)
	var rotated = vector
	match facing:
		Constants.Directions.DOWN:
			rotated = Vector2i(-vector.y, vector.x)
		Constants.Directions.LEFT:
			rotated = Vector2i(-vector.x, -vector.y)
		Constants.Directions.UP:
			rotated = Vector2i(vector.y, -vector.x)
	return vector_to_side(rotated)

func to_local_side(side:Constants.Sides) -> Constants.Sides:
	var vector = side_vector(side)
	var local = vector
	match facing:
		Constants.Directions.DOWN:
			local = Vector2i(vector.y, -vector.x)
		Constants.Directions.LEFT:
			local = Vector2i(-vector.x, -vector.y)
		Constants.Directions.UP:
			local = Vector2i(-vector.y, vector.x)
	return vector_to_side(local)

func side_vector(side:Constants.Sides) -> Vector2i:
	match side:
		Constants.Sides.LEFT: return Vector2i(-1, 0)
		Constants.Sides.RIGHT: return Vector2i(1, 0)
		Constants.Sides.TOP: return Vector2i(0, -1)
		Constants.Sides.BOTTOM: return Vector2i(0, 1)
	return Vector2i.ZERO

func vector_to_side(vector:Vector2i) -> Constants.Sides:
	if vector.x < 0: return Constants.Sides.LEFT
	if vector.x > 0: return Constants.Sides.RIGHT
	if vector.y < 0: return Constants.Sides.TOP
	if vector.y > 0: return Constants.Sides.BOTTOM
	return Constants.Sides.RIGHT

func opposite_side(side:Constants.Sides) -> Constants.Sides:
	match side:
		Constants.Sides.LEFT: return Constants.Sides.RIGHT
		Constants.Sides.RIGHT: return Constants.Sides.LEFT
		Constants.Sides.TOP: return Constants.Sides.BOTTOM
		Constants.Sides.BOTTOM: return Constants.Sides.TOP
	return side
