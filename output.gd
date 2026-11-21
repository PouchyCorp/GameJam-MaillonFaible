extends Contraption

class_name OutputThingy

@export
var requirements: Dictionary = {"placeholderItem": 5}


func can_append_item(item: Item, side: Constants.Sides) -> bool:
	if item == null:
		return false

	if side == Constants.Sides.BACK:
		return true

	return false


func append_item(item: Item, side: Constants.Sides) -> void:

	if item == null:
		return

	if item.get_meta("type") not in requirements:
		push_warning("Item type not required: " + str(item.get_meta("type")))
		# TODO : play loud buzzer and decrease life
		return

	requirements[item.get_meta("type")] -= 1

	if requirements[item.get_meta("type")] <= 0:
		requirements.erase(item.get_meta("type"))

	# TODO : play happy sound and increase score


	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
