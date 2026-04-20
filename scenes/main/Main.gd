extends Node2D

## Main scene — root of the game. Manages locations, characters, HUD, day cycle.

@onready var warning_popup: Control = $HUD/WarningPopup
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var pause_menu: PanelContainer = $HUD/PauseMenu
@onready var fade_overlay: ColorRect = $HUD/FadeOverlay
@onready var day_banner: Label = $HUD/DayBanner
@onready var interaction_popup: PanelContainer = $HUD/InteractionPopup
@onready var dialogue_box: PanelContainer = $HUD/DialogueBox
@onready var sat_quiz: PanelContainer = $HUD/SATQuiz
@onready var mission_panel: PanelContainer = $HUD/MissionPanel
@onready var location_label: Label = $HUD/LocationLabel
@onready var objective_label: Label = $HUD/ObjectiveLabel
@onready var controls_hint: PanelContainer = $HUD/ControlsHint
@onready var title_screen: Control = $HUD/TitleScreen
@onready var day_split: Control = $HUD/DaySplitScreen
@onready var commute_anim: Control = $HUD/CommuteAnimation
@onready var day_summary: Control = $HUD/DaySummary
@onready var decision_day: Control = $HUD/DecisionDay
@onready var upgrade_shop: PanelContainer = $HUD/UpgradeShop
@onready var journey_panel: PanelContainer = $HUD/JourneyPanel
@onready var journey_btn: Button = $HUD/BottomButtons/JourneyBtn
@onready var missions_btn: Button = $HUD/BottomButtons/MissionsBtn
@onready var sat_full_test: PanelContainer = $HUD/SATFullTest
@onready var needs_bars_panel: PanelContainer = $HUD/NeedsBars
# Room score removed from HUD — shown in pause menu instead
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager
@onready var mission_manager: MissionManager = $Systems/MissionManager
@onready var college_progress: CollegeProgress = $Systems/CollegeProgress
@onready var college_system: CollegeSystem = $Systems/CollegeSystem
@onready var coin_system: CoinSystem = $Systems/CoinSystem
@onready var furniture_system: FurnitureUpgradeSystem = $Systems/FurnitureUpgradeSystem
@onready var tutorial_system: TutorialSystem = $Systems/TutorialSystem
@onready var tutorial_overlay: Control = $HUD/TutorialOverlay
@onready var world: Node2D = $World

const SLEEP_WARNING_HOUR := 23
const FORCE_END_HOUR := 0
const NO_SLEEP_PENALTY := 30.0

const LOCATION_NAMES := {
	"favela_bedroom": "Smartle's Bedroom",
	"favela_kitchen": "Smartle's Kitchen",
	"mansion": "Gritty's Bedroom",
	"mansion_kitchen": "Gritty's Kitchen",
	"classroom": "Classroom",
	"library": "Library",
	"cafeteria": "Cafeteria",
	"gym": "Gym",
}

var _sleep_warned: bool = false
var _day_ended: bool = false
var _gritty_day_done: bool = false
var _smartle_day_done: bool = false

# Journey tracking — each character plays 7 days independently
var _smartle_journey_complete: bool = false
var _gritty_journey_complete: bool = false
var _current_journey_character: String = "smartle"  # Who is currently playing their 7 days

var gritty_player: CharacterBody2D = null
var smartle_player: CharacterBody2D = null
var _player_scene: PackedScene = preload("res://scenes/characters/Player.tscn")
var _pending_player_placement: Dictionary = {}  # Used after scene swap


func _ready() -> void:
	pause_overlay.visible = false
	day_banner.visible = false

	# Register systems in groups FIRST
	schedule_manager.add_to_group("schedule_manager")
	mission_manager.add_to_group("mission_manager")
	coin_system.add_to_group("coin_system")
	furniture_system.add_to_group("furniture_upgrade_system")
	furniture_system.setup_defaults()
	college_system.setup_default_lists()

	# Journey system
	var journey_sys := $Systems/JourneySystem
	journey_sys.add_to_group("journey_system")
	journey_btn.pressed.connect(_on_open_upgrades)
	missions_btn.pressed.connect(_on_toggle_missions)

	# Curfew system (random favela lockdown for Smartle)
	var curfew_sys := $Systems/CurfewSystem
	curfew_sys.add_to_group("curfew_system")

	# Setup scene manager
	SceneManager.setup(world, fade_overlay)
	SceneManager.location_changed.connect(_on_location_changed)

	# Create and load
	_create_players()
	_load_starting_locations()

	# Connect signals
	pause_menu.open_upgrades.connect(_on_open_upgrades)
	GameState.state_changed.connect(_on_state_changed)
	GameClock.hour_changed.connect(_on_hour_changed)
	GameClock.time_tick.connect(_on_time_tick)
	GameClock.day_changed.connect(_on_day_changed)
	CharacterManager.character_switched.connect(_on_character_switched)
	interaction_popup.action_confirmed.connect(_on_action_confirmed)
	interaction_popup.alt_action_confirmed.connect(_on_alt_action_confirmed)
	interaction_popup.popup_closed.connect(_on_popup_closed)
	sat_quiz.quiz_completed.connect(_on_quiz_completed)
	sat_full_test.test_completed.connect(_on_full_test_completed)
	decision_day.game_ended.connect(_on_game_ended)
	decision_day.play_other_character.connect(_on_play_other_character)
	coin_system.coins_changed.connect(_on_coins_changed)
	furniture_system.furniture_upgraded.connect(_on_furniture_upgraded)
	title_screen.start_game.connect(_on_title_start)
	title_screen.continue_game.connect(_on_continue_game)
	day_split.continue_day.connect(_on_split_continue)

	# Setup UI
	mission_panel.setup(mission_manager)
	mission_manager.generate_missions("gritty")
	mission_manager.generate_missions("smartle")
	_update_coins_label()

	# Tutorial setup
	tutorial_system.step_changed.connect(_on_tutorial_step_changed)
	tutorial_system.tutorial_finished.connect(_on_tutorial_finished)
	tutorial_overlay.skip_pressed.connect(_on_tutorial_skip)
	tutorial_overlay.next_pressed.connect(_on_tutorial_next)

	# Start paused — show title screen
	GameState.change_state(GameState.State.IN_MENU)
	GameClock.pause()


func _on_continue_game() -> void:
	title_screen.visible = false
	title_screen.set_process_unhandled_input(false)

	# Load saved data
	var data := SaveSystem.load_game()
	if not data.is_empty():
		SaveSystem.apply_save_data(
			data,
			_get_needs(gritty_player),
			_get_needs(smartle_player),
			coin_system,
			furniture_system,
			college_system,
		)
		# Restore character times
		if data.has("character_times"):
			GameClock._character_times = data["character_times"]
		# Restore locations
		if data.has("character_locations"):
			for key in data["character_locations"]:
				SceneManager.character_locations[key] = data["character_locations"][key]

	# Start playing with Smartle's time
	GameClock.restore_time_for("smartle")
	GameState.change_state(GameState.State.PLAYING)
	GameClock.resume()
	_update_coins_label()
	EventBus.warning_shown.emit("Game loaded! Welcome back.", "yellow")


func _on_title_start() -> void:
	title_screen.visible = false
	title_screen.set_process_unhandled_input(false)
	# Show morning split screen
	call_deferred("_show_morning_split")


func _show_morning_split() -> void:
	day_split.show_split(GameClock.game_day, _get_needs(gritty_player), _get_needs(smartle_player))


func _on_split_continue() -> void:
	# Smartle wakes up at 5:00 (needs 2h bus to arrive by 8:00, plus prep time)
	GameClock.game_hour = 5
	GameClock.game_minute = 0
	GameClock.save_time_for("smartle")

	# Gritty wakes up at 7:00 (only 20min car ride)
	GameClock.game_hour = 7
	GameClock.game_minute = 0
	GameClock.save_time_for("gritty")

	# Start with Smartle's time (she's the active player)
	GameClock.restore_time_for("smartle")

	# Start playing!
	GameState.change_state(GameState.State.PLAYING)
	GameClock.resume()
	_show_day_banner(GameClock.game_day)

	# Start tutorial on day 1
	if GameClock.game_day == 1:
		tutorial_system.start()
	_update_room_score()
	_update_coins_label()


func _create_players() -> void:
	gritty_player = _player_scene.instantiate()
	smartle_player = _player_scene.instantiate()

	# GRITTY — middle class, parents work hard for his education
	var gritty_data := CharacterData.new()
	gritty_data.character_name = "gritty"
	gritty_data.display_name = "Gritty"
	gritty_data.sprite_path = "res://assets/characters/Gritty.png"
	gritty_data.starting_hunger = 100.0
	gritty_data.starting_energy = 100.0
	gritty_data.starting_fun = 100.0
	gritty_data.overnight_recovery = 75.0  # Decent bed, good rest

	# SMARTLE — lives in favela, fewer resources but determined
	var smartle_data := CharacterData.new()
	smartle_data.character_name = "smartle"
	smartle_data.display_name = "Smartle"
	smartle_data.sprite_path = "res://assets/characters/Smartle.png"
	smartle_data.starting_hunger = 100.0
	smartle_data.starting_energy = 100.0
	smartle_data.starting_fun = 100.0
	smartle_data.overnight_recovery = 50.0  # Old bed, less recovery

	gritty_player.character_data = gritty_data
	smartle_player.character_data = smartle_data


func _load_starting_locations() -> void:
	# Smartle starts in favela bedroom (active player)
	var favela := SceneManager.load_location_immediate("favela_bedroom")
	var ysort: Node2D = favela.get_node("YSortRoot")
	ysort.add_child(smartle_player)
	smartle_player.position = favela.get_spawn_world_pos()

	# Gritty goes in hidden holder (inactive until Tab)
	var holder := Node2D.new()
	holder.name = "InactivePlayerHolder"
	holder.visible = false
	add_child(holder)
	holder.add_child(gritty_player)

	_update_location_label("favela_bedroom")
	call_deferred("_setup_players")


func _setup_players() -> void:
	# Smartle registered FIRST — she's the active player on screen
	smartle_player.setup(smartle_player.character_data)
	gritty_player.setup(gritty_player.character_data)


# ======== SCENE TRANSITIONS ========

func _on_character_switched(active_name: String) -> void:
	var active := CharacterManager.get_active_player()
	var inactive := CharacterManager.get_inactive_player()
	var target := SceneManager.get_location(active_name)
	_update_objective_label()

	# Save current character's time before switching
	if inactive:
		var inactive_needs: NeedsComponent = inactive.get_node_or_null("NeedsComponent")
		if inactive_needs:
			GameClock.save_time_for(inactive_needs.character_name)

	# Restore the new character's time
	GameClock.restore_time_for(active_name)

	# Check if the new character's day is already done
	var new_day_done := (_gritty_day_done and active_name == "gritty") or (_smartle_day_done and active_name == "smartle")
	if new_day_done:
		GameClock.pause()
		EventBus.warning_shown.emit("%s's day is already done!" % active_name.capitalize(), "yellow")
	else:
		GameClock.resume()

	# Park inactive in holder
	_park_player(inactive)

	# Remove active from current location
	_park_player(active)

	# Schedule placement after scene loads
	_pending_player_placement = {"player": active, "target": target}
	SceneManager.change_location(target, active_name)


func _on_location_changed(_character: String, location: String) -> void:
	# Tutorial hooks
	if location.ends_with("_kitchen"):
		_tutorial_event("entered_kitchen")
	elif location == "classroom":
		_tutorial_event("entered_school")

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

			# If both at school, show both in same room
			var school_locations := ["classroom", "library", "cafeteria", "gym"]
			var other := CharacterManager.get_inactive_player()
			if other and location in school_locations:
				var other_needs: NeedsComponent = other.get_node_or_null("NeedsComponent")
				if other_needs:
					var other_loc := SceneManager.get_location(other_needs.character_name)
					if other_loc in school_locations:
						# Both at school — show inactive player too
						if other.get_parent():
							other.get_parent().remove_child(other)
						ysort.add_child(other)
						other.visible = true
						other.position = loc.get_spawn_world_pos() + Vector2(60, 30)

		_pending_player_placement = {}
	_update_location_label(location)

	# Failsafe: make sure player is unlocked and game is in PLAYING state
	var active_player := CharacterManager.get_active_player()
	if active_player:
		active_player.unlock_from_action()
	if GameState.current_state != GameState.State.PLAYING and not title_screen.visible and not day_split.visible:
		GameState.change_state(GameState.State.PLAYING)


func _use_door(door: DoorObject) -> void:
	var player := CharacterManager.get_active_player()
	if not player:
		return
	var needs := CharacterManager.get_active_needs()
	var target: String = door.target_location

	# Special: upgrade shop is a UI overlay, not a location
	if target == "upgrade_shop":
		if needs:
			upgrade_shop.show_shop(needs.character_name)
		return

	# "home" resolves to character's home bedroom
	if target == "home":
		if needs and needs.character_name == "smartle":
			target = "favela_bedroom"  # Smartle lives in favela
		elif needs and needs.character_name == "gritty":
			target = "mansion"  # Gritty lives in middle-class home
		else:
			target = "favela_bedroom"

	# Smartle needs bus pass to go to school
	if target in ["classroom", "library", "cafeteria", "gym"]:
		var char_name_early: String = needs.character_name if needs else ""
		var current_loc_early := SceneManager.get_location(char_name_early) if char_name_early != "" else ""
		var already_at_school := current_loc_early in ["classroom", "library", "cafeteria", "gym"]

		# Curfew blocks Smartle from leaving home during favela violence
		if needs and needs.character_name == "smartle" and not already_at_school:
			var curfew_sys := _get_curfew_system()
			if curfew_sys and curfew_sys.is_smartle_locked_in():
				EventBus.warning_shown.emit("CURFEW! Violence in the favela. You can't leave home today.", "red")
				return

		if needs and needs.character_name == "smartle":
			var journey_sys := _get_journey_system()
			if journey_sys and not journey_sys.has_item("smartle", "bus_pass"):
				EventBus.warning_shown.emit("You need a Bus Pass to get to school! Check My Journey.", "red")
				return

		# School entry closed after 17:00 — but internal room switching is allowed
		var time := GameClock.get_total_minutes()
		if time > 1020 and not already_at_school:  # 17:00
			EventBus.warning_shown.emit("School is closed! Come back tomorrow.", "red")
			return

	# Cafeteria is always accessible but food only at meal times
	# (handled in InteractionPopup time lock check)

	var char_name: String = needs.character_name if needs else ""

	# Check commute BEFORE updating location
	var current_loc := SceneManager.get_location(char_name) if char_name != "" else ""
	var is_going_to_school := target == "classroom"
	var is_going_home := target in ["favela_bedroom", "mansion", "home"]
	var at_school := current_loc in ["classroom", "library", "cafeteria", "gym"]
	var at_home := current_loc in ["favela_kitchen", "mansion_kitchen", "favela_bedroom", "mansion"]

	# Now update location tracking
	if char_name != "":
		SceneManager.character_locations[char_name] = target

	# Track leaving school mission
	if is_going_home and at_school and char_name != "":
		var time := GameClock.get_total_minutes()
		if time <= 1020:  # Left by 17:00
			var mm := get_tree().get_first_node_in_group("mission_manager") as MissionManager
			if mm:
				mm.complete_mission_by_event(char_name, "left_school")

	if (is_going_to_school and at_home) or (is_going_home and at_school):
		# Smartle: bus 2 hours each way (120 min). Gritty: car 20 min each way.
		var mode := "bus" if char_name == "smartle" else "car"
		var travel := 120 if char_name == "smartle" else 20
		var direction := "to school" if is_going_to_school else "home"
		commute_anim.show_commute(char_name.capitalize() + " going " + direction, mode, travel)
		commute_anim.commute_done.connect(func():
			_do_door_transition(player, target, char_name)
		, CONNECT_ONE_SHOT)
		return

	_do_door_transition(player, target, char_name)


func _do_door_transition(player: CharacterBody2D, target: String, char_name: String) -> void:
	# Auto-save on every scene transition
	_auto_save()
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

func _on_state_changed(old_state: GameState.State, new_state: GameState.State) -> void:
	if new_state == GameState.State.PAUSED:
		pause_overlay.visible = true
		pause_menu.show_menu()
	elif old_state == GameState.State.PAUSED:
		pause_overlay.visible = false
		pause_menu.hide_menu()


func _on_time_tick(hour: int, minute: int) -> void:
	if _day_ended:
		return
	# Tutorial: detect player movement via active player velocity
	if tutorial_system and tutorial_system.active:
		var active_player := CharacterManager.get_active_player()
		if active_player and active_player.velocity.length() > 1.0:
			_tutorial_event("player_moved")
	# Force end of day at 23:59 if character hasn't slept
	if hour == 23 and minute >= 59:
		print("[DAY] 23:59 reached — forcing day end (day %d)" % GameClock.game_day)
		var needs := CharacterManager.get_active_needs()
		if needs:
			EventBus.warning_shown.emit("It's midnight! You fell asleep from exhaustion.", "red")
			needs.modify_need("energy", -20.0)  # Penalty for not sleeping properly
			mark_character_day_done(needs.character_name)


func _on_hour_changed(hour: int) -> void:
	if _day_ended:
		return
	if hour == SLEEP_WARNING_HOUR and not _sleep_warned:
		_sleep_warned = true
		EventBus.warning_shown.emit("Time to sleep!", "yellow")
	# At hour 23, if character hasn't slept, force them to end
	if hour == 23:
		var needs := CharacterManager.get_active_needs()
		if needs:
			var char_name := needs.character_name
			var already_done := (_gritty_day_done and char_name == "gritty") or \
								(_smartle_day_done and char_name == "smartle")
			if not already_done:
				EventBus.warning_shown.emit("It's late! You should sleep now. Your day will end soon.", "yellow")


func mark_character_day_done(character_name: String) -> void:
	## Called when the current character sleeps — their day is over.
	print("[DAY] mark_character_day_done: %s (day=%d)" % [character_name, GameClock.game_day])
	if _day_ended:
		return

	# In the new system, each character plays independently.
	# When the active character sleeps, their day ends immediately.
	_force_end_day()


func _on_day_changed(day: int) -> void:
	_sleep_warned = false
	_day_ended = false
	_gritty_day_done = false
	_smartle_day_done = false
	_apply_overnight_recovery()
	_show_day_banner(day)
	_update_objective_label()
	EventBus.day_started.emit(day)

	# Update college checklist
	college_system.update_checklist("gritty", _get_needs(gritty_player).sat_score)
	college_system.update_checklist("smartle", _get_needs(smartle_player).sat_score)

	# Show morning split screen
	day_split.show_split(day, _get_needs(gritty_player), _get_needs(smartle_player))


func _force_end_day() -> void:
	print("[DAY] _force_end_day called! day=%d" % GameClock.game_day)
	_day_ended = true
	GameClock.pause()
	_get_needs(gritty_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_get_needs(smartle_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_check_homework()
	EventBus.day_ended.emit(GameClock.game_day)
	_auto_save()

	# Track mission totals for college system
	college_system.total_missions["gritty"] += mission_manager.get_completion_count("gritty")
	college_system.total_missions["smartle"] += mission_manager.get_completion_count("smartle")

	# Award coins for completed missions
	_award_mission_coins("gritty")
	_award_mission_coins("smartle")

	# Show end of day summary
	day_summary.show_summary(
		GameClock.game_day,
		_get_needs(gritty_player), _get_needs(smartle_player),
		mission_manager.get_completion_count("gritty"),
		mission_manager.get_completion_count("smartle")
	)

	# When summary closes: advance to next day OR handle day 7 ending
	if GameClock.game_day >= 7:
		# Day 7 complete for current character!
		var current_char := _current_journey_character
		day_summary.summary_closed.connect(func():
			_handle_journey_end(current_char)
		, CONNECT_ONE_SHOT)
	else:
		# Days 1-6 — advance to next day when summary closes
		day_summary.summary_closed.connect(func():
			_advance_to_next_day()
		, CONNECT_ONE_SHOT)


func _advance_to_next_day() -> void:
	## Reset clock to 06:00 of the next day and trigger day_changed.
	## NEVER advance past day 7.
	var next_day := GameClock.game_day + 1
	print("[DAY] _advance_to_next_day: %d -> %d" % [GameClock.game_day, next_day])
	if next_day > 7:
		print("[DAY] BLOCKED — past day 7!")
		return
	GameClock.game_day = next_day
	GameClock.game_hour = 6
	GameClock.game_minute = 0
	GameClock.resume()
	GameState.change_state(GameState.State.PLAYING)
	GameClock.day_changed.emit(GameClock.game_day)
	print("[DAY] Now on day %d, clock: %s" % [GameClock.game_day, GameClock.get_time_string()])


func _handle_journey_end(character: String) -> void:
	## Called when a character finishes day 7.
	print("[DAY] Journey end for: %s" % character)

	if character == "smartle":
		_smartle_journey_complete = true
	else:
		_gritty_journey_complete = true

	# Get this character's college results
	var player := smartle_player if character == "smartle" else gritty_player
	var sat := _get_needs(player).sat_score
	var results := college_system.evaluate_decisions(character, sat)

	if _smartle_journey_complete and _gritty_journey_complete:
		# BOTH journeys complete — show COMPARATIVE final results
		var gritty_results := college_system.evaluate_decisions("gritty", _get_needs(gritty_player).sat_score)
		var smartle_results := college_system.evaluate_decisions("smartle", _get_needs(smartle_player).sat_score)
		decision_day.show_decisions(gritty_results, smartle_results)
	else:
		# Only one journey done — show their results + prompt to play the other
		var other := "Gritty" if character == "smartle" else "Smartle"
		decision_day.show_single_result(character, results, other)


func _check_homework() -> void:
	for player in [gritty_player, smartle_player]:
		var needs := _get_needs(player)
		if not needs.homework_done:
			needs.modify_sat(-5)
			EventBus.warning_shown.emit("%s: -5 SAT (no homework done!)" % needs.character_name.capitalize(), "red")
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
	if controls_hint:
		controls_hint.set_location_tip(location)
	_update_objective_label()


func _update_objective_label() -> void:
	if not objective_label:
		return
	var needs := CharacterManager.get_active_needs()
	var char_name := needs.character_name.capitalize() if needs else ""
	objective_label.text = "Day %d/7 (%s) - Goal: Study, eat, sleep. Press ENTER to interact." % [GameClock.game_day, char_name]


func _show_day_banner(day: int) -> void:
	day_banner.text = "Day %d" % day
	day_banner.visible = true
	var tween := create_tween()
	tween.tween_property(day_banner, "modulate", Color.WHITE, 0.3).from(Color(1, 1, 1, 0))
	tween.tween_interval(2.5)
	tween.tween_property(day_banner, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func(): day_banner.visible = false)


# ======== INTERACTION ========

func _can_interact() -> bool:
	## Returns true only when no overlay screen is showing.
	if interaction_popup.visible: return false
	if dialogue_box.visible: return false
	if sat_quiz.visible: return false
	if title_screen.visible: return false
	if day_split.visible: return false
	if commute_anim.visible: return false
	if day_summary.visible: return false
	if decision_day.visible: return false
	if pause_menu.visible: return false
	if upgrade_shop.visible: return false
	if journey_panel.visible: return false
	if sat_full_test.visible: return false
	if GameState.current_state != GameState.State.PLAYING: return false
	return true


func _unhandled_input(event: InputEvent) -> void:
	# Failsafe: ESC unlocks player if stuck (when no popups are open)
	if event.is_action_pressed("ui_cancel") and _can_interact():
		var player := CharacterManager.get_active_player()
		if player:
			player.unlock_from_action()
		GameState.change_state(GameState.State.PLAYING)
		return

	if event.is_action_pressed("interact") and _can_interact():
		var player := CharacterManager.get_active_player()
		if not player:
			return
		var result: Dictionary = player.try_interact()
		if result.has("type"):
			if result.type == "object":
				player.lock_for_action()
				interaction_popup.show_for_object(result.object)
			elif result.type == "furniture":
				player.lock_for_action()
				_interact_furniture(result.furniture)
			elif result.type == "door":
				_use_door(result.door)
			elif result.type == "player":
				player.lock_for_action()
				_interact_with_friend(result.player)


func _interact_with_friend(other_player: CharacterBody2D) -> void:
	## Show interaction options when near the other student.
	var my_needs := CharacterManager.get_active_needs()
	var other_needs: NeedsComponent = other_player.get_node_or_null("NeedsComponent")
	if not my_needs or not other_needs:
		CharacterManager.get_active_player().unlock_from_action()
		return

	var other_name: String = other_needs.character_name.capitalize()

	# Create temporary interaction object with friend options
	var temp := GameObject.new()
	temp.object_name = other_name
	temp.quality = 3
	temp.action_name = "Chat & Destress (30min)"
	temp.need_affected = "mental_health"
	temp.base_restore = 25.0
	temp.time_cost = 30
	temp.alt_action_name = "Study Together (1h)"
	temp.alt_need_affected = ""
	temp.alt_base_restore = 0.0
	temp.alt_time_cost = 60
	interaction_popup.show_for_object(temp)


func _on_action_confirmed(obj: GameObject) -> void:
	var player := CharacterManager.get_active_player()
	if not player:
		return
	var executor: ActionExecutor = player.get_node("ActionExecutor")
	var needs: NeedsComponent = player.get_node("NeedsComponent")

	if not executor.study_completed.is_connected(_on_study_completed):
		executor.study_completed.connect(_on_study_completed)
	if not executor.full_test_requested.is_connected(_on_full_test_requested):
		executor.full_test_requested.connect(_on_full_test_requested)
	if not executor.character_slept.is_connected(_on_character_slept):
		executor.character_slept.connect(_on_character_slept)

	# Tutorial hooks
	if obj.need_affected == "hunger":
		_tutorial_event("ate_food")
	if obj.object_name == "Mrs Brighta":
		_tutorial_event("talked_brighta")
	if obj.action_name.begins_with("Study") or obj.action_name.begins_with("SAT") or obj.action_name.begins_with("English Practice"):
		_tutorial_event("studied")

	executor.execute(obj, needs)
	executor.action_completed.connect(func(text: String):
		if text != "":
			EventBus.warning_shown.emit(text, "yellow")
		college_progress.check_score(needs.character_name, needs.sat_score)
	, CONNECT_ONE_SHOT)
	player.unlock_from_action()


func _on_alt_action_confirmed(obj: GameObject) -> void:
	## Execute the alt action
	var player := CharacterManager.get_active_player()
	if not player:
		return
	var needs: NeedsComponent = player.get_node("NeedsComponent")

	# CONSEQUENCE CHECK: block non-recovery actions when exhausted
	var alt_is_recovery := obj.alt_need_affected in ["energy", "hunger"]
	if not alt_is_recovery and needs.is_too_exhausted_to_act():
		EventBus.warning_shown.emit(needs.get_block_reason(), "red")
		player.unlock_from_action()
		return

	# Get SAT multiplier BEFORE advancing time
	var sat_mult := needs.get_sat_multiplier()

	# Advance clock — stop at 23:59 to prevent midnight crossing
	for i in range(obj.alt_time_cost):
		if GameClock.game_hour == 23 and GameClock.game_minute == 59:
			break
		GameClock._advance_minute()

	# Check if alt action is study-related
	var is_study := obj.alt_need_affected == "" and (
		obj.alt_action_name.begins_with("Study") or
		obj.alt_action_name.begins_with("SAT Mock") or
		obj.alt_action_name.begins_with("Write Essay") or
		obj.alt_action_name.begins_with("English Practice") or
		obj.alt_action_name.begins_with("Do Homework") or
		obj.alt_action_name.begins_with("Participate"))

	if is_study:
		# SAT gain with consequence multiplier
		var base_gain: float = 10.0 * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0)
		var sat_gain := int(base_gain * sat_mult)
		var is_together := obj.alt_action_name.contains("Together")
		if is_together:
			sat_gain = int(sat_gain * 1.5)  # 50% bonus studying together!
			needs.modify_need("mental_health", 10.0)
			EventBus.warning_shown.emit("+%d SAT (study buddy bonus!) +10 Mental" % sat_gain, "yellow")
		elif sat_mult < 0.01:
			EventBus.warning_shown.emit("+0 SAT (can't focus!)", "red")
		elif sat_mult < 1.0:
			EventBus.warning_shown.emit("+%d SAT (reduced - %s)" % [sat_gain, needs.get_status_text()], "yellow")
		else:
			EventBus.warning_shown.emit("+%d SAT" % sat_gain, "yellow")
		needs.modify_sat(sat_gain)
		# Give the other player some SAT too when studying together
		if is_together:
			var other := CharacterManager.get_inactive_player()
			if other:
				var other_needs: NeedsComponent = other.get_node_or_null("NeedsComponent")
				if other_needs:
					other_needs.modify_sat(int(sat_gain * 0.5))
					other_needs.modify_need("mental_health", 10.0)
		# Track college checklist for alt actions
		var college_sys_node := get_tree().root.find_child("CollegeSystem", true, false)
		if college_sys_node and college_sys_node is CollegeSystem:
			var cs: CollegeSystem = college_sys_node as CollegeSystem
			if obj.alt_action_name.begins_with("English Practice"):
				var hours: int = obj.alt_time_cost / 60
				cs.english_hours[needs.character_name] = cs.english_hours.get(needs.character_name, 0) + hours
				EventBus.warning_shown.emit("English Hours: %d/10h" % cs.english_hours[needs.character_name], "yellow")
			if obj.alt_action_name.begins_with("Write Essay"):
				cs.essays_written[needs.character_name] = true
				EventBus.warning_shown.emit("College Essay written!", "yellow")
			if obj.alt_action_name.begins_with("SAT Mock"):
				var hours: int = obj.alt_time_cost / 60
				cs.english_hours[needs.character_name] = cs.english_hours.get(needs.character_name, 0) + hours

		# Trigger quiz
		sat_quiz.show_quiz()
	elif obj.alt_need_affected != "":
		var restore: float = obj.alt_base_restore * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0)
		needs.modify_need(obj.alt_need_affected, restore)
		var icon := ""
		match obj.alt_need_affected:
			"fun": icon = "[Fun]"
			"energy": icon = "[Nrg]"
			"hunger": icon = "[Food]"
			"mental_health": icon = "[MH]"
		EventBus.warning_shown.emit("+%.0f %s %s" % [restore, icon, obj.alt_need_affected.capitalize()], "yellow")

	# Mission events
	var mm := get_tree().get_first_node_in_group("mission_manager") as MissionManager

	# If alt action is sleeping
	if obj.alt_need_affected == "energy" and obj.alt_action_name.begins_with("Sleep"):
		if mm:
			mm.complete_mission_by_event(needs.character_name, "action_sleep")
		# Only end the day if it's evening (after 20:00)
		var sleep_hour := GameClock.game_hour
		if sleep_hour >= 20 or sleep_hour < 4:
			mark_character_day_done(needs.character_name)
		else:
			EventBus.warning_shown.emit("Quick rest! Day continues.", "yellow")
	if mm:
		if is_study:
			mm.complete_mission_by_event(needs.character_name, "action_study")
		else:
			mm.complete_mission_by_event(needs.character_name, "action_fun")
		mm.complete_mission_by_event(needs.character_name, "action_any")

	player.unlock_from_action()


func _on_popup_closed() -> void:
	var player := CharacterManager.get_active_player()
	if player:
		player.unlock_from_action()


func _on_character_slept(character_name: String) -> void:
	## Character slept — only ends the day if it's evening (after 20:00).
	## Before 20:00, sleeping is just a nap that restores energy.
	var hour := GameClock.game_hour
	print("[DAY] _on_character_slept: %s at %02d:00" % [character_name, hour])
	_tutorial_event("slept")
	if hour >= 20 or hour < 4:
		# Night time — sleeping ends the day
		mark_character_day_done(character_name)
	else:
		# Daytime nap — just restore energy, day continues
		EventBus.warning_shown.emit("Quick rest! Day continues.", "yellow")


func _on_study_completed(_character: String) -> void:
	# 1h study -> single quiz question
	sat_quiz.show_quiz()


func _on_full_test_requested(_character: String) -> void:
	# 2h study → full 5-question practice test (more coins!)
	sat_full_test.start_test()


func _on_quiz_completed(correct: bool, sat_bonus: int) -> void:
	if correct and sat_bonus > 0:
		var needs := CharacterManager.get_active_needs()
		if needs:
			needs.modify_sat(sat_bonus)
			coin_system.add_coins(needs.character_name, CoinSystem.COINS_PER_CORRECT)
			EventBus.warning_shown.emit("+%d SAT +%d$ (correct!)" % [sat_bonus, CoinSystem.COINS_PER_CORRECT], "yellow")
			college_progress.check_score(needs.character_name, needs.sat_score)


func _on_full_test_completed(correct_count: int, _total: int, coins_earned: int) -> void:
	var needs := CharacterManager.get_active_needs()
	if needs:
		needs.modify_sat(correct_count * 8)
		coin_system.add_coins(needs.character_name, coins_earned)
		college_progress.check_score(needs.character_name, needs.sat_score)


func _interact_furniture(furn: UpgradeableFurniture) -> void:
	## Create a temporary GameObject-like popup for furniture interaction.
	var def: Dictionary = FurnitureUpgradeSystem.FURNITURE_DEFS.get(furn.furniture_id, {})
	if def.is_empty():
		CharacterManager.get_active_player().unlock_from_action()
		return

	# Create a temporary GameObject to pass to InteractionPopup
	var temp_obj := GameObject.new()
	temp_obj.object_name = furn._name_label.text if furn._name_label else furn.furniture_id
	temp_obj.action_name = def.get("action", "Use")
	temp_obj.quality = furn.level
	temp_obj.need_affected = def.get("need", "")
	temp_obj.base_restore = def.get("base_restore", 0.0)
	temp_obj.time_cost = def.get("time_cost", 30)
	temp_obj.alt_action_name = def.get("alt_action", "")
	temp_obj.alt_need_affected = def.get("alt_need", "")
	temp_obj.alt_base_restore = def.get("alt_restore", 0.0)
	temp_obj.alt_time_cost = def.get("alt_time", 30)
	interaction_popup.show_for_object(temp_obj)


func _on_coins_changed(_character: String, _amount: int) -> void:
	_update_coins_label()


func _on_open_upgrades() -> void:
	if journey_panel.visible:
		journey_panel._close()
	else:
		var needs := CharacterManager.get_active_needs()
		if needs:
			journey_panel.show_panel(needs.character_name)
			_tutorial_event("opened_journey")


func _on_toggle_missions() -> void:
	mission_panel.visible = not mission_panel.visible


func _update_coins_label() -> void:
	var needs := CharacterManager.get_active_needs()
	var amount := 0
	if needs:
		amount = coin_system.get_coins(needs.character_name)
	if needs_bars_panel and needs_bars_panel.has_method("update_coins"):
		needs_bars_panel.update_coins(amount)


func _on_furniture_upgraded(_character: String, _furniture_id: String, _new_level: int) -> void:
	_update_room_score()
	# Update room mood lighting
	var loc := SceneManager.get_current_location_node()
	if loc and loc.room_renderer:
		var avg_level := _get_avg_furniture_level(_character)
		loc.room_renderer.set_upgrade_level(avg_level)


func _update_room_score() -> void:
	var needs := CharacterManager.get_active_needs()
	pass  # Room score can be shown in pause menu


func _get_avg_furniture_level(character: String) -> int:
	if not furniture_system.furniture_levels.has(character):
		return 1
	var total := 0
	var count := 0
	for fid in furniture_system.furniture_levels[character]:
		total += furniture_system.furniture_levels[character][fid]
		count += 1
	if count == 0:
		return 1
	return total / count


const COINS_PER_MISSION := 5
const COINS_ALL_MISSIONS_BONUS := 20

func _award_mission_coins(character: String) -> void:
	var completed := mission_manager.get_completion_count(character)
	var total_missions := mission_manager.get_missions(character).size()
	var coins_earned := completed * COINS_PER_MISSION

	if completed == total_missions and total_missions > 0:
		coins_earned += COINS_ALL_MISSIONS_BONUS

	if coins_earned > 0:
		coin_system.add_coins(character, coins_earned)
		var msg := "%s earned $%d from missions" % [character.capitalize(), coins_earned]
		if completed == total_missions:
			msg += " (ALL COMPLETE BONUS +$%d!)" % COINS_ALL_MISSIONS_BONUS
		EventBus.warning_shown.emit(msg, "yellow")


func _get_journey_system() -> JourneySystem:
	for node in get_tree().get_nodes_in_group("journey_system"):
		return node as JourneySystem
	return null


func _get_curfew_system() -> CurfewSystem:
	for node in get_tree().get_nodes_in_group("curfew_system"):
		return node as CurfewSystem
	return null


# ============ TUTORIAL HANDLERS ============

func _on_tutorial_step_changed(step_index: int, step_data: Dictionary) -> void:
	if tutorial_overlay:
		tutorial_overlay.show_step(step_index, step_data, TutorialSystem.TUTORIAL_STEPS.size())


func _on_tutorial_finished() -> void:
	if tutorial_overlay:
		tutorial_overlay.hide_tutorial()


func _on_tutorial_skip() -> void:
	tutorial_system.skip()


func _on_tutorial_next() -> void:
	# Only called on the final step — just finish
	tutorial_system.skip()


func _tutorial_event(event_name: String) -> void:
	if tutorial_system and tutorial_system.active:
		tutorial_system.complete_event(event_name)


func _on_game_ended() -> void:
	## Game is over — delete save and return to title screen.
	SaveSystem.delete_save()
	GameClock.pause()
	get_tree().reload_current_scene()


func _on_play_other_character(other_name: String) -> void:
	## Switch to the other character's 7-day journey.
	print("[DAY] Starting %s's journey!" % other_name)
	_current_journey_character = other_name
	_day_ended = false
	_sleep_warned = false
	_gritty_day_done = false
	_smartle_day_done = false

	# Reset day to 1 for this character
	GameClock.game_day = 1
	GameClock.game_hour = 6
	GameClock.game_minute = 0

	# Switch active character
	if other_name == "gritty":
		CharacterManager.active_index = CharacterManager.players.find(gritty_player)
	else:
		CharacterManager.active_index = CharacterManager.players.find(smartle_player)

	# Load their home location
	var home := "mansion" if other_name == "gritty" else "favela_bedroom"
	var active_player := CharacterManager.get_active_player()
	_park_player(active_player)

	SceneManager.character_locations[other_name] = home
	var loc := SceneManager.load_location_immediate(home)
	var ysort: Node2D = loc.get_node("YSortRoot")
	ysort.add_child(active_player)
	active_player.position = loc.get_spawn_world_pos()
	active_player.is_active = true
	var camera: Camera2D = active_player.get_node_or_null("Camera2D")
	if camera:
		camera.make_current()

	_update_location_label(home)
	GameClock.resume()
	GameState.change_state(GameState.State.PLAYING)
	_show_day_banner(1)
	mission_manager.generate_missions(other_name)

	# Start tutorial for the new character's day 1
	tutorial_system.start()


func _auto_save() -> void:
	# Save current character's time
	var active_needs := CharacterManager.get_active_needs()
	if active_needs:
		GameClock.save_time_for(active_needs.character_name)

	var data := SaveSystem.build_save_data(
		_get_needs(gritty_player),
		_get_needs(smartle_player),
		coin_system,
		furniture_system,
		college_system,
		GameClock.game_day
	)
	# Add character times and locations
	data["character_times"] = GameClock._character_times.duplicate(true)
	data["character_locations"] = SceneManager.character_locations.duplicate()
	SaveSystem.save_game(data)
