extends Node
class_name JourneySystem

## Tracks each character's educational journey — purchases, milestones, sacrifices.
## Replaces furniture upgrades with meaningful educational investments.

signal item_purchased(character: String, item_id: String)
signal milestone_reached(character: String, count: int)

# Item categories
const EDUCATION := "education"
const SURVIVAL := "survival"
const COMMUNITY := "community"
const PERSONAL := "personal"

# All purchasable items
const ITEMS := {
	# === EDUCATION ===
	"sat_prep_book": {
		"name": "College Board Access", "cost": 30, "category": EDUCATION,
		"desc": "Official practice questions, boosts SAT accuracy", "effect": "sat_bonus_10",
		"available_to": ["smartle", "gritty"],
	},
	"online_course": {
		"name": "Online Course", "cost": 50, "category": EDUCATION,
		"desc": "Access harder questions for more points", "effect": "unlock_hard_questions",
		"available_to": ["smartle", "gritty"],
	},
	"tutor_session": {
		"name": "Tutor Session", "cost": 80, "category": EDUCATION,
		"desc": "2x SAT points for one day", "effect": "sat_2x_day",
		"available_to": ["smartle", "gritty"],
	},
	"calculator": {
		"name": "Calculator", "cost": 20, "category": EDUCATION,
		"desc": "+15% on math questions", "effect": "math_bonus",
		"available_to": ["smartle", "gritty"],
	},
	"school_supplies": {
		"name": "School Supplies", "cost": 10, "category": EDUCATION,
		"desc": "Required to study at home", "effect": "homework_enabled",
		"available_to": ["smartle", "gritty"],
	},
	"computer": {
		"name": "Computer", "cost": 100, "category": EDUCATION,
		"desc": "Required for online courses at home", "effect": "computer",
		"available_to": ["smartle", "gritty"],
	},
	"college_app_1": {
		"name": "College Application #1", "cost": 75, "category": EDUCATION,
		"desc": "Apply to your dream school", "effect": "college_app",
		"available_to": ["smartle", "gritty"],
	},
	"college_app_2": {
		"name": "College Application #2", "cost": 75, "category": EDUCATION,
		"desc": "Apply to a match school", "effect": "college_app",
		"available_to": ["smartle", "gritty"],
	},
	"college_app_3": {
		"name": "College Application #3", "cost": 75, "category": EDUCATION,
		"desc": "Apply to a safety school", "effect": "college_app",
		"available_to": ["smartle", "gritty"],
	},

	# === SURVIVAL (mostly Smartle) ===
	"bus_pass": {
		"name": "Weekly Bus Pass", "cost": 15, "category": SURVIVAL,
		"desc": "Required to get to school", "effect": "bus_pass",
		"available_to": ["smartle"],
		"recurring": true,
	},
	"help_rent": {
		"name": "Help Mom with Rent", "cost": 50, "category": SURVIVAL,
		"desc": "+30 Mental Health, shows responsibility", "effect": "mental_30",
		"available_to": ["smartle"],
	},
	"internet": {
		"name": "Internet Access (monthly)", "cost": 25, "category": SURVIVAL,
		"desc": "Required to study at home", "effect": "internet",
		"available_to": ["smartle"],
		"recurring": true,
	},

	# === COMMUNITY ===
	"tutor_kids": {
		"name": "Tutor Younger Kids", "cost": 0, "category": COMMUNITY,
		"desc": "+20 Mental Health, extracurricular for college", "effect": "mental_20_extra",
		"available_to": ["smartle", "gritty"],
	},
	"community_service": {
		"name": "Community Service", "cost": 0, "category": COMMUNITY,
		"desc": "Improves college application", "effect": "extra_curricular",
		"available_to": ["smartle", "gritty"],
	},
	"study_group": {
		"name": "Start a Study Group", "cost": 0, "category": COMMUNITY,
		"desc": "+15 Mental Health, helps everyone", "effect": "mental_15",
		"available_to": ["smartle", "gritty"],
	},

	# === PERSONAL ===
	"therapy": {
		"name": "Therapy Session", "cost": 30, "category": PERSONAL,
		"desc": "+40 Mental Health", "effect": "mental_40",
		"available_to": ["smartle", "gritty"],
	},
	"sports_equip": {
		"name": "Sports Equipment", "cost": 20, "category": PERSONAL,
		"desc": "Can exercise at home", "effect": "home_exercise",
		"available_to": ["smartle", "gritty"],
	},
	"journal": {
		"name": "Personal Journal", "cost": 5, "category": PERSONAL,
		"desc": "+10 Mental Health, self-reflection", "effect": "mental_10",
		"available_to": ["smartle", "gritty"],
	},
}

# {character: {item_id: true}}
var purchased: Dictionary = {"smartle": {}, "gritty": {}}

# Track recurring purchases per day
var recurring_purchased_today: Dictionary = {"smartle": {}, "gritty": {}}


func get_items_for(character: String) -> Array:
	## Returns all items available to this character with purchase status.
	var result: Array = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if character in item.available_to:
			var is_bought: bool = purchased.get(character, {}).get(item_id, false)
			var is_recurring: bool = item.get("recurring", false)
			var bought_today: bool = recurring_purchased_today.get(character, {}).get(item_id, false)
			result.append({
				"id": item_id,
				"name": item.name,
				"cost": item.cost,
				"category": item.category,
				"desc": item.desc,
				"effect": item.effect,
				"purchased": is_bought and not is_recurring,
				"purchased_today": bought_today,
				"recurring": is_recurring,
				"can_buy": not is_bought or is_recurring,
			})
	return result


func purchase(character: String, item_id: String) -> bool:
	if not ITEMS.has(item_id):
		return false
	var item: Dictionary = ITEMS[item_id]
	if character not in item.available_to:
		return false

	var coin_sys := _get_coin_system()
	if not coin_sys:
		return false
	if not coin_sys.spend_coins(character, item.cost):
		return false

	purchased[character][item_id] = true
	if item.get("recurring", false):
		recurring_purchased_today[character][item_id] = true

	item_purchased.emit(character, item_id)

	# Check milestone
	var count := get_purchased_count(character)
	if count % 3 == 0:
		milestone_reached.emit(character, count)

	return true


func get_purchased_count(character: String) -> int:
	var count := 0
	for item_id in purchased.get(character, {}):
		if purchased[character][item_id]:
			count += 1
	return count


func get_total_available(character: String) -> int:
	var count := 0
	for item_id in ITEMS:
		if character in ITEMS[item_id].available_to:
			count += 1
	return count


func has_item(character: String, item_id: String) -> bool:
	return purchased.get(character, {}).get(item_id, false)


func reset_recurring() -> void:
	recurring_purchased_today = {"smartle": {}, "gritty": {}}


func _get_coin_system() -> CoinSystem:
	for node in get_tree().get_nodes_in_group("coin_system"):
		return node as CoinSystem
	return null
