extends Node
class_name FurnitureUpgradeSystem

## Manages furniture levels per character. Each furniture can be upgraded 1→5★.

signal furniture_upgraded(character: String, furniture_id: String, new_level: int)

# Upgrade costs per level
const UPGRADE_COSTS := {
	2: 30,
	3: 75,
	4: 150,
	5: 300,
}

# Furniture definitions: {id: {name, base_restore, need, time_cost, sprites...}}
const FURNITURE_DEFS := {
	"bed": {"name": "Bed", "action": "Sleep", "need": "energy", "base_restore": 40.0, "time_cost": 120},
	"desk": {"name": "Desk", "action": "Study", "need": "", "base_restore": 0.0, "time_cost": 60,
			 "alt_action": "Play", "alt_need": "fun", "alt_restore": 25.0, "alt_time": 60},
	"stove": {"name": "Stove", "action": "Cook", "need": "hunger", "base_restore": 30.0, "time_cost": 30},
	"fridge": {"name": "Fridge", "action": "Eat", "need": "hunger", "base_restore": 15.0, "time_cost": 10},
}

# Level names per furniture
const LEVEL_NAMES := {
	"bed": ["Old Mattress", "Basic Bed", "Comfy Bed", "Queen Bed", "King Bed"],
	"desk": ["Cardboard Box", "Old Desk", "Wooden Desk", "Gaming Setup", "Pro Studio"],
	"stove": ["Hot Plate", "Basic Stove", "Gas Stove", "Electric Range", "Chef Kitchen"],
	"fridge": ["Cooler Box", "Mini Fridge", "Fridge", "Smart Fridge", "Gourmet Fridge"],
}

# {character: {furniture_id: level}}
var furniture_levels: Dictionary = {}


func setup_defaults() -> void:
	# Gritty starts with everything at level 1
	furniture_levels["gritty"] = {
		"bed": 1, "desk": 1, "stove": 1, "fridge": 1,
	}
	# Smartle starts with everything at level 4-5 (privilege)
	furniture_levels["smartle"] = {
		"bed": 5, "desk": 5, "stove": 4, "fridge": 4,
	}


func get_level(character: String, furniture_id: String) -> int:
	if furniture_levels.has(character) and furniture_levels[character].has(furniture_id):
		return furniture_levels[character][furniture_id]
	return 1


func get_name_for_level(furniture_id: String, level: int) -> String:
	if LEVEL_NAMES.has(furniture_id):
		var names: Array = LEVEL_NAMES[furniture_id]
		return names[clampi(level - 1, 0, names.size() - 1)]
	return "Unknown"


func get_upgrade_cost(current_level: int) -> int:
	var next_level := current_level + 1
	return UPGRADE_COSTS.get(next_level, -1)  # -1 = max level


func can_upgrade(character: String, furniture_id: String) -> bool:
	var level := get_level(character, furniture_id)
	if level >= 5:
		return false
	var cost := get_upgrade_cost(level)
	var coin_sys := _get_coin_system()
	if coin_sys:
		return coin_sys.get_coins(character) >= cost
	return false


func do_upgrade(character: String, furniture_id: String) -> bool:
	var level := get_level(character, furniture_id)
	if level >= 5:
		return false
	var cost := get_upgrade_cost(level)
	var coin_sys := _get_coin_system()
	if not coin_sys or not coin_sys.spend_coins(character, cost):
		return false

	furniture_levels[character][furniture_id] = level + 1
	furniture_upgraded.emit(character, furniture_id, level + 1)
	return true


func get_all_furniture(character: String) -> Array:
	## Returns array of {id, name, level, max_level, next_cost, can_upgrade}
	var result: Array = []
	if not furniture_levels.has(character):
		return result

	for fid in furniture_levels[character]:
		var level: int = furniture_levels[character][fid]
		var next_cost := get_upgrade_cost(level)
		result.append({
			"id": fid,
			"name": get_name_for_level(fid, level),
			"level": level,
			"max_level": 5,
			"next_cost": next_cost,
			"can_upgrade": can_upgrade(character, fid),
		})
	return result


func _get_coin_system() -> CoinSystem:
	for node in get_tree().get_nodes_in_group("coin_system"):
		return node as CoinSystem
	return null
