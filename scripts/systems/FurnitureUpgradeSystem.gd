extends Node
class_name FurnitureUpgradeSystem

## Manages furniture levels (3 tiers) per character.
## Level 1 = 1.5★, Level 2 = 3.25★, Level 3 = 5★

signal furniture_upgraded(character: String, furniture_id: String, new_level: int)

const MAX_LEVEL := 3

# Star values per level
const STAR_VALUES := {1: 1.5, 2: 3.25, 3: 5.0}

# Quality multipliers based on star value
const QUALITY_MULTIPLIERS := {1: 0.55, 2: 1.0, 3: 1.6}

# Upgrade costs
const UPGRADE_COSTS := {2: 50, 3: 150}

# All furniture types with their gameplay properties
const FURNITURE_DEFS := {
	"bed": {"name": ["Old Bed", "Comfy Bed", "Luxury Bed"],
			"action": "Sleep 8h", "need": "energy", "base_restore": 60.0, "time_cost": 480,
			"alt_action": "Sleep 6h", "alt_need": "energy", "alt_restore": 40.0, "alt_time": 360,
			"path": "res://assets/furniture/bed/Cama %d.png"},
	"desk": {"name": ["Old Desk", "Wooden Desk", "Pro Setup"],
			 "action": "Do Homework (1h)", "need": "", "base_restore": 0.0, "time_cost": 60,
			 "alt_action": "SAT Mock Test (2h)", "alt_need": "", "alt_restore": 0.0, "alt_time": 120,
			 "path": "res://assets/furniture/desk/Mesa %d.png"},
	"stove": {"name": ["Hot Plate", "Basic Stove", "Chef Kitchen"],
			  "action": "Cook Healthy ($5)", "need": "hunger", "base_restore": 40.0, "time_cost": 45,
			  "coin_cost": 5,
			  "alt_action": "Order Junk Food ($3)", "alt_need": "hunger", "alt_restore": 25.0, "alt_time": 10,
			  "alt_coin_cost": 3,
			  "path": "res://assets/furniture/stove/%s"},
	"fridge": {"name": ["Cooler Box", "Fridge", "Gourmet Fridge"],
			   "action": "Snack ($2)", "need": "hunger", "base_restore": 15.0, "time_cost": 5,
			   "coin_cost": 2,
			   "path": "res://assets/furniture/fridge/%s"},
	"tv": {"name": ["Old TV", "Flat Screen", "Home Theater"],
		   "action": "Watch 2h", "need": "fun", "base_restore": 35.0, "time_cost": 120,
		   "alt_action": "Watch 30min", "alt_need": "fun", "alt_restore": 15.0, "alt_time": 30,
		   "path": "res://assets/furniture/tv/%s"},
	"sofa": {"name": ["Old Sofa", "Comfy Sofa", "Luxury Sofa"],
			 "action": "Exercise (Mental Health)", "need": "mental_health", "base_restore": 30.0, "time_cost": 60,
			 "alt_action": "Quick Rest", "alt_need": "energy", "alt_restore": 10.0, "alt_time": 30,
			 "path": "res://assets/furniture/sofa/Sofa %d.png"},
	"bookshelf": {"name": ["Small Shelf", "Bookshelf", "Library"],
				  "action": "Read", "need": "", "base_restore": 0.0, "time_cost": 45,
				  "path": "res://assets/furniture/bookshelf/%s"},
	"closet": {"name": ["Box", "Wardrobe", "Walk-in Closet"],
			   "action": "Organize", "need": "fun", "base_restore": 10.0, "time_cost": 20,
			   "path": "res://assets/furniture/closet/Armario %d.png"},
	"table": {"name": ["Crate Table", "Dining Table", "Grand Table"],
			  "action": "Eat", "need": "hunger", "base_restore": 20.0, "time_cost": 20,
			  "path": "res://assets/furniture/table/Mesa jantar %d.png"},
	"rug": {"name": ["Old Mat", "Rug", "Persian Rug"],
			"action": "", "need": "", "base_restore": 0.0, "time_cost": 0,
			"path": "res://assets/furniture/rug/%s", "decorative": true},
	"sink": {"name": ["Bucket", "Sink", "Designer Sink"],
			 "action": "Wash", "need": "energy", "base_restore": 5.0, "time_cost": 10,
			 "path": "res://assets/furniture/kitchen sink/%s"},
}

# Filename mappings for files with inconsistent naming
const FILE_NAMES := {
	"stove": ["Fogao 1.png", "fogao 2.png", "Fogao 3.png"],
	"fridge": ["Geladeira 1.png", "Geladeira2.png", "Geladeira 3.png"],
	"tv": ["Tv 1.png", "Tv2.png", "Tv 3.png"],
	"bookshelf": ["Estante 1.png", "estante 2.png", "Estante 3.png"],
	"rug": ["tapete 1.png", "tapete2.png", "tapete3.png"],
	"sink": ["Pia 1.png", "pia2.png", "pia 3.png"],
	"desk": ["Mesa 1.png", "Mesa2.png", "Mesa 3.png"],
}

# {character: {furniture_id: level (1-3)}}
var furniture_levels: Dictionary = {}


func setup_defaults() -> void:
	# Gritty — middle class, level 2 furniture (parents work hard)
	furniture_levels["gritty"] = {
		"bed": 2, "desk": 2, "stove": 2, "fridge": 2,
		"tv": 2, "sofa": 2, "bookshelf": 2, "rug": 2,
	}
	# Smartle — favela, level 1 furniture (limited resources)
	furniture_levels["smartle"] = {
		"bed": 1, "desk": 1, "stove": 1, "fridge": 1,
		"tv": 1, "sofa": 1, "rug": 1,
	}


func get_level(character: String, furniture_id: String) -> int:
	if furniture_levels.has(character) and furniture_levels[character].has(furniture_id):
		return furniture_levels[character][furniture_id]
	return 1


func get_star_value(level: int) -> float:
	return STAR_VALUES.get(level, 1.5)


func get_quality_multiplier(level: int) -> float:
	return QUALITY_MULTIPLIERS.get(level, 0.55)


func get_name_for_level(furniture_id: String, level: int) -> String:
	if FURNITURE_DEFS.has(furniture_id):
		var names: Array = FURNITURE_DEFS[furniture_id].name
		return names[clampi(level - 1, 0, names.size() - 1)]
	return "Unknown"


func get_texture_path(furniture_id: String, level: int) -> String:
	if not FURNITURE_DEFS.has(furniture_id):
		return ""
	var def: Dictionary = FURNITURE_DEFS[furniture_id]
	# Use filename mapping if available
	if FILE_NAMES.has(furniture_id):
		var files: Array = FILE_NAMES[furniture_id]
		var idx := clampi(level - 1, 0, files.size() - 1)
		var base_dir: String = def.path.get_base_dir()
		return base_dir + "/" + files[idx]
	# Standard naming: "Name %d.png"
	return def.path % level


func get_upgrade_cost(current_level: int) -> int:
	var next := current_level + 1
	return UPGRADE_COSTS.get(next, -1)


func can_upgrade(character: String, furniture_id: String) -> bool:
	var level := get_level(character, furniture_id)
	if level >= MAX_LEVEL:
		return false
	var cost := get_upgrade_cost(level)
	var coin_sys := _get_coin_system()
	if coin_sys:
		return coin_sys.get_coins(character) >= cost
	return false


func do_upgrade(character: String, furniture_id: String) -> bool:
	var level := get_level(character, furniture_id)
	if level >= MAX_LEVEL:
		return false
	var cost := get_upgrade_cost(level)
	var coin_sys := _get_coin_system()
	if not coin_sys or not coin_sys.spend_coins(character, cost):
		return false
	furniture_levels[character][furniture_id] = level + 1
	furniture_upgraded.emit(character, furniture_id, level + 1)
	return true


func get_all_furniture(character: String) -> Array:
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
			"max_level": MAX_LEVEL,
			"stars": get_star_value(level),
			"next_cost": next_cost,
			"can_upgrade": can_upgrade(character, fid),
		})
	return result


func _get_coin_system() -> CoinSystem:
	for node in get_tree().get_nodes_in_group("coin_system"):
		return node as CoinSystem
	return null
