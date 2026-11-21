extends StaticBody2D

class_name Contraption

var facing: Constants.Faces = Constants.Faces.RIGHT

func reverse(direction:Constants.Faces):
	if direction == Constants.Faces.LEFT: return Constants.Faces.RIGHT
	if direction == Constants.Faces.RIGHT: return Constants.Faces.LEFT
	if direction == Constants.Faces.UP: return Constants.Faces.DOWN
	if direction == Constants.Faces.DOWN: return Constants.Faces.UP

func alter_input_output(item:Contraption,block:Grid.Block,direction:Constants.Faces):
	pass

func append_item(item: Item, side: Constants.Sides) -> void:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	pass

func can_append_item(item: Item, side: Constants.Sides) -> bool:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	print("side :", side)
	return false
