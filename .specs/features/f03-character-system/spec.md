# F03 — Character System Specification

## Problem Statement

The game needs two playable characters (Gritty and Smartle) with needs that decay over time and a way to switch between them. The needs system (hunger, energy, fun) drives the core gameplay loop — managing resources under different conditions of inequality. Without this, there's no simulation.

## Goals

- [ ] Two characters with independent needs bars (hunger, energy, fun)
- [ ] Needs decay over time at different rates per character
- [ ] Visual expressions that change based on needs levels
- [ ] Switchable active character control
- [ ] SAT progress bar per character

## Out of Scope

| Feature | Reason |
| --- | --- |
| Object interaction to restore needs | Deferred to F07 |
| Full expression sprite animations | P2, start with floating icons |
| Character customization | Not in v1 |
| Brighta NPC | Deferred to F09 |

---

## User Stories

### P1: Needs System ⭐ MVP

**User Story**: As a player, I want my characters to have hunger, energy, and fun needs that decay over time so that I must manage their daily routine.

**Why P1**: Core simulation mechanic — without needs, there's no game pressure.

**Acceptance Criteria**:

1. WHEN game is running THEN each character's needs SHALL decay every game minute
2. WHEN hunger drops below 40 THEN energy SHALL decay faster (compound inequality mechanic)
3. WHEN any need reaches 0 THEN character SHALL be unable to perform related actions
4. WHEN needs change THEN values SHALL be clamped between 0 and 100

**Decay rates (per game minute):**
- Hunger: -0.15 (both characters)
- Energy: -0.1 base, -0.2 if hunger < 40 (compound)
- Fun: -0.08 (both characters)

**Starting values:**
- Gritty: hunger=50, energy=45, fun=60 (worse bed, less food)
- Smartle: hunger=80, energy=85, fun=70 (chef, king bed)

**Independent Test**: Run game, watch needs bars decrease over time.

---

### P1: Needs Bars UI ⭐ MVP

**User Story**: As a player, I want to see visual bars showing each need so I can make informed decisions about what to do next.

**Why P1**: Without visual feedback, player can't manage needs.

**Acceptance Criteria**:

1. WHEN game is running THEN HUD SHALL show 3 needs bars + 1 SAT progress bar
2. WHEN a need value changes THEN its bar SHALL update with smooth animation
3. WHEN a need is below 40 THEN its bar SHALL turn yellow (warning)
4. WHEN a need is below 20 THEN its bar SHALL turn red (critical)
5. WHEN SAT progress changes THEN SAT bar SHALL update (blue color, different from needs)

**Independent Test**: Watch bars drain from green to yellow to red.

---

### P1: Character Switch ⭐ MVP

**User Story**: As a player, I want to switch between Gritty and Smartle so I can manage both characters' days.

**Why P1**: Game requires controlling both characters — can't play with only one.

**Acceptance Criteria**:

1. WHEN player presses [Tab] THEN active character SHALL switch to the other
2. WHEN switching THEN camera SHALL transition to the new character's position
3. WHEN switching THEN HUD needs bars SHALL update to show the new character's stats
4. WHEN inactive THEN the other character's needs SHALL still decay in background
5. WHEN switching THEN a small portrait indicator SHALL show which character is active

**Independent Test**: Press Tab — camera moves to other character, bars change values.

---

### P1: Character Expressions ⭐ MVP

**User Story**: As a player, I want to see my character's mood through floating icons so I know which needs are critical without checking bars.

**Why P1**: Key visual feedback that makes the game feel alive and communicates urgency.

**Acceptance Criteria**:

1. WHEN energy < 40 THEN 😪 icon SHALL float above character head
2. WHEN energy < 20 THEN ✖✖ icon SHALL float with zzz animation
3. WHEN hunger < 40 THEN 😟 icon SHALL float above character head
4. WHEN hunger < 20 THEN 💧 icon SHALL float above character head
5. WHEN fun < 30 THEN 😑 icon SHALL float above character head
6. WHEN all needs > 50 THEN 😊 icon SHALL float (happy)
7. WHEN multiple needs are low THEN the most critical SHALL be shown

**Independent Test**: Let needs decay, see icons change above character.

---

### P2: SAT Progress Tracking

**User Story**: As a player, I want to see how close each character is to their college admission goal.

**Why P2**: Important for endgame but not needed for core loop.

**Acceptance Criteria**:

1. WHEN SAT points are earned/lost THEN progress bar SHALL update
2. WHEN SAT bar is displayed THEN it SHALL show current/target (e.g., 450/1600)
3. WHEN character reaches SAT target THEN system SHALL emit completion signal

---

## Edge Cases

- WHEN both characters have critical needs THEN the inactive one SHALL still decay (no free pause)
- WHEN switching during commute THEN commute SHALL continue for the commuting character
- WHEN energy reaches 0 THEN character SHALL auto-sleep (forced end of activities)
- WHEN hunger reaches 0 THEN energy decay doubles again (stacking penalty)

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| CHR-01 | P1: Needs System | Design | Pending |
| CHR-02 | P1: Needs Bars UI | Design | Pending |
| CHR-03 | P1: Character Switch | Design | Pending |
| CHR-04 | P1: Expressions | Design | Pending |
| CHR-05 | P2: SAT Progress | - | Pending |

**Coverage:** 5 total, 0 mapped to tasks, 5 unmapped ⚠️

---

## Success Criteria

- [ ] Both characters have independent needs that decay over time
- [ ] Gritty starts with worse stats than Smartle
- [ ] Needs bars display green → yellow → red transitions
- [ ] Tab switches character with camera transition
- [ ] Floating icons appear when needs are low
- [ ] Compound hunger→energy penalty works
