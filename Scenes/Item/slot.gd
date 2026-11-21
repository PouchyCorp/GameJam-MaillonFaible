extends Area2D
class_name Slot

@export var enabled = true

var grabItem:Grabbable = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unhighlight()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func place(item:Grabbable):
	print("Slot ",self," recieve",item)
	if !enabled: return
	
	item.slot = self
	grabItem = item
	item.global_position = global_position
	item_placed.emit(item)
	enabled = false
	
func remove():
	print("Slot ",self," lost")
	item_placed.emit(null)
	enabled = true
	grabItem = null
	
func highlight():
	if enabled: $Sprite2D.show()
	
func unhighlight():
	$Sprite2D.hide()
	
func item_is_grabbed():
	grabItem = null
	item_placed.emit(null)
	enabled = false

func item_is_dropped():
	enabled = true
	

signal item_placed(item: Grabbable)
