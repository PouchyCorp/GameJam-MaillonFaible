extends StaticBody2D

class_name Contraption

var facing:Constants.Faces = Constants.Faces.RIGHT

@export var oil_max: float = 100.0
@export var oil_drain_per_second: float = 1.5
@export var oil_recovery: float = 25.0

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

func notify_change(contraption:Contraption,side:Constants.Faces):
	print("got contraption ",contraption," with side ",side)
func clear_items() -> void:
	pass
