extends Contraption
class_name Grabbable

const SNAP = Vector2(100,100)

@export var grabbed:bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if grabbed:
		$PlaceIndicator.show()
		$PlaceIndicator.global_position = global_position.snapped(SNAP)
	else:
		$PlaceIndicator.hide()

func grab():
	grabbed = true
	
func drop():
	grabbed = false
	global_position = global_position.snapped(SNAP)

func grab_highlight():
	modulate = Color(1.0, 0.0, 0.0, 1.0)
	
func ungrab_highlight():
	modulate = Color(1,1,1,1)
