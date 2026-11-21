extends StaticBody2D

class_name Contraption

const facing:Constants.Faces = Constants.Faces.RIGHT

func append_item(item: Item, side: Constants.Sides) -> void:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	pass

func can_append_item(item: Item, side: Constants.Sides) -> bool:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	print("side :", side)
	return false

func notify_change(contraption:Contraption,side:Constants.Faces):
	print("got contraption ",contraption," with side ",side)
