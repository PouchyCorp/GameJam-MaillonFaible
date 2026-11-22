extends Node

const GRID_SIZE = 128 - 12
const ROWS = 9
const ROW_SIZE = 12

var cells:Array[Contraption] = []

func _ready() -> void:
	cells.resize(ROWS * ROW_SIZE)
	cells.fill(null)


func coord_to_vector(coord:int) -> Vector2i:
	return Vector2i(coord % ROW_SIZE, int(float(coord) / float(ROW_SIZE)))


func vector_to_coord(coord:Vector2i) -> int:
	return coord.y * ROW_SIZE + coord.x


func is_in_bounds(coord:Vector2i) -> bool:
	return coord.x >= 0 and coord.x < ROW_SIZE and coord.y >= 0 and coord.y < ROWS


func coords(pos:Vector2) -> Vector2i:
	var x = floori(pos.x / GRID_SIZE)
	var y = floori(pos.y / GRID_SIZE)
	return Vector2i(x, y)


func get_contraption(pos:Vector2) -> Contraption:
	var coord = coords(pos)
	if not is_in_bounds(coord):
		return null
	return cells[vector_to_coord(coord)]


func get_contraption_at(coord:Vector2i) -> Contraption:
	if not is_in_bounds(coord):
		return null
	return cells[vector_to_coord(coord)]


func can_place(pos:Vector2i) -> bool:
	return cells[ROW_SIZE * pos.y + pos.x] == null


func debug_print() -> void:
	# display core positions of contraptions in the grid
	var output = "Grid state:\n"
	for y in range(ROWS):
		for x in range(ROW_SIZE):
			var contraption = get_contraption_at(Vector2i(x, y))
			if contraption == null:
				output += ". "
			elif (contraption.core_position == Vector2i(x, y)):
				output += "X "
			else:
				output += "O "
		output += "\n"
	print(output)


func take_contraption(pos:Vector2, contraption:Contraption = null) -> Contraption:
	if contraption == null:
		var core = coords(pos)
		contraption = get_contraption_at(core)

		if contraption == null:
			for candidate in cells:
				if candidate != null and candidate.core_position == core:
					contraption = candidate
					break
	if contraption == null:
		return null

	var occupied_cells = contraption.get_global_occupied_cells()
	for occupied in occupied_cells:
		if is_in_bounds(occupied):
			cells[vector_to_coord(occupied)] = null
	contraption.set_core_position(Vector2i(-1, -1))
	return contraption


func _get_scene_path_for_contraption_type(type:String) -> String:
	var normalized = type.strip_edges().to_lower()
	match normalized:
		"conveyor":
			return "res://Scenes/Contraptions/conveyor.tscn"
		"splitter":
			return "res://Scenes/Contraptions/splitter.tscn"
		"merger":
			return "res://Scenes/Contraptions/merger.tscn"
		"heater":
			return "res://Scenes/Contraptions/heater.tscn"
		"cutter":
			return "res://Scenes/Contraptions/cutter.tscn"
		_:
			return ""


func _get_spawn_parent() -> Node:
	var scene_tree := get_tree()
	if scene_tree == null or scene_tree.current_scene == null:
		return self

	var current_scene = scene_tree.current_scene
	var constructs = current_scene.get_node_or_null("Constructs")
	if constructs != null:
		return constructs
	return current_scene


func _find_random_placement_for(contraption: Contraption) -> Vector2:
	if contraption == null:
		return Vector2(-1, -1)

	var candidates: Array[Vector2i] = []
	for y in range(ROWS):
		for x in range(ROW_SIZE):
			if (cells[vector_to_coord(Vector2i(x, y))] == null):
				candidates.append(Vector2i(x, y))

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if candidates.size() > 0:
		var random_index = rng.randi_range(0, candidates.size() - 1)
		var chosen_coord = candidates[random_index]
		return Vector2(chosen_coord.x * GRID_SIZE, chosen_coord.y * GRID_SIZE)
	else:
		return Vector2(-1, -1)



func _on_contraption_command(type:String):
	# Finds a random spot on the grid that can fit a contraption of the given type and places it there.
	var scene_path = _get_scene_path_for_contraption_type(type)
	if scene_path.is_empty():
		push_warning("Unknown contraption command type: " + type)
		return

	var scene: PackedScene = load(scene_path) as PackedScene
	if scene == null:
		push_error("Failed to load contraption scene for type: " + type)
		return

	var contraption := scene.instantiate() as Grabbable
	if contraption == null:
		push_error("Command type does not instantiate a Grabbable machine: " + type)
		return

	var spawn_position = _find_random_placement_for(contraption)
	if spawn_position.x < 0:
		push_warning("No free space available to place contraption type: " + type)
		var sound_player = AudioStreamPlayer.new()
		var stream = load("res://Assets/Sounds/WRONG BUZZER.mp3")
		sound_player.set_stream(stream)
		get_tree().current_scene.add_child(sound_player)
		sound_player.play()
		await not sound_player.playing
		sound_player.queue_free()
		contraption.queue_free()
		return

	
	get_tree().current_scene.get_node("Constructs").add_child(contraption)

func place_contraption(pos:Vector2i, contraption:Contraption) -> void:
	if contraption == null:
		return

	contraption.position = pos # Offset to center the output contraption
	contraption.core_position = coords(pos)
	cells[vector_to_coord(coords(pos))] = contraption
