extends Node

const GRID_SIZE = 128
var cells:Array[Contraption] = []
const ROWS = 10
const ROW_SIZE = 12

func _ready() -> void:
	for i in range(ROWS*ROW_SIZE):
		cells.append(null)

func coords(pos:Vector2) -> int:
	var x = int(pos.x/GRID_SIZE)
	var y = int(pos.y/GRID_SIZE)
	return y*ROW_SIZE + x

func coord_to_vector(coord:int) -> Vector2i:
	return Vector2i(coord % ROW_SIZE, int(coord / ROW_SIZE))

func is_in_bounds(pos:Vector2i) -> bool:
	return pos.x >= 0 and pos.x < ROW_SIZE and pos.y >= 0 and pos.y < ROWS

func get_contraption(pos:Vector2) -> Contraption:
	var coord = coords(pos)
	if coord < 0 or coord >= cells.size():
		return null
	return cells[coord]

func can_place(pos:Vector2) -> bool:
	var coord = coords(pos)
	if coord < 0 or coord >= cells.size():
		return false
	return cells[coord] == null

func place_contraption(pos:Vector2, contraption:Contraption) -> bool:
	if contraption == null:
		return false
	var coord = coords(pos)
	if coord < 0 or coord >= cells.size() or cells[coord] != null:
		return false
	cells[coord] = contraption
	update_contraptions_around(coord_to_vector(coord))
	return true

func take_contraption(pos:Vector2) -> Contraption:
	var coord = coords(pos)
	if coord < 0 or coord >= cells.size():
		return null
	var contraption = cells[coord]
	if contraption == null:
		return null
	cells[coord] = null
	update_contraptions_around(coord_to_vector(coord))
	return contraption

func update_contraptions(pos:Vector2, contraption:Contraption) -> bool:
	if contraption == null:
		take_contraption(pos)
		return true
	return place_contraption(pos, contraption)

func update_contraptions_around(coord:Vector2i) -> void:
	for y in range(max(0, coord.y - 1), min(coord.y + 2, ROWS)):
		for x in range(max(0, coord.x - 1), min(coord.x + 2, ROW_SIZE)):
			var contraption = cells[y*ROW_SIZE + x]
			if contraption != null:
				update_single_contraption(x, y, contraption)

func update_single_contraption(x:int, y:int, contraption:Contraption) -> void:
	if "frontContraption" in contraption:
		contraption.frontContraption = null
	if "contraptionTop" in contraption:
		contraption.contraptionTop = null
	if "contraptionBottom" in contraption:
		contraption.contraptionBottom = null
	if "leftContraption" in contraption:
		contraption.leftContraption = null
	if "rightContraption" in contraption:
		contraption.rightContraption = null

	for output_side in contraption.base_output_sides:
		var global_output = contraption.rotate_side(output_side)
		var neighbor = Vector2i(x, y) + side_offset(global_output)
		if not is_in_bounds(neighbor):
			continue
		var target = cells[neighbor.y*ROW_SIZE + neighbor.x]
		if target == null:
			continue
		var receiving_global = contraption.opposite_side(global_output)
		var receiving_local = target.to_local_side(receiving_global)
		if not target.accepts_side(receiving_local):
			continue

		if contraption is Splitter:
			if global_output == Constants.Sides.TOP:
				contraption.contraptionTop = target
				contraption.contraptionTopSide = receiving_local
			elif global_output == Constants.Sides.BOTTOM:
				contraption.contraptionBottom = target
				contraption.contraptionBottomSide = receiving_local
		elif contraption is Cutter:
			if global_output == Constants.Sides.TOP:
				contraption.topContraption = target
				contraption.rightContraptionSide = receiving_local
			elif global_output == Constants.Sides.BOTTOM:
				contraption.bottomContraption = target
				contraption.leftContraptionSide = receiving_local
		elif "frontContraption" in contraption:
			contraption.frontContraption = target
			contraption.frontContraptionSide = receiving_local

func side_offset(side:Constants.Sides) -> Vector2i:
	match side:
		Constants.Sides.LEFT:
			return Vector2i(-1, 0)
		Constants.Sides.RIGHT:
			return Vector2i(1, 0)
		Constants.Sides.TOP:
			return Vector2i(0, -1)
		Constants.Sides.BOTTOM:
			return Vector2i(0, 1)
	return Vector2i.ZERO



