# F01 — Game Loop & Clock Specification

## Problem Statement

The game needs a time system that drives all mechanics — schedule constraints, commute timing, daily missions, and inequality effects all depend on a functioning game clock. Without this foundation, no other feature can work.

## Goals

- [ ] Functional game clock that progresses in-game time at a configurable speed
- [ ] Day/night cycle with visual time indicator
- [ ] Schedule system that gates activities by time windows
- [ ] Day transitions with stat resets and daily mission triggers

## Out of Scope

| Feature | Reason |
| --- | --- |
| Weather system | Not in v1 scope |
| Seasons/calendar | Unnecessary complexity for v1 |
| Save/load time state | Deferred to later feature |
| Multiple time speeds (pause/fast-forward) | P3, not needed for MVP |

---

## User Stories

### P1: Game Clock Display ⭐ MVP

**User Story**: As a player, I want to see the current in-game time so that I can plan my character's actions around schedule constraints.

**Why P1**: Every mechanic depends on knowing the current time — school hours, commute deadlines, activity windows.

**Acceptance Criteria**:

1. WHEN the game starts THEN clock SHALL display time in HH:MM format starting at 06:00
2. WHEN the game is running THEN clock SHALL advance 1 in-game minute every 1 real second (configurable ratio)
3. WHEN time reaches a schedule boundary (e.g., 07:15 for Gritty's bus) THEN clock SHALL visually pulse red
4. WHEN time is displayed THEN it SHALL be visible in the top bar HUD at all times

**Independent Test**: Launch game, observe clock counting from 06:00 upward in real-time.

---

### P1: Day Cycle ⭐ MVP

**User Story**: As a player, I want each in-game day to start and end so that daily missions reset and I experience the rhythm of the characters' routines.

**Why P1**: The core loop IS the daily routine — wake up, commute, school, study, sleep.

**Acceptance Criteria**:

1. WHEN clock reaches 06:00 THEN system SHALL trigger "day start" — reset daily missions, show day number
2. WHEN clock reaches 23:00 THEN system SHALL show "time to sleep" warning
3. WHEN clock reaches 00:00 (midnight) THEN system SHALL force-end the day with energy penalty if character hasn't slept
4. WHEN a new day starts THEN system SHALL increment day counter and show "Day N" briefly on screen
5. WHEN day ends THEN system SHALL apply overnight stat changes (different for Gritty vs Smartle)

**Independent Test**: Let clock run from 06:00 to 00:00, verify day transition fires and stats reset.

---

### P1: Schedule Constraints ⭐ MVP

**User Story**: As a player, I want activities to be locked/unlocked by time so that I feel the pressure of managing a tight schedule.

**Why P1**: Schedule pressure is the core inequality mechanic — Gritty has less margin than Smartle.

**Acceptance Criteria**:

1. WHEN player tries to start a time-locked activity outside its window THEN system SHALL show lock icon (🔒) and time window
2. WHEN current time enters an activity window THEN system SHALL unlock the activity and show available indicator
3. WHEN an activity window is about to open (15 min before) THEN system SHALL show subtle notification

**Schedule windows:**
- English class: 08:00–11:00
- Cafeteria: 11:30–14:00
- SAT Extra: 15:00–17:00
- Homework: anytime at home (but penalized if not done by 22:00)

**Independent Test**: Try to access cafeteria at 08:00 — should be locked. Try at 12:00 — should be open.

---

### P1: Commute Deadlines ⭐ MVP

**User Story**: As a player, I want to feel the time pressure of getting to school on time, with different constraints per character.

**Why P1**: The commute mechanic is the most tangible expression of inequality in the game.

**Acceptance Criteria**:

1. WHEN Gritty hasn't left home by 07:15 THEN system SHALL show animated warning "⚠️ Hora de ir à escola!"
2. WHEN Smartle hasn't left home by 07:45 THEN system SHALL show the same warning
3. WHEN character arrives at school after 08:00 THEN system SHALL apply lateness penalty: -SAT points proportional to delay (every 5 min late = penalty shown on screen)
4. WHEN character triggers commute THEN system SHALL show commute animation (bus for Gritty ~45min, car for Smartle ~15min) and advance clock accordingly
5. WHEN commute is in progress THEN system SHALL drain energy (more for Gritty on bus than Smartle in car)

**Independent Test**: Start as Gritty at 07:00, trigger commute at 07:15, verify arrival at ~08:00. Start at 07:30, verify late penalty.

---

### P2: Time Speed Control

**User Story**: As a player, I want to speed up or pause time so that I can skip boring waits or think about my next move.

**Why P2**: Improves UX but not essential for core loop to function.

**Acceptance Criteria**:

1. WHEN player presses [Space] THEN system SHALL toggle pause (clock stops, "PAUSED" overlay)
2. WHEN player presses [+] THEN system SHALL increase speed to 2x (1 min = 0.5 sec)
3. WHEN player presses [-] THEN system SHALL return to 1x speed
4. WHEN game is paused THEN player SHALL still be able to view stats and mission panel

**Independent Test**: Press Space — clock freezes. Press again — clock resumes.

---

### P3: Visual Day/Night Ambiance

**User Story**: As a player, I want the lighting to subtly change through the day for immersion.

**Why P3**: Pure polish — nice but not functional.

**Acceptance Criteria**:

1. WHEN time is 06:00–08:00 THEN scene SHALL have warm morning tint
2. WHEN time is 12:00–14:00 THEN scene SHALL have bright daylight
3. WHEN time is 18:00–20:00 THEN scene SHALL have orange sunset tint
4. WHEN time is 21:00+ THEN scene SHALL have dark blue night tint

---

## Edge Cases

- WHEN player switches character mid-commute THEN system SHALL continue commute for original character in background
- WHEN both characters need to commute at the same time THEN system SHALL show split-screen or auto-commute the inactive character
- WHEN player is in a time-locked activity and the window closes THEN system SHALL gracefully end the activity with partial credit
- WHEN clock advances during an interaction menu THEN time SHALL continue (no free pauses)

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| CLK-01 | P1: Game Clock Display | Design | Pending |
| CLK-02 | P1: Day Cycle | Design | Pending |
| CLK-03 | P1: Schedule Constraints | Design | Pending |
| CLK-04 | P1: Commute Deadlines | Design | Pending |
| CLK-05 | P2: Time Speed Control | - | Pending |
| CLK-06 | P3: Visual Day/Night | - | Pending |

**Coverage:** 6 total, 0 mapped to tasks, 6 unmapped ⚠️

---

## Success Criteria

- [ ] Clock runs continuously and displays correctly in HUD
- [ ] Day starts at 06:00, ends at 00:00, with proper transitions
- [ ] All 4 schedule windows (class, cafeteria, SAT, homework) lock/unlock correctly
- [ ] Gritty and Smartle have different commute times with correct penalties
- [ ] Late arrival penalty calculates and displays correctly
