extends Node2D

## Main scene — root of the game. Manages locations, characters, HUD, day cycle.

@onready var warning_popup: Control = $HUD/WarningPopup
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var fade_overlay: ColorRect = $HUD/FadeOverlay
@onready var day_banner: Label = $HUD/DayBanner
@onready var interaction_popup: PanelContainer = $HUD/InteractionPopup
@onready var dialogue_box: PanelContainer = $HUD/DialogueBox
@onready var sat_quiz: PanelContainer = $HUD/SATQuiz
@onready var mission_panel: PanelContainer = $HUD/MissionPanel
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager
@onready var mission_manager: MissionManager = $Systems/MissionManager
@onready var college_progress: CollegeProgress = $Systems/CollegeProgress
@onready var world: Node2D = $World

const SLEEP_WARNING_HOUR := 23
const FORCE_END_HOUR := 0
const NO_SLEEP_PENALTY := 30.0

var _sleep_warned: bool = false
var _day_ended: bool = false

# Player nodes — created dynamically
var gritty_player: CharacterBody2D = null
var smartle_player: CharacterBody2D = null
var _player_scene: PackedScene = preload("res://scenes/characters/Player.tscn")


func _ready() -> void:
	pause_overlay.visible = false
	day_banner.visible = false

	# Setup scene manager
	SceneManager.setup(world, fade_overlay)

	# Create players
	_create_players()

	# Load starting locations
	_load_starting_locations()

	# Connect signals
	GameState.state_changed.connect(_on_state_changed)
	GameClock.hour_changed.connect(_on_hour_changed)
	GameClock.day_changed.connect(_on_day_changed)
	CharacterManager.character_switched.connect(_on_character_switched)
	interaction_popup.action_confirmed.connect(_on_action_confirmed)
	interaction_popup.popup_closed.connect(_on_popup_closed)
	sat_quiz.quiz_completed.connect(_on_quiz_completed)
	schedule_manager.add_to_group("schedule_manager")
	mission_manager.add_to_group("mission_manager")

	# Setup mission panel
	mission_panel.setup(mission_manager)

	# Generate initial missions
	mission_manager.generate_missions("gritty")
	mission_manager.generate_missions("smartle")

	_show_day_banner(GameClock.game_day)


func _create_players() -> void:
	gritty_player = _player_scene.instantiate()
	smartle_player = _player_scene.instantiate()

	var gritty_data := CharacterData.new()
	gritty_data.character_name = "gritty"
	gritty_data.display_name = "Gritty"
	gritty_data.sprite_path = "res://assets/characters/Gritty.png"
	gritty_data.starting_hunger = 50.0
	gritty_data.starting_energy = 45.0
	gritty_data.starting_fun = 60.0
	gritty_data.overnight_recovery = 50.0
	gritty_data.commute_mode = "bus"
	gritty_data.commute_leave_by = 435
	gritty_data.commute_travel_time = 45
	gritty_data.commute_energy_cost = 15.0

	var smartle_data := CharacterData.new()
	smartle_data.character_name = "smartle"
	smartle_data.display_name = "Smartle"
	smartle_data.sprite_path = "res://assets/characters/Smartle.png"
	smartle_data.starting_hunger = 80.0
	smartle_data.starting_energy = 85.0
	smartle_data.starting_fun = 70.0
	smartle_data.overnight_recovery = 85.0
	smartle_data.commute_mode = "car"
	smartle_data.commute_leave_by = 465
	smartle_data.commute_travel_time = 15
	smartle_data.commute_energy_cost = 5.0

	# Setup must happen after adding to tree, so defer
	gritty_player.character_data = gritty_data
	smartle_player.character_data = smartle_data


func _load_starting_locations() -> void:
	# Load Gritty's favela — active player starts here
	var favela := SceneManager.load_location_immediate("favela")
	var ysort: Node2D = favela.get_node("YSortRoot")

	# Add Gritty to favela (active)
	ysort.add_child(gritty_player)
	gritty_player.position = favela.get_spawn_world_pos()

	# Smartle starts off-tree — she'll be placed when Tab switches to her
	# But we still need her in the tree for NeedsComponent to tick
	# Add her to a hidden holder node
	var holder := Node2D.new()
	holder.name = "InactivePlayerHolder"
	add_child(holder)
	holder.add_child(smartle_player)
	smartle_player.position = Vector2.ZERO

	# Defer setup
	call_deferred("_setup_players")


func _setup_players() -> void:
	gritty_player.setup(gritty_player.character_data)
	smartle_player.setup(smartle_player.character_data)


func _on_character_switched(active_name: String) -> void:
	var active_player := CharacterManager.get_active_player()
	var inactive_player := CharacterManager.get_inactive_player()
	var target_location := SceneManager.get_location(active_name)

	# Move inactive player to holder
	if inactive_player and inactive_player.get_parent():
		var old_parent := inactive_player.get_parent()
		old_parent.remove_child(inactive_player)
		$InactivePlayerHolder.add_child(inactive_player)

	# Remove active player from wherever it is
	if active_player.get_parent():
		active_player.get_parent().remove_child(active_player)

	# Load the target location with fade
	await SceneManager.change_location(target_location, active_name)
	var loc_node := SceneManager.get_current_location_node()

	# Place active player in the new location
	var ysort: Node2D = loc_node.get_node("YSortRoot")
	ysort.add_child(active_player)
	active_player.position = loc_node.get_spawn_world_pos()


func _on_state_changed(_old: GameState.State, new_state: GameState.State) -> void:
	pause_overlay.visible = (new_state == GameState.State.PAUSED)


func _on_hour_changed(hour: int) -> void:
	if hour == SLEEP_WARNING_HOUR and not _sleep_warned:
		_sleep_warned = true
		EventBus.warning_shown.emit("Hora de dormir!", "yellow")
	if hour == FORCE_END_HOUR and not _day_ended:
		_force_end_day()


func _on_day_changed(day: int) -> void:
	_sleep_warned = false
	_day_ended = false
	_apply_overnight_recovery()
	_show_day_banner(day)
	EventBus.day_started.emit(day)


func _force_end_day() -> void:
	_day_ended = true
	EventBus.warning_shown.emit("Voce nao dormiu! -%.0f%% energia" % NO_SLEEP_PENALTY, "red")
	_get_needs(gritty_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_get_needs(smartle_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_check_homework()
	EventBus.day_ended.emit(GameClock.game_day)


func _check_homework() -> void:
	for player in [gritty_player, smartle_player]:
		var needs := _get_needs(player)
		if not needs.homework_done:
			needs.modify_sat(-5)
			EventBus.warning_shown.emit("%s: -5 SAT (sem dever de casa!)" % needs.character_name.capitalize(), "red")
		needs.homework_done = false  # Reset for next day


func _apply_overnight_recovery() -> void:
	if gritty_player.character_data:
		_get_needs(gritty_player).modify_need("energy", gritty_player.character_data.overnight_recovery)
	if smartle_player.character_data:
		_get_needs(smartle_player).modify_need("energy", smartle_player.character_data.overnight_recovery)


func _get_needs(player: CharacterBody2D) -> NeedsComponent:
	return player.get_node("NeedsComponent") as NeedsComponent


func _show_day_banner(day: int) -> void:
	day_banner.text = "Dia %d" % day
	day_banner.visible = true
	var tween := create_tween()
	tween.tween_property(day_banner, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0))
	tween.tween_interval(2.5)
	tween.tween_property(day_banner, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): day_banner.visible = false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not interaction_popup.visible and not dialogue_box.visible and not sat_quiz.visible:
		var player := CharacterManager.get_active_player()
		if not player:
			return
		var result: Dictionary = player.try_interact()
		if result.has("type"):
			if result.type == "object":
				player.lock_for_action()
				interaction_popup.show_for_object(result.object)
			elif result.type == "door":
				_use_door(result.door)


func _on_action_confirmed(obj: GameObject) -> void:
	var player := CharacterManager.get_active_player()
	if not player:
		return
	var executor: ActionExecutor = player.get_node("ActionExecutor")
	var needs: NeedsComponent = player.get_node("NeedsComponent")

	# Connect study_completed to trigger quiz
	if not executor.study_completed.is_connected(_on_study_completed):
		executor.study_completed.connect(_on_study_completed)

	executor.execute(obj, needs)
	# Show result
	executor.action_completed.connect(func(text: String):
		if text != "":
			EventBus.warning_shown.emit(text, "yellow")
		# Check college milestones
		college_progress.check_score(needs.character_name, needs.sat_score)
	, CONNECT_ONE_SHOT)
	player.unlock_from_action()


func _on_popup_closed() -> void:
	var player := CharacterManager.get_active_player()
	if player:
		player.unlock_from_action()


func _on_study_completed(_character: String) -> void:
	# Show SAT quiz after study action
	sat_quiz.show_quiz()


func _on_quiz_completed(correct: bool, sat_bonus: int) -> void:
	if correct and sat_bonus > 0:
		var needs := CharacterManager.get_active_needs()
		if needs:
			needs.modify_sat(sat_bonus)
			EventBus.warning_shown.emit("+%d SAT (resposta correta!)" % sat_bonus, "yellow")
			college_progress.check_score(needs.character_name, needs.sat_score)


func _use_door(door: DoorObject) -> void:
	var player := CharacterManager.get_active_player()
	var other := CharacterManager.get_inactive_player()
	if not player:
		return
	var needs := CharacterManager.get_active_needs()
	var target: String = door.target_location

	# "home" means go to character's home location
	if target == "home":
		target = "favela" if needs and needs.character_name == "gritty" else "mansion"

	# Update character location tracking
	if needs:
		SceneManager.character_locations[needs.character_name] = target

	# Remove player from current location
	if player.get_parent():
		player.get_parent().remove_child(player)

	# If leaving a shared location (school), remove other player too
	if other and other.get_parent() and other.get_parent().name == "YSortRoot":
		other.get_parent().remove_child(other)
		$InactivePlayerHolder.add_child(other)

	# Transition with fade
	var char_name: String = needs.character_name if needs else ""
	await SceneManager.change_location(target, char_name)
	var loc_node := SceneManager.get_current_location_node()

	# Place active player in new location
	var ysort: Node2D = loc_node.get_node("YSortRoot")
	ysort.add_child(player)
	player.position = loc_node.get_spawn_world_pos()

	# If both characters are at the same location (school), show both
	if other and needs:
		var other_needs: NeedsComponent = other.get_node("NeedsComponent")
		if other_needs and SceneManager.get_location(other_needs.character_name) == target:
			if other.get_parent():
				other.get_parent().remove_child(other)
			ysort.add_child(other)
			other.position = loc_node.get_spawn_world_pos() + Vector2(80, 40)
