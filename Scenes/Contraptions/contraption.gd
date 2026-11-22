extends StaticBody2D

class_name Contraption

var SNAP = Vector2(Grid.GRID_SIZE,Grid.GRID_SIZE) # l'ide preferait ne pas avoir une constante ici

var facing:Constants.Directions = Constants.Directions.RIGHT

# Grid coordinate of the top-left cell (the machine core).
var core_position: Vector2i = Vector2i(-1, -1)

var oil_max: float = 100.0
var oil_drain_per_second: float = 1.5
var oil_recovery: float = 25.0

# Grid data is relative to this machine's core.
# 1x1 is the default footprint; larger machines override these offsets.
@export var base_occupied_offsets: Array[Vector2i] = [Vector2i(0, 0)]

@export var base_input_slots: Array[Vector2i] = []

var input_connections: Dictionary = {}
var output_connections: Dictionary = {}

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


func append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> void:
	print("this is a generic contraption, you should not see this. item :", item, " slot:", slot)


func can_append_item(item: Item, _slot: Vector2i = Vector2i.ZERO) -> bool:
	print("this is a generic contraption, you should not see this. item :", item)
	return false


func notify_change(_contraption:Contraption) -> void:
	pass


func clear_items() -> void:
	pass


func rotate_vector(vector: Vector2i) -> Vector2i:
	match facing:
		Constants.Directions.DOWN:
			return Vector2i(-vector.y, vector.x)
		Constants.Directions.LEFT:
			return Vector2i(-vector.x, -vector.y)
		Constants.Directions.UP:
			return Vector2i(vector.y, -vector.x)
	return vector


func get_occupied_offsets() -> Array[Vector2i]:
	var rotated:Array[Vector2i] = []
	for offset in base_occupied_offsets:
		rotated.append(rotate_vector(offset))
	return rotated


func get_rotated_input_slots() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for slot in base_input_slots:
		result.append(rotate_vector(slot))
	return result


#func get_rotated_output_slots() -> Array[Vector2i]:
#	var result:Array[Vector2i] = []
#	for slot in base_output_slots:
#		result.append(rotate_vector(slot))
#	return result


func get_core_center_offset() -> Vector2:
	var min_x := 0
	var min_y := 0
	var max_x := 0
	var max_y := 0
	for offset in get_occupied_offsets():
		min_x = min(min_x, offset.x)
		min_y = min(min_y, offset.y)
		max_x = max(max_x, offset.x)
		max_y = max(max_y, offset.y)
	return Vector2((min_x + max_x + 1) * Grid.GRID_SIZE / 2.0,
		(min_y + max_y + 1) * Grid.GRID_SIZE / 2.0)


func set_core_position(core_coord: Vector2i) -> void:
	core_position = core_coord


func get_core_position() -> Vector2i:
	return core_position


func get_global_occupied_cells() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	if core_position.x < 0:
		return result
	for offset in get_occupied_offsets():
		result.append(core_position + offset)
	return result


func get_global_slot_cells(base_slots: Array[Vector2i]) -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	if core_position.x < 0:
		return result
	for offset in base_slots:
		result.append(core_position + rotate_vector(offset))
	return result

func _ready() -> void:
	position = position.snapped(SNAP)
