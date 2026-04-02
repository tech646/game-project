# F07-F09 — Interaction & Mechanics Specification

## Problem Statement

Players can see objects and needs bars, but can't interact with anything yet. The core gameplay loop requires pressing Enter near objects to perform actions (eat, sleep, study), which restore needs based on object quality. The inequality mechanics (compound penalties, commute effects) need to be fully wired. NPCs need basic presence.

## Goals

- [ ] Enter key opens interaction menu when near an object
- [ ] Performing actions restores needs (quality-multiplied) and costs time
- [ ] Compound inequality mechanics fully working in gameplay
- [ ] Brighta NPC with basic dialogue at school
- [ ] Homework and study actions trigger SAT progress

## Out of Scope

| Feature | Reason |
| --- | --- |
| SAT quiz questions | Deferred to F11 (M4) |
| Full NPC AI / pathfinding | v1 has static NPCs |
| Multiple interaction options per object | v1 has 1 action per object |
| Crafting / combining objects | Not in scope |

---

## User Stories

### P1: Object Interaction ⭐ MVP

**User Story**: As a player, I want to press Enter near an object to use it so that I can restore my character's needs.

**Acceptance Criteria**:

1. WHEN player is within 1 tile of an object AND presses Enter THEN system SHALL show interaction popup with: object name, quality stars, action name, time cost, expected restore amount
2. WHEN player confirms action THEN system SHALL: advance game clock by time_cost, restore the affected need by quality-adjusted amount, play a brief "using" animation/feedback
3. WHEN action completes THEN popup SHALL close and character returns to idle
4. WHEN player is NOT near any object AND presses Enter THEN nothing SHALL happen
5. WHEN multiple objects are nearby THEN system SHALL interact with the closest one
6. WHEN an activity is time-locked AND outside its window THEN interaction SHALL show 🔒 and the available time window

**Independent Test**: Walk to bed, press Enter, see popup, confirm, watch energy bar increase and clock advance.

---

### P1: Action Execution with Time Cost ⭐ MVP

**User Story**: As a player, I want actions to take game time so that I must choose wisely how to spend my day.

**Acceptance Criteria**:

1. WHEN an action starts THEN game clock SHALL advance by the action's time_cost
2. WHEN clock advances THEN needs SHALL continue decaying during the action
3. WHEN action is in progress THEN movement SHALL be disabled
4. WHEN action completes THEN a brief notification SHALL show what was restored (e.g., "+20 ⚡ Energia")

**Independent Test**: Use bed (120 min), clock jumps ~2 hours, energy increases, other needs decrease.

---

### P1: Quality-Based Restoration ⭐ MVP

**User Story**: As a player, I want higher quality objects to restore more needs so that I feel the inequality between Gritty and Smartle.

**Acceptance Criteria**:

1. WHEN Gritty uses Cama Velha (★☆☆☆☆, base 40) THEN energy SHALL restore 20 (40 × 0.5)
2. WHEN Smartle uses Cama King (★★★★★, base 40) THEN energy SHALL restore 64 (40 × 1.6)
3. WHEN interaction popup shows THEN expected restore amount SHALL be displayed with quality multiplier

**Independent Test**: Compare energy gain from 1-star bed vs 5-star bed.

---

### P1: Study Action → SAT Progress ⭐ MVP

**User Story**: As a player, I want studying to increase my SAT score so that I progress toward the college dream.

**Acceptance Criteria**:

1. WHEN player uses a study object (desk, library, tutor) THEN SAT score SHALL increase
2. WHEN study quality is higher THEN SAT gain SHALL be higher (quality multiplied)
3. WHEN SAT progress changes THEN SAT bar in HUD SHALL update
4. WHEN study action is at school desk during class hours THEN bonus SAT SHALL be awarded

**Base SAT gain per study session**: 10 points × quality multiplier

---

### P1: Homework Mechanic ⭐ MVP

**User Story**: As a player, I want homework to be required daily so that skipping it has consequences.

**Acceptance Criteria**:

1. WHEN day starts THEN homework_done flag SHALL be false for both characters
2. WHEN player studies at home desk THEN homework_done SHALL become true
3. WHEN day ends AND homework_done is false THEN character SHALL lose 5 SAT points
4. WHEN homework is done THEN a ✅ indicator SHALL show in the HUD

---

### P2: Brighta NPC Interaction

**User Story**: As a player, I want to talk to Brighta at school for encouragement and study tips.

**Acceptance Criteria**:

1. WHEN player presses Enter near Brighta THEN dialogue box SHALL show a message
2. WHEN dialogue shows THEN it SHALL be an English phrase (bilingual school theme)
3. WHEN dialogue closes THEN player returns to normal state

---

## Edge Cases

- WHEN player tries to use object while another action is in progress THEN system SHALL ignore
- WHEN action would advance clock past midnight THEN action SHALL complete and trigger day end
- WHEN need is already at 100 THEN restored amount SHALL be wasted (no overflow indication needed)
- WHEN player switches character during action THEN action SHALL continue for the acting character

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| INT-01 | P1: Object Interaction | Design | Pending |
| INT-02 | P1: Action Execution | Design | Pending |
| INT-03 | P1: Quality Restoration | Design | Pending |
| INT-04 | P1: Study → SAT | Design | Pending |
| INT-05 | P1: Homework | Design | Pending |
| INT-06 | P2: Brighta NPC | - | Pending |

**Coverage:** 6 total, 0 mapped to tasks, 6 unmapped ⚠️

---

## Success Criteria

- [ ] Enter near object opens interaction popup
- [ ] Actions restore needs (quality multiplied) and cost time
- [ ] Gritty's 1★ bed gives much less energy than Smartle's 5★ bed
- [ ] Studying increases SAT score
- [ ] Homework penalty applies when skipped
- [ ] Brighta shows dialogue at school
