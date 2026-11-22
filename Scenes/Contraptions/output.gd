extends Contraption

class_name OutputThingy

@export
var requirements: Dictionary = {}


var requirements_container: VBoxContainer = null


func can_append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> bool:
	if item == null:
		return false
	var local_slot = slot - core_position
	return local_slot in get_rotated_input_slots()


func append_item(item: Item, slot: Vector2i = Vector2i.ZERO) -> void:
	if item == null:
		return
	if not can_append_item(item, slot):
		return

	var item_type = str(item.get_meta("type"))
	if item_type not in requirements:
		push_warning("Item type not required: " + item_type)
		# TODO : decrease life
		var sound_player = AudioStreamPlayer.new()
		var stream = load("res://Assets/Sounds/WRONG BUZZER.mp3")
		sound_player.set_stream(stream)
		get_tree().current_scene.add_child(sound_player)
		sound_player.play()
		await not sound_player.playing
		sound_player.queue_free()
		item.queue_free()
		return

	requirements[item_type] -= 1

	if requirements[item_type] <= 0:
		requirements.erase(item_type)

	_update_requirements_label()
	item.queue_free()
	var sound_player = AudioStreamPlayer.new()
	var stream = load("res://Assets/Sounds/Correct Buzzer - Sound Effect.mp3")
	sound_player.set_stream(stream)
	get_tree().current_scene.add_child(sound_player)
	sound_player.play()
	await not sound_player.playing
	sound_player.queue_free()
	# TODO : increase score


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
	base_occupied_offsets = [Vector2i(0, 0)]
	base_input_slots = [Vector2i(-1, 0)]
	requirements_container = $RequirementsContainer
	_update_requirements_label()

	super()
