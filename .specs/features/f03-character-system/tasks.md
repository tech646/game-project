# F03 — Character System Tasks

**Design**: `.specs/features/f03-character-system/design.md`
**Status**: Draft

---

## Execution Plan

```
Phase 1:  T1 → T2
Phase 2:  T2 → T3 (parallel: T4, T5)
Phase 3:  T3, T4, T5 → T6 → T7
```

---

## Task Breakdown

### T1: Create CharacterData resource + instances

**What**: Resource class for character config + gritty/smartle .tres files
**Where**: `scripts/data/CharacterData.gd`, `resources/gritty_data.tres`, `resources/smartle_data.tres`
**Depends on**: None
**Requirement**: CHR-01

**Done when**:
- [ ] CharacterData class with exports: name, display_name, sprite, starting needs, overnight recovery
- [ ] Gritty: hunger=50, energy=45, fun=60, recovery=50
- [ ] Smartle: hunger=80, energy=85, fun=70, recovery=85

**Verify**: Resources load without errors.

---

### T2: Create NeedsComponent

**What**: Reusable node script that manages hunger/energy/fun decay and signals
**Where**: `scripts/components/NeedsComponent.gd`
**Depends on**: T1
**Requirement**: CHR-01

**Done when**:
- [ ] Decays needs per GameClock.time_tick
- [ ] Compound mechanic: hunger < 40 → energy decays 2x; hunger < 20 → 3x
- [ ] Emits `need_changed(name, value, 100.0)` on each change
- [ ] Emits `need_critical(name, value)` when need < 40
- [ ] `modify_need(name, amount)` for external changes (eating, sleeping)
- [ ] `sat_score` with `modify_sat(amount)` and signal
- [ ] Clamps all values 0-100

**Verify**: Attach to node, observe decay in console prints over time.

---

### T3: Create CharacterManager autoload

**What**: Singleton that tracks both characters and handles Tab switching
**Where**: `autoloads/CharacterManager.gd`
**Depends on**: T2
**Requirement**: CHR-03

**Done when**:
- [ ] Registers both players on _ready (via groups)
- [ ] `switch_character()` toggles active player
- [ ] `get_active_player()` / `get_inactive_player()`
- [ ] Emits `character_switched(name)`
- [ ] Tab input calls switch_character
- [ ] Disables input on inactive player, enables on active
- [ ] Both characters' needs decay regardless of active status

**Verify**: Press Tab, active player changes, other stops responding to input.

---

### T4: Create NeedsBarsUI [P]

**What**: HUD panel with 4 progress bars (hunger, energy, fun, SAT)
**Where**: `scenes/ui/NeedsBars.tscn` + `scenes/ui/NeedsBars.gd`
**Depends on**: T2
**Requirement**: CHR-02, CHR-05

**Done when**:
- [ ] 3 needs bars + 1 SAT bar in VBoxContainer
- [ ] Bars update when active character's NeedsComponent emits need_changed
- [ ] Color transitions: green (>50), yellow (20-50), red (<20)
- [ ] SAT bar always blue with "SAT: X/1600" label
- [ ] Bars have labels with icons (🍖 hunger, ⚡ energy, 🎮 fun)
- [ ] Smooth tween on value change
- [ ] Updates on character switch

**Verify**: Watch bars drain and change color over time.

---

### T5: Create ExpressionIcon component [P]

**What**: Floating emoji above character head based on most critical need
**Where**: `scripts/components/ExpressionIcon.gd`
**Depends on**: T2
**Requirement**: CHR-04

**Done when**:
- [ ] Label node positioned above character sprite
- [ ] Updates on need_changed/need_critical signals
- [ ] Priority: exhausted > starving > tired > hungry > bored > happy
- [ ] Gentle bobbing tween animation
- [ ] Only shows when a need triggers it

**Verify**: Let needs decay, see emoji change above character.

---

### T6: Add second character (Smartle) to TestRoom

**What**: Instance Smartle in TestRoom alongside Gritty, both with NeedsComponent + ExpressionIcon
**Where**: `scenes/main/Main.tscn` or `scenes/world/TestRoom.tscn` (modify)
**Depends on**: T3, T4, T5
**Requirement**: CHR-03

**Done when**:
- [ ] Smartle Player instance at different position in room
- [ ] Uses Smartle sprite and starting stats
- [ ] Both have NeedsComponent and ExpressionIcon
- [ ] CharacterManager tracks both
- [ ] Tab switches between them

**Verify**: See both characters in room, Tab switches control and camera.

---

### T7: Integrate NeedsBars + Portrait into HUD

**What**: Add NeedsBarsUI and active character portrait to Main HUD
**Where**: `scenes/main/Main.tscn` (modify)
**Depends on**: T6
**Requirement**: CHR-02

**Done when**:
- [ ] NeedsBars visible in HUD right side
- [ ] Small portrait showing active character name/icon
- [ ] Bars update on character switch
- [ ] All F01 elements still work (clock, warnings, pause)

**Verify**: Full integration — clock runs, needs decay, Tab switches, bars update, expressions show.

---

## Parallel Execution Map

```
Phase 1 (Sequential):
  T1 ──→ T2

Phase 2 (T2 complete, then parallel):
  T2 ──→ T3
  T2 ──→ T4 [P]
  T2 ──→ T5 [P]

Phase 3 (Sequential):
  T3, T4, T5 ──→ T6 ──→ T7
```

---

## Commit Plan

| Task | Commit |
| --- | --- |
| T1 | `feat(data): create CharacterData resource for Gritty and Smartle` |
| T2 | `feat(needs): add NeedsComponent with decay and compound mechanics` |
| T3 | `feat(manager): add CharacterManager autoload with Tab switching` |
| T4 | `feat(ui): add NeedsBars with color-coded progress bars` |
| T5 | `feat(expression): add floating emoji ExpressionIcon component` |
| T6 | `feat(characters): add Smartle as second playable character` |
| T7 | `feat(hud): integrate NeedsBars and portrait into Main HUD` |
