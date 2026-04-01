# F04-F06 — World Building Tasks

**Design**: `.specs/features/f04-f06-world-building/design.md`
**Status**: Draft

---

## Execution Plan

```
Phase 1:  T1 → T2
Phase 2:  T2 → T3 [P], T4 [P], T5 [P]
Phase 3:  T3,T4,T5 → T6 → T7
```

---

## Task Breakdown

### T1: Create GameObject component

**What**: StaticBody2D-based interactive object with quality, name, stars label
**Where**: `scripts/components/GameObject.gd`
**Depends on**: None
**Requirement**: WLD-05

**Done when**:
- [ ] StaticBody2D with CollisionShape2D
- [ ] Quality property (1-5) with multiplier calculation
- [ ] QualityLabel showing stars (★☆ format)
- [ ] Colored placeholder Sprite2D (different color per object type)
- [ ] `get_restore_amount() -> float` applies quality multiplier
- [ ] `object_name`, `action_name`, `need_affected`, `base_restore`, `time_cost` properties

---

### T2: Update TileSetFactory for per-location palettes

**What**: Add location-specific color palettes to TileSetFactory
**Where**: `scripts/tools/TileSetFactory.gd` (modify)
**Depends on**: T1
**Requirement**: WLD-01, WLD-02, WLD-03

**Done when**:
- [ ] `create_tileset_for(location: String)` method
- [ ] Favela: brown floor, red-brick walls
- [ ] Mansion: white floor, pink walls
- [ ] School: wood floor, beige walls
- [ ] Old `create_isometric_tileset()` still works (backwards compat)

---

### T3: Create FavelaHome scene [P]

**What**: 8x8 isometric room with 5 low-quality objects
**Where**: `scenes/locations/FavelaHome.tscn` + `.gd`
**Depends on**: T2
**Requirement**: WLD-01

**Done when**:
- [ ] 8x8 room with brown/brick tiles
- [ ] 5 GameObjects: bed(1), stove(2), tv(1), desk(1), fridge(1)
- [ ] Quality stars visible on each object
- [ ] YSortRoot for depth
- [ ] Spawn point defined for character entry

---

### T4: Create MansionHome scene [P]

**What**: 14x14 isometric room with 5 high-quality objects
**Where**: `scenes/locations/MansionHome.tscn` + `.gd`
**Depends on**: T2
**Requirement**: WLD-02

**Done when**:
- [ ] 14x14 room with white/pink tiles
- [ ] 5 GameObjects: bed(5), kitchen(4), gamer(5), tutor(5), gym(4)
- [ ] Quality stars visible
- [ ] YSortRoot for depth
- [ ] Spawn point defined

---

### T5: Create School scene [P]

**What**: 12x10 isometric room with 4 medium-quality objects + Brighta placeholder
**Where**: `scenes/locations/School.tscn` + `.gd`
**Depends on**: T2
**Requirement**: WLD-03

**Done when**:
- [ ] 12x10 room with wood/beige tiles
- [ ] 4 GameObjects: desk(3), cafeteria(2), library(3), teacher_desk(3)
- [ ] Brighta NPC placeholder (static sprite)
- [ ] YSortRoot for depth
- [ ] Spawn point defined

---

### T6: Create SceneManager autoload with fade transitions

**What**: Autoload that manages location switching with fade overlay
**Where**: `autoloads/SceneManager.gd`
**Depends on**: T3, T4, T5
**Requirement**: WLD-04

**Done when**:
- [ ] `change_location(location, character)` swaps World child in Main
- [ ] Fade to black → swap → fade in animation
- [ ] Tracks current location per character
- [ ] `get_current_location(character) -> String`
- [ ] Character placed at spawn point after transition
- [ ] Emits `location_changed` signal

---

### T7: Integrate locations into Main + remove TestRoom

**What**: Replace TestRoom with location system, characters start at their homes
**Where**: `scenes/main/Main.tscn` + `scenes/main/Main.gd` (modify)
**Depends on**: T6
**Requirement**: WLD-01, WLD-02, WLD-04

**Done when**:
- [ ] Gritty starts at FavelaHome
- [ ] Smartle starts at MansionHome
- [ ] Tab switch transitions to other character's location
- [ ] TestRoom removed from Main
- [ ] HUD still works on top
- [ ] Commute triggers transition to School

---

## Commit Plan

| Task | Commit |
| --- | --- |
| T1 | `feat(objects): create GameObject with quality system` |
| T2 | `feat(tiles): add per-location tile palettes` |
| T3 | `feat(favela): create FavelaHome with low-quality objects` |
| T4 | `feat(mansion): create MansionHome with high-quality objects` |
| T5 | `feat(school): create School with medium-quality objects` |
| T6 | `feat(scenes): add SceneManager with fade transitions` |
| T7 | `feat(main): integrate locations, characters start at homes` |
