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
@onready var location_label: Label = $HUD/LocationLabel
@onready var title_screen: Control = $HUD/TitleScreen
@onready var day_split: Control = $HUD/DaySplitScreen
@onready var commute_anim: Control = $HUD/CommuteAnimation
@onready var day_summary: Control = $HUD/DaySummary
@onready var decision_day: Control = $HUD/DecisionDay
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager
@onready var mission_manager: MissionManager = $Systems/MissionManager
@onready var college_progress: CollegeProgress = $Systems/CollegeProgress
@onready var college_system: CollegeSystem = $Systems/CollegeSystem
@onready var world: Node2D = $World

const SLEEP_WARNING_HOUR := 23
const FORCE_END_HOUR := 0
const NO_SLEEP_PENALTY := 30.0

const LOCATION_NAMES := {
	"favela_bedroom": "🏠 Quarto do Gritty",
	"favela_kitchen": "🏠 Cozinha do Gritty",
	"mansion": "🏰 Quarto da Smartle",
	"mansion_kitchen": "🏰 Cozinha da Smartle",
	"school": "🏫 Escola Bilingue",
}

var _sleep_warned: bool = false
var _day_ended: bool = false

var gritty_player: CharacterBody2D = null
var smartle_player: CharacterBody2D = null
var _player_scene: PackedScene = preload("res://scenes/characters/Player.tscn")
var _pending_player_placement: Dictionary = {}  # Used after scene swap


func _ready() -> void:
	pause_overlay.visible = false
	day_banner.visible = false

	# Show title screen first — game starts paused
	GameState.change_state(GameState.State.IN_MENU)
	GameClock.pause()
	title_screen.start_game.connect(_on_title_start)

	SceneManager.setup(world, fade_overlay)
	SceneManager.location_changed.connect(_on_location_changed)

	_create_players()
	_load_starting_locations()

	GameState.state_changed.connect(_on_state_changed)
	GameClock.hour_changed.connect(_on_hour_changed)
	GameClock.day_changed.connect(_on_day_changed)
	CharacterManager.character_switched.connect(_on_character_switched)
	interaction_popup.action_confirmed.connect(_on_action_confirmed)
	interaction_popup.alt_action_confirmed.connect(_on_alt_action_confirmed)
	interaction_popup.popup_closed.connect(_on_popup_closed)
	sat_quiz.quiz_completed.connect(_on_quiz_completed)
	day_split.continue_day.connect(func(): pass)  # Just closes itself
	commute_anim.commute_done.connect(func(): pass)
	day_summary.summary_closed.connect(func(): pass)
	schedule_manager.add_to_group("schedule_manager")
	mission_manager.add_to_group("mission_manager")
	mission_panel.setup(mission_manager)
	mission_manager.generate_missions("gritty")
	mission_manager.generate_missions("smartle")
	college_system.setup_default_lists()


func _on_title_start() -> void:
	title_screen.visible = false
	# Show split screen for day 1
	day_split.show_split(1, _get_needs(gritty_player), _get_needs(smartle_player))
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

	var smartle_data := CharacterData.new()
	smartle_data.character_name = "smartle"
	smartle_data.display_name = "Smartle"
	smartle_data.sprite_path = "res://assets/characters/Smartle.png"
	smartle_data.starting_hunger = 80.0
	smartle_data.starting_energy = 85.0
	smartle_data.starting_fun = 70.0
	smartle_data.overnight_recovery = 85.0

	gritty_player.character_data = gritty_data
	smartle_player.character_data = smartle_data


func _load_starting_locations() -> void:
	var favela := SceneManager.load_location_immediate("favela_bedroom")
	var ysort: Node2D = favela.get_node("YSortRoot")
	ysort.add_child(gritty_player)
	gritty_player.position = favela.get_spawn_world_pos()

	# Inactive player holder (hidden)
	var holder := Node2D.new()
	holder.name = "InactivePlayerHolder"
	holder.visible = false
	add_child(holder)
	holder.add_child(smartle_player)

	_update_location_label("favela_bedroom")
	call_deferred("_setup_players")


func _setup_players() -> void:
	gritty_player.setup(gritty_player.character_data)
	smartle_player.setup(smartle_player.character_data)


# ======== SCENE TRANSITIONS ========

func _on_character_switched(active_name: String) -> void:
	var active := CharacterManager.get_active_player()
	var inactive := CharacterManager.get_inactive_player()
	var target := SceneManager.get_location(active_name)

	# Park inactive in holder
	_park_player(inactive)

	# Remove active from current location
	_park_player(active)

	# Schedule placement after scene loads
	_pending_player_placement = {"player": active, "target": target}
	SceneManager.change_location(target, active_name)


func _on_location_changed(_character: String, location: String) -> void:
	# Place player after scene swap completes
	if not _pending_player_placement.is_empty():
		var player: CharacterBody2D = _pending_player_placement.player
		var loc := SceneManager.get_current_location_node()
		if loc:
			var ysort: Node2D = loc.get_node("YSortRoot")
			if player.get_parent():
				player.get_parent().remove_child(player)
			ysort.add_child(player)
			player.position = loc.get_spawn_world_pos()

			# If both at same location (school), show both
			var other := CharacterManager.get_inactive_player()
			if other:
				var other_needs: NeedsComponent = other.get_node_or_null("NeedsComponent")
				if other_needs and SceneManager.get_location(other_needs.character_name) == location:
					_park_player(other)
					ysort.add_child(other)
					other.position = loc.get_spawn_world_pos() + Vector2(80, 40)

		_pending_player_placement = {}
	_update_location_label(location)


func _use_door(door: DoorObject) -> void:
	var player := CharacterManager.get_active_player()
	if not player:
		return
	var needs := CharacterManager.get_active_needs()
	var target: String = door.target_location

	# "home" resolves to character's home bedroom
	if target == "home":
		if needs and needs.character_name == "gritty":
			target = "favela_bedroom"
		elif needs and needs.character_name == "smartle":
			target = "mansion"
		else:
			target = "favela_bedroom"

	var char_name: String = needs.character_name if needs else ""
	if char_name != "":
		SceneManager.character_locations[char_name] = target

	# If going to school, show commute animation first
	if target == "school" and needs:
		var mode := "bus" if char_name == "gritty" else "car"
		var travel := 45 if char_name == "gritty" else 15
		commute_anim.show_commute(char_name, mode, travel)
		commute_anim.commute_done.connect(func():
			_do_door_transition(player, target, char_name)
		, CONNECT_ONE_SHOT)
		return

	_do_door_transition(player, target, char_name)


func _do_door_transition(player: CharacterBody2D, target: String, char_name: String) -> void:
	# Park players
	_park_player(player)
	var other := CharacterManager.get_inactive_player()
	if other and other.get_parent() and other.get_parent().name == "YSortRoot":
		_park_player(other)

	_pending_player_placement = {"player": player, "target": target}
	SceneManager.change_location(target, char_name)


func _park_player(player: CharacterBody2D) -> void:
	if not player:
		return
	if player.get_parent() and player.get_parent() != $InactivePlayerHolder:
		player.get_parent().remove_child(player)
		$InactivePlayerHolder.add_child(player)


# ======== DAY CYCLE ========

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

	# Update college checklist
	college_system.update_checklist("gritty", _get_needs(gritty_player).sat_score)
	college_system.update_checklist("smartle", _get_needs(smartle_player).sat_score)

	# Show morning split screen
	day_split.show_split(day, _get_needs(gritty_player), _get_needs(smartle_player))


func _force_end_day() -> void:
	_day_ended = true
	EventBus.warning_shown.emit("Voce nao dormiu! -%.0f%% energia" % NO_SLEEP_PENALTY, "red")
	_get_needs(gritty_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_get_needs(smartle_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_check_homework()
	EventBus.day_ended.emit(GameClock.game_day)

	# Track mission totals for college system
	college_system.total_missions["gritty"] += mission_manager.get_completion_count("gritty")
	college_system.total_missions["smartle"] += mission_manager.get_completion_count("smartle")

	# Show end of day summary
	day_summary.show_summary(
		GameClock.game_day,
		_get_needs(gritty_player), _get_needs(smartle_player),
		mission_manager.get_completion_count("gritty"),
		mission_manager.get_completion_count("smartle")
	)

	# Decision Day on day 7
	if GameClock.game_day >= 7:
		var gritty_results := college_system.evaluate_decisions("gritty", _get_needs(gritty_player).sat_score)
		var smartle_results := college_system.evaluate_decisions("smartle", _get_needs(smartle_player).sat_score)
		day_summary.summary_closed.connect(func():
			decision_day.show_decisions(gritty_results, smartle_results)
		, CONNECT_ONE_SHOT)


func _check_homework() -> void:
	for player in [gritty_player, smartle_player]:
		var needs := _get_needs(player)
		if not needs.homework_done:
			needs.modify_sat(-5)
			EventBus.warning_shown.emit("%s: -5 SAT (sem dever de casa!)" % needs.character_name.capitalize(), "red")
		needs.homework_done = false


func _apply_overnight_recovery() -> void:
	if gritty_player.character_data:
		_get_needs(gritty_player).modify_need("energy", gritty_player.character_data.overnight_recovery)
	if smartle_player.character_data:
		_get_needs(smartle_player).modify_need("energy", smartle_player.character_data.overnight_recovery)


func _get_needs(player: CharacterBody2D) -> NeedsComponent:
	return player.get_node("NeedsComponent") as NeedsComponent


# ======== UI ========

func _update_location_label(location: String) -> void:
	location_label.text = LOCATION_NAMES.get(location, location)


func _show_day_banner(day: int) -> void:
	day_banner.text = "Dia %d" % day
	day_banner.visible = true
	var tween := create_tween()
	tween.tween_property(day_banner, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0))
	tween.tween_interval(2.5)
	tween.tween_property(day_banner, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): day_banner.visible = false)


# ======== INTERACTION ========

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

	if not executor.study_completed.is_connected(_on_study_completed):
		executor.study_completed.connect(_on_study_completed)

	executor.execute(obj, needs)
	executor.action_completed.connect(func(text: String):
		if text != "":
			EventBus.warning_shown.emit(text, "yellow")
		college_progress.check_score(needs.character_name, needs.sat_score)
	, CONNECT_ONE_SHOT)
	player.unlock_from_action()


func _on_alt_action_confirmed(obj: GameObject) -> void:
	## Execute the alt action (e.g., "Jogar" on a desk)
	var player := CharacterManager.get_active_player()
	if not player:
		return
	var needs: NeedsComponent = player.get_node("NeedsComponent")

	# Advance clock
	for i in range(obj.alt_time_cost):
		GameClock._advance_minute()

	# Restore alt need
	if obj.alt_need_affected != "":
		var restore: float = obj.alt_base_restore * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0)
		needs.modify_need(obj.alt_need_affected, restore)
		var icon := ""
		match obj.alt_need_affected:
			"fun": icon = "🎮"
			"energy": icon = "⚡"
			"hunger": icon = "🍖"
		EventBus.warning_shown.emit("+%.0f %s %s" % [restore, icon, obj.alt_need_affected.capitalize()], "yellow")

		# Mission event
		var mm := get_tree().get_first_node_in_group("mission_manager") as MissionManager
		if mm:
			mm.complete_mission_by_event(needs.character_name, "action_fun")
			mm.complete_mission_by_event(needs.character_name, "action_any")

	player.unlock_from_action()


func _on_popup_closed() -> void:
	var player := CharacterManager.get_active_player()
	if player:
		player.unlock_from_action()


func _on_study_completed(_character: String) -> void:
	sat_quiz.show_quiz()


func _on_quiz_completed(correct: bool, sat_bonus: int) -> void:
	if correct and sat_bonus > 0:
		var needs := CharacterManager.get_active_needs()
		if needs:
			needs.modify_sat(sat_bonus)
			EventBus.warning_shown.emit("+%d SAT (resposta correta!)" % sat_bonus, "yellow")
			college_progress.check_score(needs.character_name, needs.sat_score)
