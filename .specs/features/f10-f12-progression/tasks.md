# F10-F12 Tasks

**Status**: Draft

---

## Execution Plan

```
Phase 1:  T1 → T2 (Missions)
Phase 2:  T3 → T4 (SAT Quiz)
Phase 3:  T5 (College Progress)
Phase 4:  T6 (Integration)
```

---

### T1: Create MissionManager + mission data

**What**: System that generates 10 daily missions and tracks completion
**Where**: `scripts/systems/MissionManager.gd`
**Depends on**: None

**Done when**:
- [ ] Generates 10 missions per character per day
- [ ] Auto-detects mission completion from game events
- [ ] Emits mission_completed signal
- [ ] Awards +3 SAT per mission, +10 for all-complete
- [ ] Resets on new day

---

### T2: Create MissionPanel UI

**What**: Side panel showing missions with ⬜/✅ and icons
**Where**: `scenes/ui/MissionPanel.tscn` + `.gd`
**Depends on**: T1

**Done when**:
- [ ] Shows 10 missions with icon + description + status
- [ ] Updates in real-time on completion
- [ ] Shows "All complete! +10 SAT bonus" when done
- [ ] Scrollable if needed
- [ ] Visible in HUD left side

---

### T3: Create SAT question bank (JSON)

**What**: JSON file with 50+ curated SAT questions
**Where**: `resources/sat_questions.json`
**Depends on**: None

**Done when**:
- [ ] 50+ questions with: id, domain, difficulty, question, options[4], answer, source
- [ ] Mix of reading/writing and math
- [ ] Easy/medium/hard distribution
- [ ] Source noted as "CollegeBoard Question Bank"

---

### T4: Create SATQuiz UI

**What**: Quiz popup that appears on study actions
**Where**: `scenes/ui/SATQuiz.tscn` + `.gd`
**Depends on**: T3

**Done when**:
- [ ] Shows question text + 4 option buttons (A/B/C/D)
- [ ] Player clicks answer or presses 1/2/3/4
- [ ] Correct: green flash + "+5 SAT" + sound feedback
- [ ] Wrong: red flash + shows correct answer for 2 seconds
- [ ] Closes after answer, returns to game
- [ ] Triggered by ActionExecutor on study actions

---

### T5: Create college milestone system

**What**: Milestones at SAT score thresholds with notifications
**Where**: `scripts/systems/CollegeProgress.gd`
**Depends on**: None

**Done when**:
- [ ] Tracks milestones: 400 (started), 800 (progressing), 1200 (acceptance range), 1600 (perfect)
- [ ] Shows notification at each milestone
- [ ] End-game screen at 1600 for either character
- [ ] SAT bar in HUD already exists (NeedsBars), just need milestone events

---

### T6: Wire everything into Main

**What**: Connect missions, quiz, and milestones into game flow
**Where**: `scenes/main/Main.tscn` + `.gd` (modify)
**Depends on**: T2, T4, T5

**Done when**:
- [ ] MissionPanel in HUD
- [ ] SATQuiz triggered on study actions
- [ ] MissionManager connected to game events
- [ ] CollegeProgress listening to SAT changes
- [ ] Full loop: study → quiz → SAT gain → mission complete → milestone

---

## Commit Plan

| Task | Commit |
| --- | --- |
| T1 | `feat(missions): add MissionManager with daily generation` |
| T2 | `feat(ui): add MissionPanel with live tracking` |
| T3 | `feat(sat): create SAT question bank with 50+ questions` |
| T4 | `feat(ui): add SATQuiz popup with answer feedback` |
| T5 | `feat(progress): add college milestone system` |
| T6 | `feat(main): integrate missions, quiz, and milestones` |
