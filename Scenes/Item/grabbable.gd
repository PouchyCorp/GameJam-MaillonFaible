extends Contraption
class_name Grabbable


const BASE_DIMENSIONS = Vector2(128,128)
const SNAP = Vector2(Grid.GRID_SIZE,Grid.GRID_SIZE)

var reached = false

@export var grabbed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drop()

func _process(delta: float) -> void:
	if reached:
		modulate = Color(0.05, 1.0, 0.0, 1.0)
	else:
		modulate = Color(1,1,1,1)

func grab():
	var snapped = global_position.snapped(SNAP)
	Grid.set_contraption(snapped,null)
	grabbed = true
	$CollisionBox.disabled = true
	
func drop():
	global_position = global_position.snapped(SNAP)
	Grid.set_contraption(global_position,self)
	grabbed = false
	$CollisionBox.disabled = false
	

func grab_highlight():
	reached = true
	
func ungrab_highlight():
	reached = false
