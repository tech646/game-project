extends Resource
class_name CharacterData

@export var character_name: String = ""
@export var display_name: String = ""
@export var sprite_path: String = ""
@export var starting_hunger: float = 50.0
@export var starting_energy: float = 45.0
@export var starting_fun: float = 60.0
@export var overnight_recovery: float = 50.0
@export var commute_mode: String = "bus"
@export var commute_leave_by: int = 435       # minutes since 00:00
@export var commute_travel_time: int = 45
@export var commute_energy_cost: float = 15.0
