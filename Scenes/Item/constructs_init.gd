extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Place trash can at bottom right corner
	var trash_can_scene: PackedScene = preload("res://Scenes/Contraptions/trash_can.tscn") as PackedScene
	var trash_can: Contraption = trash_can_scene.instantiate() as Contraption
	#var trash_can_pos = Vector2((Grid.ROW_SIZE - 1) * Grid.GRID_SIZE, (Grid.ROWS - 1) * Grid.GRID_SIZE)
	var trash_can_pos = Vector2(0,0)
	Grid.place_contraption(trash_can_pos, trash_can)

	trash_can.name = "TrashCan"
	trash_can.position = trash_can_pos + Vector2(64, 64) # Offset to center the output contraption
	add_child(trash_can)


	# Place the inputs at the left side of the grid
	var input_scene: PackedScene = preload("res://Scenes/Contraptions/input.tscn") as PackedScene
	for i in range(3):
		var input: Contraption = input_scene.instantiate() as Contraption
		var input_pos = Vector2(0, (i*3 + 1) * Grid.GRID_SIZE)
		Grid.place_contraption(input_pos, input)

		input.name = "InputThingy" + str(i+1)
		input.position = input_pos + Vector2(64, 64)# Offset to center the output contraption
		add_child(input)

	# Samething for the outputs at the right side of the grid
	var output_scene: PackedScene = preload("res://Scenes/Contraptions/output.tscn") as PackedScene
	for i in range(3):
		var output: Contraption = output_scene.instantiate() as Contraption
		var output_pos = Vector2((Grid.ROW_SIZE - 1) * Grid.GRID_SIZE, (i*3 + 1) * Grid.GRID_SIZE)
		Grid.place_contraption(output_pos, output)

		output.name = "OutputThingy" + str(i+1)
		output.position = output_pos + Vector2(64, 64) # Offset to center the output contraption
		add_child(output)
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:

		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()

			KEY_W:
				Grid._on_contraption_command("conveyor")
			KEY_X:
				Grid._on_contraption_command("cutter")
			KEY_C:
				Grid._on_contraption_command("splitter")
			KEY_V:
				Grid._on_contraption_command("merger")
			KEY_B:
				Grid._on_contraption_command("heater")
