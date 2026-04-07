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
@onready var title_screen: Control = $HUD/TitleScreen
@onready var day_split: Control = $HUD/DaySplitScreen
@onready var commute_anim: Control = $HUD/CommuteAnimation
@onready var day_summary: Control = $HUD/DaySummary
@onready var decision_day: Control = $HUD/DecisionDay
@onready var upgrade_shop: PanelContainer = $HUD/UpgradeShop
@onready var sat_full_test: PanelContainer = $HUD/SATFullTest
@onready var coins_label: Label = $HUD/CoinsLabel
@onready var room_score_bar: Control = $HUD/RoomScoreBar
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager
@onready var mission_manager: MissionManager = $Systems/MissionManager
@onready var college_progress: CollegeProgress = $Systems/CollegeProgress
@onready var college_system: CollegeSystem = $Systems/CollegeSystem
@onready var coin_system: CoinSystem = $Systems/CoinSystem
@onready var furniture_system: FurnitureUpgradeSystem = $Systems/FurnitureUpgradeSystem
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

	# Register systems in groups FIRST
	schedule_manager.add_to_group("schedule_manager")
	mission_manager.add_to_group("mission_manager")
	coin_system.add_to_group("coin_system")
	furniture_system.add_to_group("furniture_upgrade_system")
	furniture_system.setup_defaults()
	college_system.setup_default_lists()

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
	GameClock.day_changed.connect(_on_day_changed)
	CharacterManager.character_switched.connect(_on_character_switched)
	interaction_popup.action_confirmed.connect(_on_action_confirmed)
	interaction_popup.alt_action_confirmed.connect(_on_alt_action_confirmed)
	interaction_popup.popup_closed.connect(_on_popup_closed)
	sat_quiz.quiz_completed.connect(_on_quiz_completed)
	sat_full_test.test_completed.connect(_on_full_test_completed)
	coin_system.coins_changed.connect(_on_coins_changed)
	furniture_system.furniture_upgraded.connect(_on_furniture_upgraded)
	title_screen.start_game.connect(_on_title_start)
	day_split.continue_day.connect(_on_split_continue)

	# Setup UI
	mission_panel.setup(mission_manager)
	mission_manager.generate_missions("gritty")
	mission_manager.generate_missions("smartle")
	_update_coins_label()

	# Start paused — show title screen
	GameState.change_state(GameState.State.IN_MENU)
	GameClock.pause()


func _on_title_start() -> void:
	title_screen.visible = false
	title_screen.set_process_unhandled_input(false)
	# Show morning split screen
	call_deferred("_show_morning_split")


func _show_morning_split() -> void:
	day_split.show_split(GameClock.game_day, _get_needs(gritty_player), _get_needs(smartle_player))


func _on_split_continue() -> void:
	# Start playing!
	GameState.change_state(GameState.State.PLAYING)
	GameClock.resume()
	_show_day_banner(GameClock.game_day)
	_update_room_score()
	_update_coins_label()
	print("[Main] Game started - State: ", GameState.State.keys()[GameState.current_state])


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

	# Check school hours — allow leaving home early for commute
	# School open 8:00-16:00, but commute takes time
	if target in ["classroom", "library", "cafeteria"]:
		var time := GameClock.get_total_minutes()
		# Allow leaving from 7:00 onward (earliest commute departure)
		# Block after 16:00
		if time > 960:
			EventBus.warning_shown.emit("School is closed! Come back tomorrow.", "red")
			return

	# Check cafeteria hours (12:00 - 13:30) — only if already at school
	if target == "cafeteria":
		var time := GameClock.get_total_minutes()
		var current_loc := SceneManager.get_location(needs.character_name if needs else "")
		var at_school := current_loc in ["classroom", "library"]
		if at_school and (time < 720 or time > 810):
			EventBus.warning_shown.emit("Cafeteria open 12:00-13:30 only!", "red")
			return

	var char_name: String = needs.character_name if needs else ""
	if char_name != "":
		SceneManager.character_locations[char_name] = target

	# If going to school, show commute animation first
	# Commute animation — going TO school from home
	var is_going_to_school := target == "classroom"
	# Commute animation — going HOME from school
	var is_going_home := target in ["favela_bedroom", "mansion", "home"]
	var current_loc := SceneManager.get_location(char_name) if char_name != "" else ""
	var at_school := current_loc in ["classroom", "library", "cafeteria"]
	var at_home := current_loc in ["favela_kitchen", "mansion_kitchen", "favela_bedroom", "mansion"]

	if (is_going_to_school and at_home) or (is_going_home and at_school):
		# Smartle: bus 2 hours (120 min). Gritty: car 30 min.
		var mode := "bus" if char_name == "smartle" else "car"
		var travel := 120 if char_name == "smartle" else 30
		var direction := "to school" if is_going_to_school else "home"
		commute_anim.show_commute(char_name + " going " + direction, mode, travel)
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

func _on_state_changed(old_state: GameState.State, new_state: GameState.State) -> void:
	if new_state == GameState.State.PAUSED:
		pause_overlay.visible = true
		pause_menu.show_menu()
	elif old_state == GameState.State.PAUSED:
		pause_overlay.visible = false
		pause_menu.hide_menu()


func _on_hour_changed(hour: int) -> void:
	if hour == SLEEP_WARNING_HOUR and not _sleep_warned:
		_sleep_warned = true
		EventBus.warning_shown.emit("Time to sleep!", "yellow")
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
	EventBus.warning_shown.emit("You didn't sleep! -%.0f%% energy" % NO_SLEEP_PENALTY, "red")
	_get_needs(gritty_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_get_needs(smartle_player).modify_need("energy", -NO_SLEEP_PENALTY)
	_check_homework()
	EventBus.day_ended.emit(GameClock.game_day)
	_auto_save()

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
	if sat_full_test.visible: return false
	if GameState.current_state != GameState.State.PLAYING: return false
	return true


func _unhandled_input(event: InputEvent) -> void:
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

	# Advance clock
	for i in range(obj.alt_time_cost):
		GameClock._advance_minute()

	# Check if alt action is study-related
	var is_study := obj.alt_need_affected == "" and (
		obj.alt_action_name.begins_with("Study") or
		obj.alt_action_name.begins_with("Participate"))

	if is_study:
		# SAT gain
		var sat_gain := int(10.0 * GameObject.QUALITY_MULTIPLIERS.get(obj.quality, 1.0))
		needs.modify_sat(sat_gain)
		EventBus.warning_shown.emit("+%d SAT" % sat_gain, "yellow")
		# Always trigger quiz when studying
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


func _on_study_completed(_character: String) -> void:
	# 1h study → single quiz question
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
	var needs := CharacterManager.get_active_needs()
	if needs:
		upgrade_shop.show_shop(needs.character_name)


func _update_coins_label() -> void:
	var needs := CharacterManager.get_active_needs()
	var amount := 0
	if needs:
		amount = coin_system.get_coins(needs.character_name)
	# Update in needs panel
	var needs_bars_node := get_node_or_null("HUD/NeedsBars")
	if needs_bars_node and needs_bars_node.has_method("update_coins"):
		needs_bars_node.update_coins(amount)
	# Also update standalone label if exists
	if coins_label:
		coins_label.text = "Coins: $%d" % amount


func _on_furniture_upgraded(_character: String, _furniture_id: String, _new_level: int) -> void:
	_update_room_score()
	# Update room mood lighting
	var loc := SceneManager.get_current_location_node()
	if loc and loc.room_renderer:
		var avg_level := _get_avg_furniture_level(_character)
		loc.room_renderer.set_upgrade_level(avg_level)


func _update_room_score() -> void:
	var needs := CharacterManager.get_active_needs()
	if needs and room_score_bar:
		room_score_bar.update_score(needs.character_name)


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


func _auto_save() -> void:
	var data := SaveSystem.build_save_data(
		_get_needs(gritty_player),
		_get_needs(smartle_player),
		coin_system,
		furniture_system,
		college_system,
		GameClock.game_day
	)
	SaveSystem.save_game(data)
