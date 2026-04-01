extends Node2D

## Main scene — root of the game. Holds HUD and world placeholder.
## Manages day cycle, schedule, and commute systems.

@onready var clock_display: Control = $HUD/TopBar/ClockDisplay
@onready var warning_popup: Control = $HUD/WarningPopup
@onready var pause_overlay: ColorRect = $HUD/PauseOverlay
@onready var schedule_manager: Node = $Systems/ScheduleManager
@onready var commute_manager: Node = $Systems/CommuteManager

func _ready() -> void:
	pause_overlay.visible = false
	GameState.state_changed.connect(_on_state_changed)
	schedule_manager.add_to_group("schedule_manager")


func _on_state_changed(_old_state: GameState.State, new_state: GameState.State) -> void:
	pause_overlay.visible = (new_state == GameState.State.PAUSED)
