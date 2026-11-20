extends StaticBody2D

class_name Contraption

func append_item(item: Item):
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	pass

func can_append_item(item: Item) -> bool:
	# This function is meant to be overridden by subclasses
	print("this is a generic contraption, you should not see this. item :", item)
	return false
