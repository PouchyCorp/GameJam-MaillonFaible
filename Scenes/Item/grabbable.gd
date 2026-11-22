extends Contraption
class_name Grabbable


const BASE_DIMENSIONS = Vector2(128,128)

var reached = false

@export var grabbed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(SNAP)
	drop()

func _process(_delta: float) -> void:
	if reached:
		modulate = Color(0.05, 1.0, 0.0, 1.0)
	else:
		modulate = Color(1,1,1,1)

func grab():
	var coords = position.snapped(SNAP)
	Grid.take_contraption(coords, self)
	core_position = Vector2i(-1, -1)
	grabbed = true
	scale = Vector2(0.5,0.5)
	$CollisionBox.disabled = true
	
func drop() -> bool:
	position = position.snapped(SNAP)
	if not Grid.can_place(Grid.coords(position)):
		grabbed = true
		$CollisionBox.disabled = true
		return false
	grabbed = false
	core_position = Grid.coords(position)
	scale = Vector2(1,1)
	$CollisionBox.disabled = false
	return true
	

func grab_highlight():
	reached = true
	
func ungrab_highlight():
	reached = false
