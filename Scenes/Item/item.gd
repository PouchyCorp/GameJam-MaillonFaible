extends Contraption
class_name Grabbable


const BASE_DIMENSIONS = Vector2(128,128)

var reached = false

@export var grabbed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drop()

func _process(delta: float) -> void:
	if reached:
		modulate = Color(0.05, 1.0, 0.0, 1.0)
	elif $Slots/Slot.grabItem != null:
		modulate = Color(1,0,0,1)
	else:
		modulate = Color(1,1,1,1)

func grab():
	grabbed = true
	$CollisionBox.disabled = true
	
	
func drop():
	grabbed = false
	$CollisionBox.disabled = false
	
	
func rotate_item():
	rotation = rotation + PI/2

func grab_highlight():
	reached = true
	
func ungrab_highlight():
	reached = false
