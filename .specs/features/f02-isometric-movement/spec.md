# F02 — Isometric World & Movement Specification

## Problem Statement

The game needs a navigable isometric world where characters move with arrow keys on a tile-based grid. Without movement, the player cannot interact with objects, travel between rooms, or experience the game environments. This is the physical foundation for all gameplay.

## Goals

- [ ] Tile-based isometric map that renders the game environments
- [ ] Arrow key movement with proper isometric direction mapping
- [ ] Collision system preventing characters from walking through walls/furniture
- [ ] Y-sort rendering so characters appear behind/in front of objects correctly
- [ ] Camera following the active character

## Out of Scope

| Feature | Reason |
| --- | --- |
| Pathfinding / click-to-move | Arrow keys only for v1 |
| Scene transitions between locations | Deferred to F04-F06 (world building) |
| Object interaction (Enter key) | Deferred to F07 |
| Multiple rooms / locations | Only one test room for F02 |
| NPC movement | Deferred to F09 |

---

## User Stories

### P1: Isometric Tile Map ⭐ MVP

**User Story**: As a player, I want to see an isometric room rendered with tiles so that the game has the pixel art aesthetic defined in the art direction.

**Why P1**: No movement without a map to move on.

**Acceptance Criteria**:

1. WHEN the game loads THEN system SHALL display an isometric tile map with floor, walls, and basic furniture placeholders
2. WHEN tiles are rendered THEN they SHALL use isometric projection (2:1 ratio, typically 64x32 or 128x64 tiles)
3. WHEN the map is displayed THEN floor tiles SHALL form a walkable grid and wall tiles SHALL block movement
4. WHEN objects are placed THEN they SHALL snap to the isometric grid

**Independent Test**: Launch game, see an isometric room with floor and walls rendered correctly.

---

### P1: Character Movement ⭐ MVP

**User Story**: As a player, I want to move my character with arrow keys in isometric directions so that I can navigate the room.

**Why P1**: Core interaction — without movement there is no game.

**Acceptance Criteria**:

1. WHEN player presses Up arrow THEN character SHALL move diagonally up-right (isometric north)
2. WHEN player presses Down arrow THEN character SHALL move diagonally down-left (isometric south)
3. WHEN player presses Left arrow THEN character SHALL move diagonally up-left (isometric west)
4. WHEN player presses Right arrow THEN character SHALL move diagonally down-right (isometric east)
5. WHEN character moves THEN movement SHALL be smooth (not tile-snap) at consistent speed
6. WHEN character is moving THEN sprite SHALL face the direction of movement
7. WHEN no arrow key is pressed THEN character SHALL stand idle

**Independent Test**: Press arrow keys, character moves in correct isometric directions smoothly.

---

### P1: Collision System ⭐ MVP

**User Story**: As a player, I want my character to be blocked by walls and furniture so that the room feels solid and real.

**Why P1**: Without collision, characters walk through everything — breaks immersion.

**Acceptance Criteria**:

1. WHEN character walks into a wall tile THEN character SHALL stop and not pass through
2. WHEN character walks into a furniture object THEN character SHALL stop at the object boundary
3. WHEN character walks on floor tiles THEN movement SHALL be unobstructed
4. WHEN character slides along a wall THEN movement SHALL continue along the wall (no hard stop on diagonal walls)

**Independent Test**: Walk character into walls from all directions — character stops but can slide along.

---

### P1: Y-Sort Rendering ⭐ MVP

**User Story**: As a player, I want characters to appear behind objects that are "in front" of them and in front of objects "behind" them so that depth looks correct.

**Why P1**: Without Y-sort, isometric depth is broken and the game looks wrong.

**Acceptance Criteria**:

1. WHEN character walks behind a tall object THEN character SHALL render behind (occluded by) the object
2. WHEN character walks in front of an object THEN character SHALL render on top
3. WHEN two entities share the same Y position THEN rendering order SHALL be deterministic

**Independent Test**: Walk behind a table — character partially hidden. Walk in front — character visible.

---

### P1: Camera Follow ⭐ MVP

**User Story**: As a player, I want the camera to follow my character so that I can always see where I am.

**Why P1**: Rooms will be larger than the viewport — camera must track the player.

**Acceptance Criteria**:

1. WHEN character moves THEN camera SHALL smoothly follow the character (with slight lag/smoothing)
2. WHEN camera reaches map edge THEN camera SHALL stop scrolling (no empty space beyond map)
3. WHEN the game starts THEN camera SHALL be centered on the active character

**Independent Test**: Move character to edges of a room larger than viewport — camera follows smoothly and stops at boundaries.

---

### P2: Character Sprite & Animations

**User Story**: As a player, I want to see my character animated while walking and idle so that the game feels alive.

**Why P2**: Important for polish but the game works with a static sprite.

**Acceptance Criteria**:

1. WHEN character is idle THEN system SHALL show idle animation (subtle breathing/bobbing)
2. WHEN character walks THEN system SHALL show walk animation in the movement direction
3. WHEN character has 4+ directional sprites THEN system SHALL select correct direction sprite
4. WHEN character stops THEN animation SHALL transition to idle in the last facing direction

**Independent Test**: Walk in all 4 directions — see directional walk animations. Stop — see idle.

---

## Edge Cases

- WHEN player presses two arrow keys simultaneously (diagonal) THEN character SHALL move in the combined isometric direction
- WHEN character is at the edge of the walkable area THEN movement SHALL be blocked without jittering
- WHEN game is paused THEN character movement SHALL be disabled
- WHEN switching characters (future) THEN camera SHALL transition to the new character

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| --- | --- | --- | --- |
| MOV-01 | P1: Isometric Tile Map | Design | Pending |
| MOV-02 | P1: Character Movement | Design | Pending |
| MOV-03 | P1: Collision System | Design | Pending |
| MOV-04 | P1: Y-Sort Rendering | Design | Pending |
| MOV-05 | P1: Camera Follow | Design | Pending |
| MOV-06 | P2: Sprite & Animations | - | Pending |

**Coverage:** 6 total, 0 mapped to tasks, 6 unmapped ⚠️

---

## Success Criteria

- [ ] Isometric room renders with floor tiles and wall boundaries
- [ ] Character moves in 4 isometric directions with arrow keys
- [ ] Walls and objects block character movement
- [ ] Y-sort depth rendering is correct
- [ ] Camera follows character smoothly with edge clamping
