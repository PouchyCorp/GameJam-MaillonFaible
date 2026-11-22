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


func can_place(pos:Vector2, contraption:Contraption = null) -> bool:
	var proposed_core = coords(pos)
	if contraption == null:
		return is_in_bounds(proposed_core) and get_contraption_at(proposed_core) == null

	for offset in contraption.get_occupied_offsets():
		var occupied = proposed_core + offset
		if not is_in_bounds(occupied):
			return false
		var existing = get_contraption_at(occupied)
		if existing != null and existing != contraption:
			return false
	return true


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

func place_contraption(pos:Vector2, contraption:Contraption) -> bool:
	debug_print()
	if contraption == null or not can_place(pos, contraption):
		return false
	var core = coords(pos)
	contraption.set_core_position(core)
	for offset in contraption.get_occupied_offsets():
		cells[vector_to_coord(core + offset)] = contraption
	
	return true


func take_contraption(pos:Vector2, contraption:Contraption = null) -> Contraption:
	debug_print()
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
	debug_print()
	return contraption


func update_contraptions(pos:Vector2, contraption:Contraption) -> bool:
	if contraption == null:
		return take_contraption(pos) != null
	return place_contraption(pos, contraption)


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
			candidates.append(Vector2i(x, y))

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(candidates.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var tmp = candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = tmp

	for coord in candidates:
		var pos = Vector2(coord.x * GRID_SIZE, coord.y * GRID_SIZE)
		if can_place(pos, contraption):
			return pos

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
		# TODO : play buzzer sound
		contraption.queue_free()
		return

	place_contraption(spawn_position, contraption)

	contraption.position = spawn_position
	get_tree().current_scene.get_node("Constructs").add_child(contraption)
