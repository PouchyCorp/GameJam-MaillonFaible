extends Node

const GRID_SIZE = 128
const ROWS = 10
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
	if contraption == null or not can_place(pos, contraption):
		debug_print()
		return false
	var core = coords(pos)
	contraption.set_core_position(core)
	for offset in contraption.get_occupied_offsets():
		cells[vector_to_coord(core + offset)] = contraption
	debug_print()
	return true


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
	debug_print()
	return contraption


func update_contraptions(pos:Vector2, contraption:Contraption) -> bool:
	if contraption == null:
		return take_contraption(pos) != null
	return place_contraption(pos, contraption)
