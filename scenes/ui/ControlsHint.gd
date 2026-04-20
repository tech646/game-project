extends PanelContainer

## Always-visible controls hint panel.
## Shows basic controls and current location tip.

@onready var controls_label: Label = $Margin/VBox/ControlsLabel
@onready var tip_label: Label = $Margin/VBox/TipLabel


const LOCATION_TIPS := {
	"favela_bedroom": "TIP: Sleep in the bed after 20:00 to end the day.",
	"favela_kitchen": "TIP: Eat at the stove or fridge to restore Hunger.",
	"mansion": "TIP: Sleep in the bed after 20:00 to end the day.",
	"mansion_kitchen": "TIP: Eat at the stove or fridge to restore Hunger.",
	"classroom": "TIP: Study at the desk and talk to Mrs Brighta.",
	"library": "TIP: Read books to gain SAT points.",
	"cafeteria": "TIP: Eat lunch between 12:00 and 13:30.",
	"gym": "TIP: Exercise to boost Mental Health.",
}


func _ready() -> void:
	controls_label.text = "Arrows: Move   |   Enter: Interact   |   Tab: Switch   |   Space: Pause"
	tip_label.text = ""


func set_location_tip(location: String) -> void:
	tip_label.text = LOCATION_TIPS.get(location, "")
