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
		$CarryPlace.position = Vector2(0,0)
		z_index = -1
	elif facing == Direction.RIGHT:
		$AnimatedSprite2D.animation = animationPrefix + "side"
		$AnimatedSprite2D.flip_h = false
		$CarryPlace.position = Vector2(57,-26)
		z_index = -1
	elif facing == Direction.LEFT:
		$AnimatedSprite2D.animation = animationPrefix + "side"
		$AnimatedSprite2D.flip_h = true
		$CarryPlace.position = Vector2(-57,-26)
		z_index = -1
	elif facing == Direction.BACK:
		$AnimatedSprite2D.animation = animationPrefix + "back"
		$CarryPlace.position = Vector2(0,0)
		z_index = 1
	
	velocity = lerp(velocity, direction * SPEED, ACCEL * delta)
	move_and_slide()
	
	if hasItem && grabbedItem != null:
		$PlaceIndicator.global_position = grabbedItem.global_position.snapped(Vector2(Grid.GRID_SIZE,Grid.GRID_SIZE))
	
	if grabbedItem != null && hasItem:
		grabbedItem.global_position = $CarryPlace.global_position

func _on_item_detector_body_entered(body: Node2D) -> void:
	if (body is Grabbable):
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
	var distance_a = a.global_position - $Hand.global_position
	var distance_b = b.global_position - $Hand.global_position
	return distance_a.length_squared() < distance_b.length_squared()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact")):
		if hasItem:
			if grabbedItem.drop():
				hasItem = false
				reachable.push_front(grabbedItem)
				grabbedItem = null
				$PlaceIndicator.hide()
		elif !hasItem && reachable.size() > 0:
			grabbedItem = reachable[0]
			grabbedItem.ungrab_highlight()
			grabbedItem.grab()
			hasItem = true
			reachable.pop_front()
			$PlaceIndicator.show()
	if (event.is_action_pressed("rotate")):
		if hasItem:
			grabbedItem.rotate(PI/2)
			grabbedItem.facing = (grabbedItem.facing+1)%4 as Constants.Directions

			
