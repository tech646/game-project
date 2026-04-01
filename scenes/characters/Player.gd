extends CharacterBody2D

## Player character with isometric arrow-key movement.
## Isometric directions: arrows map to diamond-grid directions.

@export var speed: float = 200.0

# Isometric direction vectors (2:1 ratio projection)
const ISO_UP    = Vector2(1, -0.5)
const ISO_DOWN  = Vector2(-1, 0.5)
const ISO_LEFT  = Vector2(-1, -0.5)
const ISO_RIGHT = Vector2(1, 0.5)

@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.State.PLAYING:
		velocity = Vector2.ZERO
		return

	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction += ISO_UP
	if Input.is_action_pressed("move_down"):
		direction += ISO_DOWN
	if Input.is_action_pressed("move_left"):
		direction += ISO_LEFT
	if Input.is_action_pressed("move_right"):
		direction += ISO_RIGHT

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		# Flip sprite based on horizontal direction
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false

	velocity = direction * speed
	move_and_slide()
