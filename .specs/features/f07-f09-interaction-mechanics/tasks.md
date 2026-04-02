# F07-F09 Tasks

**Design**: `.specs/features/f07-f09-interaction-mechanics/design.md`
**Status**: Draft

---

## Execution Plan

```
Phase 1:  T1 → T2 → T3
Phase 2:  T3 → T4 [P], T5 [P]
Phase 3:  T4,T5 → T6 → T7
```

---

### T1: Create InteractionDetector component

**What**: Script on Player's Area2D that detects nearby GameObjects
**Where**: `scripts/components/InteractionDetector.gd`
**Depends on**: None
**Requirement**: INT-01

**Done when**:
- [ ] Detects GameObjects overlapping the Area2D
- [ ] `get_nearest_object() -> GameObject` returns closest or null
- [ ] Detection radius ~60px

---

### T2: Create InteractionPopup UI

**What**: Panel showing object info + confirm/cancel hint
**Where**: `scenes/ui/InteractionPopup.tscn` + `.gd`
**Depends on**: T1
**Requirement**: INT-01

**Done when**:
- [ ] Shows object name, quality stars, action, time cost, restore amount
- [ ] Enter confirms, Esc cancels
- [ ] Hidden by default, shown when Enter near object
- [ ] Shows 🔒 for time-locked activities outside window

---

### T3: Create ActionExecutor

**What**: Executes actions: clock advance, need restore, SAT gain, feedback
**Where**: `scripts/components/ActionExecutor.gd`
**Depends on**: T2
**Requirement**: INT-02, INT-03, INT-04

**Done when**:
- [ ] Disables movement during action
- [ ] Advances clock by time_cost
- [ ] Restores need by quality-adjusted amount
- [ ] Study objects add SAT: 10 × quality_multiplier
- [ ] Shows "+X ⚡" notification on completion
- [ ] Re-enables movement after

---

### T4: Add homework tracking [P]

**What**: homework_done flag on NeedsComponent, penalty on day end
**Where**: `scripts/components/NeedsComponent.gd` (modify) + `scenes/main/Main.gd` (modify)
**Depends on**: T3
**Requirement**: INT-05

**Done when**:
- [ ] `homework_done: bool` on NeedsComponent, reset each day
- [ ] Study at home desk sets homework_done = true
- [ ] Day end: if !homework_done → -5 SAT + warning
- [ ] ✅ indicator near SAT bar when homework done

---

### T5: Create DialogueBox + Brighta interaction [P]

**What**: Simple dialogue UI + Brighta NPC responds to Enter
**Where**: `scenes/ui/DialogueBox.tscn` + `.gd`, `scenes/locations/School.gd` (modify)
**Depends on**: T3
**Requirement**: INT-06

**Done when**:
- [ ] DialogueBox shows speaker name + text
- [ ] Enter dismisses dialogue
- [ ] Brighta has Area2D, Enter shows a random English phrase
- [ ] Movement paused during dialogue

---

### T6: Wire interaction into Player

**What**: Player.gd handles Enter key → detect → popup → execute flow
**Where**: `scenes/characters/Player.gd` (modify), `scenes/characters/Player.tscn` (modify)
**Depends on**: T4, T5
**Requirement**: INT-01, INT-02

**Done when**:
- [ ] Enter key triggers interaction flow
- [ ] InteractionDetector on Player's Area2D
- [ ] InteractionPopup shown in HUD
- [ ] ActionExecutor processes confirmed actions
- [ ] Dialogue triggered for NPCs

---

### T7: Integrate into Main HUD + test

**What**: Add InteractionPopup and DialogueBox to Main HUD
**Where**: `scenes/main/Main.tscn` (modify)
**Depends on**: T6
**Requirement**: INT-01

**Done when**:
- [ ] InteractionPopup in HUD CanvasLayer
- [ ] DialogueBox in HUD CanvasLayer
- [ ] Full flow works: walk → Enter → popup → confirm → restore → notify

---

## Commit Plan

| Task | Commit |
| --- | --- |
| T1 | `feat(interaction): add InteractionDetector for nearby objects` |
| T2 | `feat(ui): add InteractionPopup with object info` |
| T3 | `feat(action): add ActionExecutor with clock advance and need restore` |
| T4 | `feat(homework): add daily homework tracking with SAT penalty` |
| T5 | `feat(dialogue): add DialogueBox and Brighta NPC interaction` |
| T6 | `feat(player): wire interaction flow into Player` |
| T7 | `feat(hud): integrate interaction UI into Main` |
