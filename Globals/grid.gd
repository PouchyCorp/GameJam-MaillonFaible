extends Node

const GRID_SIZE = 128

var contraptions:Array[Contraption] = []
const ROWS = 10
const ROW_SIZE = 12

func _ready() -> void:
	for i in range(ROWS*ROW_SIZE):
		contraptions.append(null)

func coords(pos:Vector2) -> int:
	var x = int(pos.x/GRID_SIZE)
	var y = int(pos.y/GRID_SIZE)
	return ROWS*y + x

func get_contraption(pos:Vector2) -> Contraption:
	return contraptions[coords(pos)]
	
func set_contraption(pos:Vector2,contraption:Contraption):
	contraptions[coords(pos)] = contraption 
	
	var right = contraptions[coords(pos) + 1]
	if right != null: right.notify_change(contraption,Constants.Faces.LEFT)
	
	var left = contraptions[coords(pos) - 1]
	if left != null : left.notify_change(contraption,Constants.Faces.RIGHT)
	
	var down = contraptions[coords(pos) + ROW_SIZE]
	if down != null : down.notify_change(contraption,Constants.Faces.UP)
	
	var up = contraptions[coords(pos) - ROW_SIZE]
	if up != null : up.notify_change(contraption,Constants.Faces.DOWN)
		
