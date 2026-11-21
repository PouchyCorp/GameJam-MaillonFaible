extends CharacterBody2D


const SPEED = 500.0
const ACCEL = 20

var hasItem:bool = false
var grabbedItem:Node2D = null

var reachable:Array[Grabbable]
var slots:Array[Slot]

func _physics_process(delta: float) -> void:
	var direction:Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up","move_down")).normalized()
	if direction != Vector2(0,0): $Hand.position = direction * 100
	
	velocity = lerp(velocity, direction * SPEED, ACCEL * delta)
	move_and_slide()
	
	if grabbedItem != null && hasItem:
		grabbedItem.global_position = $Hand.global_position



func _on_item_detector_body_entered(body: Node2D) -> void:
	if (body is Grabbable):
		if (not body in reachable): reachable.push_back(body)
		update_nearest()

		
func _on_item_detector_body_exited(body: Node2D) -> void:
	if (body is Grabbable):
		body.ungrab_highlight()
		reachable.erase(body)
		update_nearest()
		
		
func _on_item_detector_area_entered(area: Area2D) -> void:
	if (area is Slot):
		if !area.enabled: return
		if (not area in slots): slots.push_back(area)
		update_nearest_slots()


func _on_item_detector_area_exited(area: Area2D) -> void:
	if (area is Slot):
		area.unhighlight()
		slots.erase(area)
		update_nearest_slots()
		
		
func update_nearest():
	reachable.sort_custom(compare_distance)
	if (!hasItem && reachable.size() > 0): reachable[0].grab_highlight()
	
func update_nearest_slots():
	for slot in slots:
		if !slot.enabled: slots.erase(slot)
	
	slots.sort_custom(compare_slots)
	if (hasItem && slots.size() > 0): slots[0].highlight()

func compare_distance(a:Grabbable,b:Grabbable):
	a.ungrab_highlight()
	b.ungrab_highlight()
	var distance_a = a.global_position - $Hand.global_position
	var distance_b = b.global_position - $Hand.global_position
	return distance_a.normalized() < distance_b.normalized()

func compare_slots(a:Slot,b:Slot):
	a.unhighlight()
	b.unhighlight()
	var distance_a = a.global_position - $Hand.global_position
	var distance_b = b.global_position - $Hand.global_position
	return distance_a.normalized() < distance_b.normalized()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact")):
		if hasItem:
			grabbedItem.drop()
			hasItem = false
			reachable.push_front(grabbedItem)
			update_nearest_slots()
			if slots.size() > 0:
				var slot = slots[0]
				slot.place(grabbedItem)
				slots.pop_front()
			
			grabbedItem = null
		elif !hasItem && reachable.size() > 0:
			grabbedItem = reachable[0]
			grabbedItem.ungrab_highlight()
			grabbedItem.grab()
			hasItem = true
			reachable.pop_front()
	if (event.is_action_pressed("rotate")):
		if hasItem:
			grabbedItem.rotate(PI/2)

			
