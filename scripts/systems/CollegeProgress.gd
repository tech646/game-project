extends Node
class_name CollegeProgress

## Tracks SAT milestones and triggers notifications/end-game.

signal milestone_reached(character: String, milestone: String, score: int)
signal game_won(character: String)

const MILESTONES := {
	400: "Começando a jornada! 📖",
	800: "Progresso sólido! 📈",
	1200: "Faixa de aceitação universitária! 🎓",
	1600: "Pontuação perfeita! Sonho realizado! 🏆",
}

var _reached_milestones: Dictionary = {}  # {character: [reached scores]}


func _ready() -> void:
	# Check milestones when SAT changes on any player
	# Connected after players are setup
	pass


func check_score(character: String, score: int) -> void:
	if not _reached_milestones.has(character):
		_reached_milestones[character] = []

	var reached: Array = _reached_milestones[character]

	for threshold in MILESTONES:
		if score >= threshold and threshold not in reached:
			reached.append(threshold)
			var msg: String = MILESTONES[threshold]
			EventBus.warning_shown.emit("%s: %s" % [character.capitalize(), msg], "yellow")
			milestone_reached.emit(character, msg, score)

			if threshold == 1600:
				game_won.emit(character)
