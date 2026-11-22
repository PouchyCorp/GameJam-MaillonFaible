extends Contraption
class_name Grabbable


const BASE_DIMENSIONS = Vector2(128,128)
var SNAP = Vector2(Grid.GRID_SIZE,Grid.GRID_SIZE) # l'ide preferait ne pas avoir une constante ici

var reached = false

@export var grabbed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = global_position.snapped(SNAP)
	drop()

func _process(_delta: float) -> void:
	if reached:
		modulate = Color(0.05, 1.0, 0.0, 1.0)
	else:
		modulate = Color(1,1,1,1)

func grab():
	var coords = global_position.snapped(SNAP)
	Grid.update_contraptions(coords,null)
	grabbed = true
	scale = Vector2(0.5,0.5)
	$CollisionBox.disabled = true
	
func drop() -> bool:
	global_position = global_position.snapped(SNAP)
	if not Grid.can_place(global_position):
		grabbed = true
		$CollisionBox.disabled = true
		return false
	Grid.update_contraptions(global_position,self)
	grabbed = false
	scale = Vector2(1,1)
	$CollisionBox.disabled = false
	return true
	

func grab_highlight():
	reached = true
	
func ungrab_highlight():
	reached = false
