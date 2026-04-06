extends Node
class_name SaveSystem

## Saves and loads game state to user://save.json

const SAVE_PATH := "user://save.json"


static func save_game(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


static func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	file.close()
	if result == OK and json.data is Dictionary:
		return json.data
	return {}


static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


static func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


static func build_save_data(
	gritty_needs: NeedsComponent,
	smartle_needs: NeedsComponent,
	coin_system: CoinSystem,
	furniture_system: FurnitureUpgradeSystem,
	college_system: CollegeSystem,
	day: int
) -> Dictionary:
	return {
		"version": 1,
		"day": day,
		"clock": {"hour": GameClock.game_hour, "minute": GameClock.game_minute},
		"gritty": {
			"hunger": gritty_needs.hunger,
			"energy": gritty_needs.energy,
			"fun": gritty_needs.fun,
			"sat_score": gritty_needs.sat_score,
			"homework_done": gritty_needs.homework_done,
			"coins": coin_system.get_coins("gritty"),
		},
		"smartle": {
			"hunger": smartle_needs.hunger,
			"energy": smartle_needs.energy,
			"fun": smartle_needs.fun,
			"sat_score": smartle_needs.sat_score,
			"homework_done": smartle_needs.homework_done,
			"coins": coin_system.get_coins("smartle"),
		},
		"furniture": furniture_system.furniture_levels.duplicate(true),
		"college": {
			"english_hours": college_system.english_hours.duplicate(),
			"essays_written": college_system.essays_written.duplicate(),
			"recommendations": college_system.recommendations.duplicate(),
			"total_missions": college_system.total_missions.duplicate(),
		},
	}


static func apply_save_data(
	data: Dictionary,
	gritty_needs: NeedsComponent,
	smartle_needs: NeedsComponent,
	coin_system: CoinSystem,
	furniture_system: FurnitureUpgradeSystem,
	college_system: CollegeSystem,
) -> void:
	if data.is_empty():
		return

	GameClock.game_day = data.get("day", 1)
	var clock: Dictionary = data.get("clock", {})
	GameClock.game_hour = clock.get("hour", 6)
	GameClock.game_minute = clock.get("minute", 0)

	var gd: Dictionary = data.get("gritty", {})
	gritty_needs.hunger = gd.get("hunger", 100.0)
	gritty_needs.energy = gd.get("energy", 100.0)
	gritty_needs.fun = gd.get("fun", 100.0)
	gritty_needs.sat_score = gd.get("sat_score", 0)
	gritty_needs.homework_done = gd.get("homework_done", false)
	coin_system.coins["gritty"] = gd.get("coins", 0)

	var sd: Dictionary = data.get("smartle", {})
	smartle_needs.hunger = sd.get("hunger", 100.0)
	smartle_needs.energy = sd.get("energy", 100.0)
	smartle_needs.fun = sd.get("fun", 100.0)
	smartle_needs.sat_score = sd.get("sat_score", 0)
	smartle_needs.homework_done = sd.get("homework_done", false)
	coin_system.coins["smartle"] = sd.get("coins", 50)

	var furn: Dictionary = data.get("furniture", {})
	for character in furn:
		if furniture_system.furniture_levels.has(character):
			for fid in furn[character]:
				furniture_system.furniture_levels[character][fid] = furn[character][fid]

	var college: Dictionary = data.get("college", {})
	college_system.english_hours = college.get("english_hours", {"gritty": 0, "smartle": 0})
	college_system.essays_written = college.get("essays_written", {"gritty": false, "smartle": false})
	college_system.recommendations = college.get("recommendations", {"gritty": false, "smartle": false})
	college_system.total_missions = college.get("total_missions", {"gritty": 0, "smartle": 0})
