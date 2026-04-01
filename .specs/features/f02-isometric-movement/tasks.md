# F02 — Isometric World & Movement Tasks

**Design**: `.specs/features/f02-isometric-movement/design.md`
**Status**: Draft

---

## Execution Plan

### Phase 1: Foundation (Sequential)

```
T1 → T2
```

### Phase 2: Core (Sequential, depends on T2)

```
T2 → T3 → T4
```

### Phase 3: Polish (Parallel after T4)

```
      ┌→ T5 [P]
T4 ───┤
      └→ T6 [P]
```

### Phase 4: Integration

```
T5, T6 → T7
```

---

## Task Breakdown

### T1: Create isometric TileSet resource with placeholder tiles

**What**: Create a TileSet resource with 128x64 isometric tiles — floor tile (no collision) and wall tile (with collision polygon)
**Where**: `resources/isometric_tileset.tres` (created via GDScript tool since .tres is complex)
**Depends on**: None
**Requirement**: MOV-01

**Done when**:
- [ ] TileSet with tile_shape = ISOMETRIC, tile_size = 128x64
- [ ] Floor tile source (colored placeholder)
- [ ] Wall tile source with physics collision polygon
- [ ] Resource loads without errors in Godot

**Verify**: Load resource in editor, tiles visible in TileMap painter.

---

### T2: Create TestRoom scene with isometric TileMapLayers

**What**: Scene with GroundLayer (floor) and WallsLayer (walls with collision), forming a small enclosed room
**Where**: `scenes/world/TestRoom.tscn` + `scenes/world/TestRoom.gd`
**Depends on**: T1
**Requirement**: MOV-01, MOV-04

**Done when**:
- [ ] GroundLayer with floor tiles forming ~10x10 walkable area
- [ ] WallsLayer with wall tiles surrounding the room
- [ ] YSortRoot Node2D with y_sort_enabled = true
- [ ] WallsLayer inside YSortRoot for depth sorting
- [ ] Room renders correctly in isometric view

**Verify**: Open TestRoom.tscn in editor, isometric room visible.

---

### T3: Create Player scene with movement

**What**: CharacterBody2D with arrow key isometric movement and collision
**Where**: `scenes/characters/Player.tscn` + `scenes/characters/Player.gd`
**Depends on**: T2
**Requirement**: MOV-02, MOV-03

**Done when**:
- [ ] CharacterBody2D with CollisionShape2D (small circle/capsule)
- [ ] Sprite2D with Gritty character image (placeholder, scaled down)
- [ ] Arrow keys map to isometric directions (ISO_UP/DOWN/LEFT/RIGHT)
- [ ] `move_and_slide()` handles collision with wall tiles
- [ ] Movement disabled when GameState != PLAYING
- [ ] Speed configurable via @export

**Verify**: Run game, press arrows — character moves in correct isometric directions. Walk into walls — character stops.

---

### T4: Add Camera2D to Player with follow and limits

**What**: Camera2D child of Player with smoothing and edge clamping
**Where**: `scenes/characters/Player.tscn` (modify) + `scenes/characters/Player.gd` (modify)
**Depends on**: T3
**Requirement**: MOV-05

**Done when**:
- [ ] Camera2D as child of Player
- [ ] position_smoothing_enabled = true, speed = 5.0
- [ ] Camera limits set to map boundaries (calculated from TileMapLayer)
- [ ] No empty space visible when character at edges

**Verify**: Move to edges of room — camera stops at boundaries, no black/empty space.

---

### T5: Add Y-Sort depth rendering [P]

**What**: Ensure Player renders behind/in front of wall objects based on Y position
**Where**: `scenes/world/TestRoom.tscn` (modify)
**Depends on**: T4
**Requirement**: MOV-04

**Done when**:
- [ ] Player is child of YSortRoot (same parent as WallsLayer)
- [ ] Walking "behind" a wall object hides the character
- [ ] Walking "in front" shows the character
- [ ] Sprite2D offset adjusted so sorting uses character feet position

**Verify**: Place a tall object in room, walk behind it — character occluded. Walk in front — character visible.

---

### T6: Add placeholder furniture objects for collision testing [P]

**What**: A few isometric objects (table, bed placeholder) placed in the room to test collision and y-sort
**Where**: `scenes/world/TestRoom.tscn` (modify)
**Depends on**: T4
**Requirement**: MOV-03, MOV-04

**Done when**:
- [ ] 2-3 furniture placeholder objects placed on tile grid
- [ ] Objects have collision shapes blocking player
- [ ] Objects participate in y-sort rendering
- [ ] Player can walk around objects

**Verify**: Walk into furniture — blocked. Walk around — works. Walk behind — occluded.

---

### T7: Integrate TestRoom into Main scene

**What**: Replace empty World node in Main.tscn with TestRoom instance
**Where**: `scenes/main/Main.tscn` (modify)
**Depends on**: T5, T6
**Requirement**: MOV-01

**Done when**:
- [ ] Main.tscn loads TestRoom as child of World node
- [ ] HUD renders on top of isometric world
- [ ] Clock ticks while player moves around
- [ ] Pause (Space) freezes movement

**Verify**: Run Main.tscn — see isometric room with clock HUD, move with arrows, pause with Space.

---

## Parallel Execution Map

```
Phase 1 (Sequential):
  T1 ──→ T2

Phase 2 (Sequential):
  T2 ──→ T3 ──→ T4

Phase 3 (Parallel):
  T4 complete, then:
    ├── T5 [P] Y-Sort
    └── T6 [P] Furniture

Phase 4 (Integration):
  T5, T6 ──→ T7
```

---

## Task Granularity Check

| Task | Scope | Status |
| --- | --- | --- |
| T1: TileSet resource | 1 resource | ✅ Granular |
| T2: TestRoom scene | 1 scene | ✅ Granular |
| T3: Player scene + movement | 1 scene + 1 script | ✅ Granular |
| T4: Camera2D | 1 node + config | ✅ Granular |
| T5: Y-Sort setup | 1 scene modify | ✅ Granular |
| T6: Furniture placeholders | 1 scene modify | ✅ Granular |
| T7: Main integration | 1 scene modify | ✅ Granular |

---

## Commit Plan

| Task | Commit |
| --- | --- |
| T1 | `feat(tiles): create isometric TileSet with floor and wall tiles` |
| T2 | `feat(world): create TestRoom with isometric tile layers` |
| T3 | `feat(player): add Player with isometric arrow key movement` |
| T4 | `feat(camera): add Camera2D with smoothing and edge clamping` |
| T5 | `feat(render): enable Y-Sort depth rendering` |
| T6 | `feat(world): add placeholder furniture with collision` |
| T7 | `feat(main): integrate TestRoom into Main scene` |
