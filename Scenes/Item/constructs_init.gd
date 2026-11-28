extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Place trash can at bottom right corner
	var trash_can_scene: PackedScene = preload("res://Scenes/Contraptions/trash_can.tscn") as PackedScene
	var trash_can: Contraption = trash_can_scene.instantiate() as Contraption
	#var trash_can_pos = Vector2((Grid.ROW_SIZE - 1) * Grid.GRID_SIZE, (Grid.ROWS - 1) * Grid.GRID_SIZE)
	var trash_can_pos = Vector2(0,0)
	Grid.cells[Grid.vector_to_coord(Grid.coords(trash_can_pos))] = trash_can

	trash_can.name = "TrashCan"
	Grid.place_contraption(Vector2i(0,0), trash_can)
	add_child(trash_can)


	# Place the inputs at the left side of the grid
	var input_scene: PackedScene = preload("res://Scenes/Contraptions/input.tscn") as PackedScene
	for i in range(3):
		var input: Contraption = input_scene.instantiate() as Contraption
		var input_pos = Vector2(0, (i*3 + 1) * Grid.GRID_SIZE)
		Grid.cells[Grid.vector_to_coord(Grid.coords(input_pos))] = input

		input.name = "InputThingy" + str(i+1)
		Grid.place_contraption(Vector2i(0, (i*3 + 1)), input)
		add_child(input)

	# Samething for the outputs at the right side of the grid
	var output_scene: PackedScene = preload("res://Scenes/Contraptions/output.tscn") as PackedScene
	for i in range(3):
		var output: Contraption = output_scene.instantiate() as Contraption
		var output_pos = Vector2((Grid.ROW_SIZE - 1) * Grid.GRID_SIZE, (i*3 + 1) * Grid.GRID_SIZE)
		Grid.cells[Grid.vector_to_coord(Grid.coords(output_pos))] = output

		output.name = "OutputThingy" + str(i+1)
		
		Grid.place_contraption(Vector2i((Grid.ROW_SIZE - 1), (i*3 + 1)), output)
		add_child(output)