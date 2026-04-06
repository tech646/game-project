extends Node
class_name CollegeSystem

## Manages college list, application checklist, and Decision Day.

signal application_updated(character: String, college: String)
signal decision_day(character: String, results: Array)

const COLLEGES := {
	"MIT": {"type": "dream", "sat_min": 1500, "label": "Massachusetts Institute of Technology", "icon": ""},
	"Stanford": {"type": "dream", "sat_min": 1480, "label": "Stanford University", "icon": ""},
	"Harvard": {"type": "dream", "sat_min": 1510, "label": "Harvard University", "icon": ""},
	"Columbia": {"type": "match", "sat_min": 1400, "label": "Columbia University", "icon": ""},
	"BU": {"type": "match", "sat_min": 1300, "label": "Boston University", "icon": ""},
	"UC Davis": {"type": "match", "sat_min": 1200, "label": "UC Davis", "icon": ""},
	"NYU": {"type": "match", "sat_min": 1350, "label": "New York University", "icon": ""},
	"ASU": {"type": "safety", "sat_min": 1000, "label": "Arizona State University", "icon": ""},
	"UCF": {"type": "safety", "sat_min": 1050, "label": "University of Central Florida", "icon": "*"},
	"UMass": {"type": "safety", "sat_min": 1100, "label": "UMass Amherst", "icon": ""},
}

## Checklist items per college application
const CHECKLIST_ITEMS := [
	"sat_score",        # SAT above minimum
	"english_hours",    # 10+ hours of English class
	"essay_written",    # Essay written (desk action)
	"recommendation",   # Recommendation letter (talk to Brighta)
	"extracurricular",  # Special missions completed (20+ total missions)
]

# {character: {college_name: {checklist_item: bool}}}
var applications: Dictionary = {}
# {character: [college_name, ...]}
var college_lists: Dictionary = {}
# Track stats
var english_hours: Dictionary = {"gritty": 0, "smartle": 0}
var essays_written: Dictionary = {"gritty": false, "smartle": false}
var recommendations: Dictionary = {"gritty": false, "smartle": false}
var total_missions: Dictionary = {"gritty": 0, "smartle": 0}

## Has counselor (Smartle advantage)
var has_counselor: Dictionary = {"gritty": false, "smartle": true}


func setup_default_lists() -> void:
	# Gritty's dream is big but realistic
	college_lists["gritty"] = ["MIT", "BU", "ASU"]
	# Smartle has more options and counselor guidance
	college_lists["smartle"] = ["Stanford", "Columbia", "NYU", "UCF"]

	for character in college_lists:
		applications[character] = {}
		for college in college_lists[character]:
			applications[character][college] = {
				"sat_score": false,
				"english_hours": false,
				"essay_written": false,
				"recommendation": false,
				"extracurricular": false,
			}


func update_checklist(character: String, sat_score: int) -> void:
	if not applications.has(character):
		return

	for college_name in applications[character]:
		var college_info: Dictionary = COLLEGES[college_name]
		var checklist: Dictionary = applications[character][college_name]

		checklist.sat_score = sat_score >= college_info.sat_min
		checklist.english_hours = english_hours.get(character, 0) >= 10
		checklist.essay_written = essays_written.get(character, false)
		checklist.recommendation = recommendations.get(character, false)
		checklist.extracurricular = total_missions.get(character, 0) >= 20

	application_updated.emit(character, "")


func get_checklist_progress(character: String, college_name: String) -> Dictionary:
	if not applications.has(character) or not applications[character].has(college_name):
		return {}
	return applications[character][college_name]


func get_completion_count(character: String, college_name: String) -> int:
	var checklist := get_checklist_progress(character, college_name)
	var count := 0
	for key in checklist:
		if checklist[key]:
			count += 1
	return count


func evaluate_decisions(character: String, sat_score: int) -> Array:
	## Returns array of {college, accepted, reason}
	var results: Array = []
	if not college_lists.has(character):
		return results

	for college_name in college_lists[character]:
		var info: Dictionary = COLLEGES[college_name]
		var completed := get_completion_count(character, college_name)
		var total := CHECKLIST_ITEMS.size()

		var accepted := false
		var reason := ""

		if completed == total:
			accepted = true
			reason = "Application complete! [x]"
		elif completed >= 3 and sat_score >= info.sat_min:
			# Partial chance — counselor helps
			if has_counselor.get(character, false):
				accepted = true
				reason = "Counselor helped fill the gaps! [x]"
			else:
				accepted = (completed >= 4)
				reason = "Almost there... %d/%d requirements." % [completed, total] if not accepted else "Hard work recognized! [x]"
		else:
			reason = "Missing requirements (%d/%d)." % [completed, total]

		results.append({
			"college": college_name,
			"label": info.label,
			"icon": info.icon,
			"type": info.type,
			"accepted": accepted,
			"reason": reason,
		})

	return results
