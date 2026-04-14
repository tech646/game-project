extends Node

## Global signal bus for cross-system communication.
## Any node can emit/connect to these signals without direct references.

# Commute
signal commute_started(character: String, mode: String)
signal commute_finished(character: String, late_minutes: int)

# Schedule & Activities
signal activity_locked(activity: String, unlock_time: String)
signal activity_unlocked(activity: String)

# Warnings & UI
signal warning_shown(message: String, color: String)

# Day cycle
signal day_started(day: int)
signal day_ended(day: int)

# Stats
signal sat_penalty(character: String, amount: int, reason: String)
signal energy_changed(character: String, amount: float)

# Curfew (Smartle only — favela violence prevents leaving)
signal curfew_started
signal curfew_ended
