extends CharacterBody2D

## Player character with isometric movement and object interaction.

@export var speed: float = 200.0
@export var character_data: CharacterData = null

const ISO_UP    = Vector2(1, -0.5)
const ISO_DOWN  = Vector2(-1, 0.5)
const ISO_LEFT  = Vector2(-1, -0.5)
const ISO_RIGHT = Vector2(1, 0.5)
const TARGET_HEIGHT := 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var needs: NeedsComponent = $NeedsComponent
@onready var interaction_detector: InteractionDetector = $InteractionArea
@onready var action_executor: ActionExecutor = $ActionExecutor

var is_active: bool = true
var _interaction_locked: bool = false


func setup(data: CharacterData) -> void:
	character_data = data
	needs.initialize(data)
	if data.sprite_path != "":
		var tex: Texture2D = load(data.sprite_path)
		sprite.texture = tex
		var scale_factor := TARGET_HEIGHT / float(tex.get_height())
		sprite.scale = Vector2(scale_factor, scale_factor)
	CharacterManager.register_player(self)


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.State.PLAYING:
		velocity = Vector2.ZERO
		return
	if not is_active or _interaction_locked:
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


func try_interact() -> Dictionary:
	## Called by Main when Enter is pressed. Returns interaction info.
	if _interaction_locked or not is_active:
		return {}

	var obj := interaction_detector.get_nearest_object()
	if obj:
		return {"type": "object", "object": obj}
	return {}


func lock_for_action() -> void:
	_interaction_locked = true


func unlock_from_action() -> void:
	_interaction_locked = false
