extends Contraption

class_name OutputThingy

@export
var requirements: Dictionary = {}


var requirements_container: VBoxContainer = null


func can_append_item(item: Item, side: Constants.Sides) -> bool:
	if item == null:
		return false

	if side == Constants.Sides.LEFT:
		return true

	return false


func append_item(item: Item, _side: Constants.Sides) -> void:

	if item == null:
		return

	if item.get_meta("type") not in requirements:
		push_warning("Item type not required: " + str(item.get_meta("type")))
		# TODO : play loud buzzer and decrease life
		return

	requirements[item.get_meta("type")] -= 1

	if requirements[item.get_meta("type")] <= 0:
		requirements.erase(item.get_meta("type"))

	_update_requirements_label()
	# TODO : play happy sound and increase score


func _update_requirements_label() -> void:
	if requirements_container == null:
		return

	for child in requirements_container.get_children():
		requirements_container.remove_child(child)
		child.queue_free()

	if requirements.is_empty():
		return

	for item_type in requirements.keys():
		var row = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var texture_rect = TextureRect.new()
		texture_rect.custom_minimum_size = Vector2(32, 32)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var texture = Item.get_item_texture(str(item_type))
		texture_rect.texture = texture if texture != null else load("res://icon.svg")
		row.add_child(texture_rect)

		var quantity_label = Label.new()
		quantity_label.text = "x" + str(requirements[item_type])
		quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(quantity_label)

		requirements_container.add_child(row)


func requirementsMet() -> bool:
	return requirements.size() == 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	requirements_container = $RequirementsContainer
	_update_requirements_label()


func set_requirements(new_requirements: Dictionary) -> void:
	requirements = new_requirements
	_update_requirements_label()
