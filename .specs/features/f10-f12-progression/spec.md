# F10-F12 — Progression & Education Specification

## Problem Statement

The game needs a daily mission system to guide player behavior, SAT quiz integration for study interactions, and a college progress bar as the end-game goal. Without these, the game has no structure or win condition.

## Goals

- [ ] 10 daily missions with completion tracking and SAT bonus
- [ ] SAT quiz questions appear when studying/in class
- [ ] College progress bar with clear target and end-game condition
- [ ] Missions panel visible in HUD

## Out of Scope

| Feature | Reason |
| --- | --- |
| Live CollegeBoard API | Manual question bank instead |
| Adaptive difficulty | v1 uses random questions |
| Multiple choice explanations | v1 shows correct answer only |
| Leaderboard | Not in v1 |

---

## User Stories

### P1: Daily Mission System (F10) ⭐ MVP

**User Story**: As a player, I want daily missions to guide my routine and earn SAT bonus points.

**Acceptance Criteria**:

1. WHEN a new day starts THEN system SHALL generate 10 missions for each character
2. WHEN mission list is displayed THEN each mission SHALL show: icon, description, ⬜/✅ status
3. WHEN a mission is completed THEN it SHALL auto-detect and mark ✅ with SAT bonus
4. WHEN all missions are done THEN a bonus reward SHALL be given

**Mission types (generated daily):**
- 📚 Ir à escola — detected on commute arrival
- ✏️ Estudar — detected on study action
- 🥣 Comer — detected on eat action
- 😴 Dormir — detected on sleep action
- 🎮 Diversão — detected on fun action
- 📖 Fazer dever de casa — detected on home study
- 🕐 Chegar na hora — detected if not late
- Plus 3 rotational bonus missions

**SAT bonus per mission**: +3 points
**All-complete bonus**: +10 extra SAT

---

### P1: SAT Quiz Integration (F11) ⭐ MVP

**User Story**: As a player, I want to answer real SAT questions when studying so that education is central to gameplay.

**Acceptance Criteria**:

1. WHEN player studies (desk, library, tutor, class) THEN a SAT question SHALL appear
2. WHEN question appears THEN it SHALL show: question text, 4 options (A/B/C/D)
3. WHEN player selects correct answer THEN SAT bonus SHALL be awarded (+5 extra)
4. WHEN player selects wrong answer THEN correct answer SHALL be shown briefly
5. WHEN question is from official source THEN reference SHALL be noted

**Question format**: Multiple choice, 4 options, reading/writing + math domains

---

### P1: College Progress Bar (F12) ⭐ MVP

**User Story**: As a player, I want to see how close I am to getting into a US college.

**Acceptance Criteria**:

1. WHEN HUD is displayed THEN SAT bar SHALL show current/target (X/1600)
2. WHEN SAT reaches 1200 THEN system SHALL show "College acceptance range!"
3. WHEN SAT reaches 1600 THEN system SHALL show "Perfect score! Dream achieved!" and trigger end-game
4. WHEN comparing characters THEN both SAT scores SHALL be trackable

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| PRG-01 | P1: Daily Missions | Design | Pending |
| PRG-02 | P1: SAT Quiz | Design | Pending |
| PRG-03 | P1: College Progress | Design | Pending |

---

## Success Criteria

- [ ] 10 missions appear each day with auto-detection
- [ ] SAT questions appear on study actions
- [ ] Correct answers give bonus SAT
- [ ] SAT bar tracks progress toward 1600
- [ ] End-game triggers at 1600
