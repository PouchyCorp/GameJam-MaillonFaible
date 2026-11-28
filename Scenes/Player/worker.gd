extends CharacterBody2D

enum Direction {
	BACK,
	LEFT,
	RIGHT,
	FRONT
}

var facing:Direction = Direction.FRONT

const SPEED = 500.0
const ACCEL = 20

var hasItem:bool = false
var grabbedItem:Grabbable = null

var reachable:Array[Grabbable]

func _ready() -> void:
	$AnimatedSprite2D.play("idle_front")

func _physics_process(delta: float) -> void:
	var directionX = Input.get_axis("move_left", "move_right")
	if directionX > 0: facing = Direction.RIGHT
	elif directionX < 0: facing = Direction.LEFT
	
	var directionY = Input.get_axis("move_up","move_down")
	if directionY > 0 && directionY > abs(directionX): facing = Direction.FRONT
	elif directionY < 0 && -directionY > abs(directionX): facing = Direction.BACK
	
	var direction:Vector2 = Vector2(directionX, directionY).normalized()
	
	var animationPrefix = "idle_"
	if direction != Vector2(0,0): 
		$Hand.position = direction * 100
		animationPrefix = "walk_"
	
	if hasItem: animationPrefix += "carry_"

	if facing == Direction.FRONT:
		$AnimatedSprite2D.animation = animationPrefix + "front"
		$CarryPlace.position = Vector2(- 64,50)
		z_index = -1

		if (grabbedItem != null):
			grabbedItem.z_index = 10
			grabbedItem.position = position + Vector2(-64, - 100 - 64) + Vector2(0, 50)
	elif facing == Direction.RIGHT:
		$AnimatedSprite2D.animation = animationPrefix + "side"
		$AnimatedSprite2D.flip_h = false
		$CarryPlace.position = Vector2(100, - 64)
		z_index = -1

		if (grabbedItem != null):
			grabbedItem.z_index = 10
			grabbedItem.position = position + Vector2(-64, - 100 - 64) + Vector2(50, 0)
	elif facing == Direction.LEFT:
		$AnimatedSprite2D.animation = animationPrefix + "side"
		$AnimatedSprite2D.flip_h = true
		$CarryPlace.position = Vector2(-100 - 64, - 64)
		z_index = -1

		if (grabbedItem != null):
			grabbedItem.z_index = 10
			grabbedItem.position = position + Vector2(-64, - 100 - 64) + Vector2(-50, 0)

	elif facing == Direction.BACK:
		$AnimatedSprite2D.animation = animationPrefix + "back"
		$CarryPlace.position = Vector2(- 64,-50 - 64)
		z_index = 1

		if (grabbedItem != null):
			grabbedItem.z_index = 0
			grabbedItem.position = position + Vector2(-64, - 100 - 64) + Vector2(0, -50)
	
	velocity = lerp(velocity, direction * SPEED, ACCEL * delta)  # larp alert !!
	move_and_slide()
	

	if grabbedItem != null && hasItem:
		$PlaceIndicator.position = grabbedItem.position.snapped(Vector2(Grid.GRID_SIZE,Grid.GRID_SIZE)) - position + Vector2(Grid.GRID_SIZE/2,Grid.GRID_SIZE/2) # To adjust the indicator to the grid and the player position

func _on_item_detector_body_entered(body: Node2D) -> void:
	if (body is Grabbable):
		#print("Entered: " + str(body))
		if (not body in reachable): reachable.push_back(body)
		update_nearest()

		
func _on_item_detector_body_exited(body: Node2D) -> void:
	if (body is Grabbable):
		body.ungrab_highlight()
		reachable.erase(body)
		update_nearest()
		
func update_nearest():
	reachable.sort_custom(compare_distance)
	if (!hasItem && reachable.size() > 0): reachable[0].grab_highlight()
	
func compare_distance(a:Grabbable,b:Grabbable):
	a.ungrab_highlight()
	b.ungrab_highlight()
	var distance_a = a.position - $Hand.position
	var distance_b = b.position - $Hand.position
	return distance_a.length_squared() < distance_b.length_squared()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact")):
		if hasItem: # Drop the item
			if grabbedItem.drop():
				hasItem = false
				reachable.push_front(grabbedItem)
				grabbedItem = null
				$PlaceIndicator.hide()

		elif !hasItem && reachable.size() > 0: # Grab the nearest item
			grabbedItem = reachable[0]
			grabbedItem.ungrab_highlight()
			grabbedItem.grab()
			hasItem = true
			reachable.pop_front()
			$PlaceIndicator.show()


	if (event.is_action_pressed("rotate")):
		if hasItem:
			grabbedItem.facing = (grabbedItem.facing+1)%4 as Constants.Directions
			grabbedItem.global_rotation = grabbedItem.facing * PI/2
			%PlaceIndicator.global_rotation = grabbedItem.facing * PI/2

			# match grabbedItem.facing:
			# 	Constants.Directions.RIGHT:
			# 		grabbedItem.get_node("AnimatedSprite2D").animation = "droit"
			# 	Constants.Directions.DOWN:
			# 		grabbedItem.get_node("AnimatedSprite2D").animation = "bas"
			# 	Constants.Directions.LEFT:
			# 		grabbedItem.get_node("AnimatedSprite2D").animation = "gauche"
			# 	Constants.Directions.UP:
			# 		grabbedItem.get_node("AnimatedSprite2D").animation = "haut"
				

			grabbedItem.get_node("AnimatedSprite2D").play()


			
