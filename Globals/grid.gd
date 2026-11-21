extends Node

const GRID_SIZE = 128

var cells:Array[Contraption] = []
var footprint_array:Array[int] = [] # -1 means a cell is empty, otherwise it is from 0 to 3, representing the footprint of a 2x2 contraption (0 = top left, 1 = top right, 2 = bottom left, 3 = bottom right)
const ROWS = 10
const ROW_SIZE = 12

func _ready() -> void:
	for i in range(ROWS*ROW_SIZE):
		cells.append(null)
		footprint_array.append(-1)
func coords(pos:Vector2) -> int:
	var x = int(pos.x/GRID_SIZE)
	var y = int(pos.y/GRID_SIZE)
	return ROWS*y + x

func get_contraption(pos:Vector2) -> Contraption:
	return cells[coords(pos)]


	
func update_contraptions_around(coord : Vector2i):
	
	for i in range(max(0, coord.y - 1), min(coord.y + 2, ROWS)):
		for j in range(max(0, coord.x - 1), min(coord.x + 2, ROW_SIZE)):
			var cell = cells[ROWS*i + j]
			if cell != null:
				update_single_contraption(i, j, cell)

func update_single_contraption(i:int, j:int, contraption:Contraption):

	if contraption.footprint_size == Vector2i(2, 2):
			footprint_array[ROWS*i + j] = 0 # top left
			footprint_array[ROWS*i + j + 1] = 1 # top right
			footprint_array[ROWS*(i+1) + j] = 2 # bottom left
			footprint_array[ROWS*(i+1) + j + 1] = 3 # bottom right
	else:
		footprint_array[ROWS*i + j] = 0

	if contraption is not Splitter and contraption is not Cutter: # Theses have multiple outputs, so we don't want to set the front contraption for them
		
		
		var points_to_x = i+1 if contraption.facing == Constants.Directions.RIGHT else i-1
		var points_to_y = j+1 if contraption.facing == Constants.Directions.DOWN else j-1
		
		if (points_to_x < 0 or points_to_x >= ROWS or points_to_y < 0 or points_to_y >= ROW_SIZE):
			contraption.frontContraption = null
			return

		var front_contraption = cells[ROWS*points_to_y + points_to_x]
		if front_contraption != null:
			contraption.frontContraption = front_contraption

			if front_contraption.footprint_size == Vector2i(2, 2):
				var looking_at_block = footprint_array[ROWS*points_to_y + points_to_x]

				match looking_at_block:
					0: # top left
						if contraption.facing == Constants.Directions.RIGHT:
							contraption.frontContraptionSide = Constants.Faces.LEFTUP
						else:
							contraption.frontContraptionSide = Constants.Faces.UPLEFT
					1: # top right
						if contraption.facing == Constants.Directions.DOWN:
							contraption.frontContraptionSide = Constants.Faces.UPRIGHT
						else:
							contraption.frontContraptionSide = Constants.Faces.RIGHTUP
					2: # bottom left
						if contraption.facing == Constants.Directions.UP:
							contraption.frontContraptionSide = Constants.Faces.DOWNLEFT
						else:
							contraption.frontContraptionSide = Constants.Faces.LEFTDOWN
					3: # bottom right
						if contraption.facing == Constants.Directions.LEFT:
							contraption.frontContraptionSide = Constants.Faces.RIGHTDOWN
						else:
							contraption.frontContraptionSide = Constants.Faces.DOWNRIGHT

			else:
				contraption.frontContraptionSide = contraption.facing + front_contraption % 4 # to get the relative side of the front contraption



