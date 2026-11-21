extends Node

enum Block {
	A,
	B,
	C,
	D
}

enum BlockSize {
	A = 0,
	AB = 1,
	AC = 2,
	ABCD = 3
}

const SIZE:int = 100

const ROW_LENGTH = 12
const ROW_COUNT = 10

var contraptions = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(ROW_COUNT*ROW_LENGTH): contraptions.push_front(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func toRowIndex(pos:Vector2):
	return int(pos.y/SIZE)
	
func toColIndex(pos:Vector2):
	return int(pos.x/SIZE)

func get_contraption(pos:Vector2):
	var x = toRowIndex(pos)
	var y = toColIndex(pos)
	return contraptions[x*ROW_LENGTH + y]

func set_contraption(contraption:Contraption,pos:Vector2,block:Block):
	var x = toRowIndex(pos)
	var y = toColIndex(pos)
	
	var item = [contraption,block]
	if contraption == null: item = null
	contraptions[x*ROW_LENGTH+y] = item
	
	
	print(contraptions)
	
	var up = contraptions[(x-1)*ROW_LENGTH+y]
	if up != null: up[0].alter_input_output(contraption,up[1],Constants.Faces.DOWN)
	
	var down = contraptions[(x+1)*ROW_LENGTH+y]
	if down != null: down[0].alter_input_output(contraption,down[1],Constants.Faces.UP)
	
	var right = contraptions[(x)*ROW_LENGTH+y+1]
	if right != null: right[0].alter_input_output(contraption,right[1],Constants.Faces.LEFT)
	
	var left = contraptions[(x)*ROW_LENGTH+y-1]
	print(left)
	if left != null: left[0].alter_input_output(contraption,left[1],Constants.Faces.RIGHT)
