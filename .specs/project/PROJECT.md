# Dois Mundos

**Vision:** A life simulation game that exposes social inequality through gameplay mechanics — two characters, same dream, radically different starting conditions.
**For:** Web players interested in narrative-driven simulation games with social commentary
**Solves:** Making systemic inequality tangible and experiential, not just theoretical

## Goals

- Deliver a playable web game where inequality is felt through mechanics (time, energy, resources), not just told
- Create emotional connection with both characters through daily routine simulation
- Integrate real SAT questions as core gameplay, making education central to the narrative
- Achieve visual quality matching modern lofi pixel art standards (Stardew Valley / Habbo Hotel tier)

## Tech Stack

**Core:**

- Engine: Godot 4.x (compiled for web via Emscripten)
- Language: GDScript
- Export: HTML5/WebGL

**Key dependencies:**

- Godot Isometric Plugin (tile-based movement)
- SAT Question Bank integration (CollegeBoard official)
- Pixel art asset pipeline (Aseprite-compatible)
- Web export template (Godot HTML5)

## Scope

**v1 includes:**

- Two playable characters (Rosa / Azul) with switchable control
- Two home environments (favela / mansion) + shared school
- Needs system (hunger, energy, fun) with quality multipliers
- Game clock with day cycle, commute simulation, and schedule constraints
- Object interaction system (grid-based, quality 1-5 stars)
- Daily missions (10/day) with SAT progress tracking
- SAT quiz integration on study/class interactions
- Inequality mechanics (compound penalties, commute time, resource quality)
- Character expressions (6 states) with floating icons
- Brighta NPC teacher in school scenes
- Isometric pixel art style (high-detail, chibi characters)

**Explicitly out of scope:**

- Multiplayer / online features
- Mobile native builds (web-only for v1)
- Full open-world exploration (focused interior environments)
- Voice acting / complex audio system
- Save/load to cloud (local only for v1)
- Character customization
- More than 3 locations (favela home, mansion, school)

## Constraints

- Technical: Godot web export has performance limitations — must optimize draw calls and tile rendering
- Art: Consistent isometric pixel art style across all assets — needs strict style guide
- Content: SAT questions must reference official CollegeBoard question bank
- CSS: All pixel art must use `image-rendering: pixelated` to prevent blur on resize
