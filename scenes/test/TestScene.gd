extends Node2D

## Minimal test scene — just a character that moves, on a colored background.

var _player_scene: PackedScene = preload("res://scenes/characters/Player.tscn")

func _ready() -> void:
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.3, 0.25, 0.2)
	bg.position = Vector2(-400, -300)
	bg.size = Vector2(800, 600)
	bg.z_index = -10
	add_child(bg)

	# Floor
	var floor_rect := ColorRect.new()
	floor_rect.color = Color(0.5, 0.45, 0.38)
	floor_rect.position = Vector2(-400, 50)
	floor_rect.size = Vector2(800, 250)
	floor_rect.z_index = -9
	add_child(floor_rect)

	# Test furniture PNG
	var tex_path := "res://assets/furniture/bed/Cama 1.png"
	if ResourceLoader.exists(tex_path):
		var sprite := Sprite2D.new()
		sprite.texture = load(tex_path)
		sprite.position = Vector2(-100, 0)
		sprite.scale = Vector2(0.15, 0.15)
		add_child(sprite)
		print("[TEST] Bed PNG loaded OK at scale 0.15")
	else:
		print("[TEST] ERROR: Bed PNG not found at: ", tex_path)

	# Test another
	var tex2 := "res://assets/furniture/sofa/Sofa 1.png"
	if ResourceLoader.exists(tex2):
		var sprite2 := Sprite2D.new()
		sprite2.texture = load(tex2)
		sprite2.position = Vector2(100, 0)
		sprite2.scale = Vector2(0.15, 0.15)
		add_child(sprite2)
		print("[TEST] Sofa PNG loaded OK")
	else:
		print("[TEST] ERROR: Sofa PNG not found at: ", tex2)

	# Player
	var player: CharacterBody2D = _player_scene.instantiate()
	add_child(player)
	player.position = Vector2(0, 50)

	# Setup player with data
	var data := CharacterData.new()
	data.character_name = "gritty"
	data.display_name = "Gritty"
	data.sprite_path = "res://assets/characters/Gritty.png"
	data.starting_hunger = 100.0
	data.starting_energy = 100.0
	data.starting_fun = 100.0
	player.setup(data)

	# Force PLAYING
	GameState.change_state(GameState.State.PLAYING)
	GameClock.resume()

	print("[TEST] GameState: ", GameState.State.keys()[GameState.current_state])
	print("[TEST] Scene ready, player at: ", player.position)
