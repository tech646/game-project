extends CharacterBody2D

## Player character with isometric arrow-key movement.
## Has NeedsComponent and ExpressionIcon as children.

@export var speed: float = 200.0
@export var character_data: CharacterData = null

# Isometric direction vectors (2:1 ratio projection)
const ISO_UP    = Vector2(1, -0.5)
const ISO_DOWN  = Vector2(-1, 0.5)
const ISO_LEFT  = Vector2(-1, -0.5)
const ISO_RIGHT = Vector2(1, 0.5)

@onready var sprite: Sprite2D = $Sprite2D
@onready var needs: NeedsComponent = $NeedsComponent

var is_active: bool = true


func setup(data: CharacterData) -> void:
	## Called by Main after scene is ready. Initializes character data.
	character_data = data
	needs.initialize(data)
	if data.sprite_path != "":
		sprite.texture = load(data.sprite_path)
	CharacterManager.register_player(self)


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.State.PLAYING:
		velocity = Vector2.ZERO
		return

	if not is_active:
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
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false

	velocity = direction * speed
	move_and_slide()
