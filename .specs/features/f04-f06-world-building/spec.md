# F04-F06 — World Building Specification

## Problem Statement

The game needs three distinct locations: Gritty's favela home, Smartle's mansion, and the shared school. Each location must feel different through object quality, room size, and available amenities. Players need to navigate between locations via a scene transition system.

## Goals

- [ ] Three navigable isometric locations with unique visual identity
- [ ] Object quality system (1-5 stars) affecting gameplay
- [ ] Scene transition system to move between locations
- [ ] Each character starts at their home, school is shared
- [ ] Objects placed per location matching the narrative

## Out of Scope

| Feature | Reason |
| --- | --- |
| Full pixel art tiles | Placeholder colors for now, art comes in M5 |
| Object interaction logic | Deferred to F07 |
| Commute animation | Already handled by CommuteManager |
| Multiple rooms per location | v1 has 1 room per location |

---

## User Stories

### P1: Favela Home (F04) ⭐ MVP

**User Story**: As a player controlling Gritty, I want a small, cramped favela room with low-quality objects so that I feel the resource constraints.

**Acceptance Criteria**:

1. WHEN game starts THEN Gritty SHALL be in his favela room (8x8 tiles, small)
2. WHEN player looks around THEN room SHALL contain: old bed (★☆☆☆☆), basic stove (★★☆☆☆), old TV (★☆☆☆☆), simple desk (★☆☆☆☆), old fridge (★☆☆☆☆)
3. WHEN player views objects THEN quality stars SHALL be visible
4. WHEN room is displayed THEN walls SHALL use brick/brown tones (favela aesthetic)

---

### P1: Mansion Home (F05) ⭐ MVP

**User Story**: As a player controlling Smartle, I want a large, luxurious mansion room with high-quality objects so that I feel the abundance of resources.

**Acceptance Criteria**:

1. WHEN game starts THEN Smartle SHALL be in her mansion room (14x14 tiles, spacious)
2. WHEN player looks around THEN room SHALL contain: king bed (★★★★★), gamer setup (★★★★★), gourmet kitchen (★★★★☆), gym equipment (★★★★☆), home theater (★★★★★)
3. WHEN player views objects THEN quality stars SHALL be visible
4. WHEN room is displayed THEN walls SHALL use light/pink tones (luxury aesthetic)

---

### P1: School (F06) ⭐ MVP

**User Story**: As a player, I want a shared school where both characters attend classes, with medium-quality objects.

**Acceptance Criteria**:

1. WHEN character commutes to school THEN scene SHALL transition to school location
2. WHEN player looks around THEN school SHALL contain: classroom desks (★★★☆☆), cafeteria table (★★☆☆☆), library desk (★★★☆☆), teacher's desk (★★★☆☆)
3. WHEN at school THEN Brighta teacher placeholder SHALL be visible
4. WHEN school hours end THEN characters SHALL be prompted to go home

---

### P1: Scene Transitions ⭐ MVP

**User Story**: As a player, I want to move between locations so that the game world feels connected.

**Acceptance Criteria**:

1. WHEN character reaches a door/exit tile THEN system SHALL offer scene transition
2. WHEN transition starts THEN screen SHALL fade to black, load new scene, fade in
3. WHEN arriving at new location THEN character SHALL appear at the entrance
4. WHEN commute is triggered THEN system SHALL auto-transition to school
5. WHEN switching characters THEN scene SHALL transition to the other character's location if different

---

### P1: Object Quality System ⭐ MVP

**User Story**: As a player, I want objects to have quality ratings that affect how much they restore needs.

**Acceptance Criteria**:

1. WHEN object has quality 1 THEN it SHALL restore 50% of base amount
2. WHEN object has quality 2 THEN it SHALL restore 75% of base amount
3. WHEN object has quality 3 THEN it SHALL restore 100% (base)
4. WHEN object has quality 4 THEN it SHALL restore 130%
5. WHEN object has quality 5 THEN it SHALL restore 160%
6. WHEN player views object THEN quality stars SHALL appear below the object name

---

## Edge Cases

- WHEN switching characters in different locations THEN camera SHALL transition to the correct location
- WHEN both characters are at school THEN both SHALL be visible
- WHEN time-locked activity window closes while at school THEN character stays but activity is locked

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| WLD-01 | P1: Favela Home | Design | Pending |
| WLD-02 | P1: Mansion Home | Design | Pending |
| WLD-03 | P1: School | Design | Pending |
| WLD-04 | P1: Scene Transitions | Design | Pending |
| WLD-05 | P1: Object Quality | Design | Pending |

**Coverage:** 5 total, 0 mapped to tasks, 5 unmapped ⚠️

---

## Success Criteria

- [ ] Three locations rendered with distinct visual identity (size, colors)
- [ ] Objects placed with quality stars visible
- [ ] Scene transitions work (fade in/out)
- [ ] Character switch across locations works
- [ ] Quality multiplier affects need restoration values
