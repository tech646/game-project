extends Control

## Title screen with two pages:
## Page 1: Story + characters walking
## Page 2: Tutorial (how to play)

signal start_game
signal continue_game

@onready var title: Label = $VBox/Title
@onready var subtitle: Label = $VBox/Subtitle
@onready var narrative: Label = $VBox/Narrative
@onready var next_btn: Button = $VBox/NextBtn
@onready var play_btn: Button = $VBox/PlayBtn
@onready var continue_btn: Button = $VBox/ContinueBtn
@onready var smartle_sprite: Sprite2D = $SmartleWalk
@onready var gritty_sprite: Sprite2D = $GrittyWalk

var _page := 1
var _walk_time := 0.0

var _story_text := (
	"Two students. Same dream. Different worlds.\n\n" +
	"Smartle lives in the favela. She is a first-generation student;\n" +
	"her mother has raised her alone while struggling to make ends meet.\n" +
	"She rides a packed bus 2 hours to school and 2 hours back home.\n" +
	"She has learned to use that 'wasted time' to study for tests.\n\n" +
	"While Gritty's family can afford a good private school, Smartle\n" +
	"only attends the same institution because she was granted a\n" +
	"merit scholarship. She counts every coin for food.\n\n" +
	"Gritty is middle class. Both his parents graduated from universities\n" +
	"and have supported him during his college application process.\n" +
	"He lives close to school, eats balanced meals prepared by his mother,\n" +
	"and practices sports 4 times a week to relieve stress.\n\n" +
	"They both dream of getting into a US college.\n" +
	"But the path couldn't be more different."
)

var _tutorial_text := (
	"HOW TO PLAY\n\n" +
	"Arrow Keys -- Move your character\n" +
	"Enter -- Interact with objects and doors\n" +
	"Tab -- Switch between Smartle and Gritty\n" +
	"Space -- Pause menu (speed control)\n\n" +
	"GOALS\n\n" +
	"- Study to earn coins and SAT points\n" +
	"- Answer SAT questions correctly for bonus coins\n" +
	"- Use coins to buy food, school supplies, and college apps\n" +
	"- Take care of Hunger, Energy, Fun, and Mental Health\n" +
	"- Complete daily missions for extra coins\n" +
	"- Check 'My Journey' to invest in your future\n\n" +
	"Smartle must spend coins on survival (bus, food, internet).\n" +
	"Gritty's family covers those costs.\n\n" +
	"On Day 7, college decision letters arrive!\n" +
	"Can both students achieve their dream?"
)


func _ready() -> void:
	next_btn.pressed.connect(_on_next)
	play_btn.pressed.connect(_on_play)
	continue_btn.pressed.connect(_on_continue)
	play_btn.visible = false
	continue_btn.visible = SaveSystem.has_save()
	set_process_unhandled_input(true)
	_show_page_1()
	_load_character_sprites()


func _load_character_sprites() -> void:
	# Load Smartle happy frame
	var smartle_tex := load("res://assets/characters/animations/smartle/Smartle_Happy1.png")
	if smartle_tex:
		smartle_sprite.texture = smartle_tex
		var scale := 100.0 / float(smartle_tex.get_height())
		smartle_sprite.scale = Vector2(scale, scale)
		smartle_sprite.position = Vector2(200, 500)
		smartle_sprite.visible = true
	else:
		smartle_sprite.visible = false

	# Load Gritty happy frame
	var gritty_tex := load("res://assets/characters/animations/gritty/Gritty_Happy1.png")
	if gritty_tex:
		gritty_sprite.texture = gritty_tex
		var scale := 100.0 / float(gritty_tex.get_height())
		gritty_sprite.scale = Vector2(scale, scale)
		gritty_sprite.position = Vector2(1080, 500)
		gritty_sprite.visible = true
	else:
		gritty_sprite.visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	# Animate walking characters
	_walk_time += delta * 5.0
	var frame := int(_walk_time) % 4 + 1

	# Cycle Smartle frames
	var s_path := "res://assets/characters/animations/smartle/Smartle_Happy%d.png" % frame
	if ResourceLoader.exists(s_path):
		smartle_sprite.texture = load(s_path)

	# Cycle Gritty frames
	var g_path := "res://assets/characters/animations/gritty/Gritty_Happy%d.png" % frame
	if ResourceLoader.exists(g_path):
		gritty_sprite.texture = load(g_path)

	# Gentle bob
	smartle_sprite.position.y = 500 + sin(_walk_time) * 3.0
	gritty_sprite.position.y = 500 + sin(_walk_time + 1.0) * 3.0


func _show_page_1() -> void:
	_page = 1
	title.text = "Education as Path Out of Poverty"
	subtitle.text = "Same dream. Different paths."
	narrative.text = _story_text
	next_btn.text = "Next >"
	next_btn.visible = true
	play_btn.visible = false


func _show_page_2() -> void:
	_page = 2
	title.text = "Education as Path Out of Poverty"
	subtitle.text = ""
	narrative.text = _tutorial_text
	next_btn.visible = false
	play_btn.text = "PLAY"
	play_btn.visible = true


func _on_next() -> void:
	_show_page_2()


func _on_play() -> void:
	set_process_unhandled_input(false)
	start_game.emit()


func _on_continue() -> void:
	set_process_unhandled_input(false)
	continue_game.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		if _page == 1:
			_show_page_2()
		elif _page == 2:
			_on_play()
		get_viewport().set_input_as_handled()
