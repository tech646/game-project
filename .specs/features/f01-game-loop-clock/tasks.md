# F01 — Game Loop & Clock Tasks

**Design**: `.specs/features/f01-game-loop-clock/design.md`
**Status**: Draft

---

## Execution Plan

### Phase 1: Project Setup (Sequential)

```
T1 → T2
```

### Phase 2: Core Clock (Sequential)

```
T2 → T3 → T4
```

### Phase 3: Systems (Parallel after T4)

```
      ┌→ T5 [P] ─┐
T4 ───┼→ T6 [P] ──┼──→ T8
      └→ T7 [P] ─┘
```

### Phase 4: Integration (Sequential)

```
T8 → T9 → T10
```

---

## Task Breakdown

### T1: Criar projeto Godot e estrutura de diretórios

**What**: Inicializar projeto Godot 4 com a estrutura de pastas definida no design
**Where**: `res://project.godot` + diretórios
**Depends on**: None
**Requirement**: CLK-01 (foundation)

**Deliverable**:
```
res://
├── autoloads/
├── scenes/
│   ├── main/
│   ├── ui/
│   └── commute/
├── scripts/
│   ├── clock/
│   └── data/
├── resources/
└── assets/
    ├── characters/
    ├── environments/
    └── ui/
```

**Done when**:
- [ ] `project.godot` existe com configurações básicas (resolução, nome)
- [ ] Todas as pastas criadas
- [ ] Godot abre o projeto sem erros

**Verify**: Abrir projeto no Godot editor, verificar árvore de pastas.

---

### T2: Criar GameClock autoload

**What**: Implementar o singleton GameClock com accumulator pattern
**Where**: `autoloads/GameClock.gd`
**Depends on**: T1
**Requirement**: CLK-01

**Done when**:
- [ ] Script GDScript com accumulator em `_process(delta)`
- [ ] Emite `time_tick(hour, minute)` a cada minuto de jogo
- [ ] Emite `hour_changed(hour)` a cada hora
- [ ] Emite `day_changed(day)` quando dia muda
- [ ] `get_time_string()` retorna "HH:MM"
- [ ] `get_total_minutes()` retorna int
- [ ] `pause()` / `resume()` funcionam
- [ ] `set_speed(multiplier)` altera velocidade
- [ ] Registrado como Autoload no `project.godot`

**Verify**: Rodar jogo, observar prints de `time_tick` no console avançando a cada segundo.

---

### T3: Criar GameState autoload

**What**: Implementar FSM global com 4 estados
**Where**: `autoloads/GameState.gd`
**Depends on**: T2
**Requirement**: CLK-01, CLK-05

**Done when**:
- [ ] Enum `State { PLAYING, PAUSED, COMMUTING, IN_MENU }`
- [ ] `change_state(new_state)` emite `state_changed` signal
- [ ] PAUSED pausa o GameClock
- [ ] PLAYING resume o GameClock
- [ ] Registrado como Autoload no `project.godot`

**Verify**: Chamar `GameState.change_state(GameState.State.PAUSED)` — clock deve parar.

---

### T4: Criar EventBus autoload

**What**: Barramento de sinais global para comunicação entre sistemas
**Where**: `autoloads/EventBus.gd`
**Depends on**: T2
**Requirement**: CLK-03, CLK-04

**Done when**:
- [ ] Signals declarados: `commute_started`, `commute_finished`, `activity_locked`, `activity_unlocked`, `warning_shown`, `day_started`, `day_ended`
- [ ] Registrado como Autoload no `project.godot`

**Verify**: Arquivo existe, sem erros de parse no editor.

---

### T5: Criar ClockDisplay (UI) [P]

**What**: Componente de UI que exibe HH:MM com pulse animation
**Where**: `scenes/ui/ClockDisplay.tscn` + `scenes/ui/ClockDisplay.gd`
**Depends on**: T4
**Requirement**: CLK-01

**Done when**:
- [ ] Label exibe "HH:MM" atualizado a cada `time_tick`
- [ ] Label "Dia N" atualizado a cada `day_changed`
- [ ] AnimationPlayer com animação `pulse_red` (label fica vermelho pulsante)
- [ ] Pulse ativa quando deadline se aproxima (via signal)
- [ ] Fonte pixel art legível

**Verify**: Rodar cena, clock avança visualmente de 06:00 em diante com texto atualizado.

---

### T6: Criar ScheduleManager [P]

**What**: Sistema que gerencia janelas de atividade e deadlines de commute
**Where**: `scripts/clock/ScheduleManager.gd`
**Depends on**: T4
**Requirement**: CLK-03, CLK-04

**Done when**:
- [ ] Dictionary com 4 janelas: english_class (08-11), cafeteria (11:30-14), sat_extra (15-17), homework (sempre, penalidade após 22)
- [ ] Dictionary com deadlines: gritty (07:15, 45min), smartle (07:45, 15min)
- [ ] `is_activity_available(activity) -> bool` funciona
- [ ] `get_activity_window(activity) -> Dictionary` retorna {start, end}
- [ ] Escuta `time_tick` e emite warnings 15 min antes de deadlines
- [ ] Emite `activity_locked` / `activity_unlocked` nos horários corretos

**Verify**: Observar no console: às 07:00 emite warning para gritty, às 08:00 english_class unlocked, às 11:00 english_class locked.

---

### T7: Criar WarningPopup (UI) [P]

**What**: Popup animado para avisos de deadline e penalidades
**Where**: `scenes/ui/WarningPopup.tscn` + `scenes/ui/WarningPopup.gd`
**Depends on**: T4
**Requirement**: CLK-04

**Done when**:
- [ ] Control node com Label centralizado
- [ ] AnimationPlayer: fade_in → stay 2s → fade_out
- [ ] Escuta `EventBus.warning_shown` e exibe mensagem
- [ ] Suporta texto "⚠️ Hora de ir à escola!" e "-X SAT"
- [ ] Cor vermelha para penalidades, amarela para avisos

**Verify**: Emitir `EventBus.warning_shown.emit("⚠️ Teste!")` — popup aparece e desaparece.

---

### T8: Criar CommuteManager

**What**: Gerencia lógica de commute — tempo de viagem, avanço de clock, penalidade por atraso
**Where**: `scripts/clock/CommuteManager.gd`
**Depends on**: T5, T6, T7
**Requirement**: CLK-04

**Done when**:
- [ ] `start_commute(character)` muda GameState para COMMUTING
- [ ] Avança clock pelo tempo de viagem (45min gritty, 15min smartle)
- [ ] Calcula `late_minutes` se chegada > 08:00
- [ ] Emite `EventBus.commute_finished(character, late_minutes)`
- [ ] Penalidade: cada 5 min atraso = -2 SAT
- [ ] Drena energia durante commute (mais para gritty)

**Verify**: `start_commute("gritty")` às 07:30 → chega 08:15 → late_minutes = 15 → penalidade -6 SAT.

---

### T9: Criar Main scene com HUD integrado

**What**: Scene principal que monta HUD (ClockDisplay + WarningPopup) como CanvasLayer
**Where**: `scenes/main/Main.tscn` + `scenes/main/Main.gd`
**Depends on**: T8
**Requirement**: CLK-01, CLK-02

**Node tree**:
```
Main (Node2D)
├── HUD (CanvasLayer)
│   ├── TopBar (HBoxContainer)
│   │   ├── ClockDisplay
│   │   └── DayLabel
│   └── WarningPopup
└── World (Node2D)  ← placeholder para F02
```

**Done when**:
- [ ] Main scene carrega e exibe HUD
- [ ] Clock avança e é visível no topo
- [ ] Dia avança de 06:00 até 00:00 e transiciona
- [ ] WarningPopup funcional

**Verify**: Rodar Main.tscn — clock visível, dia avançando, warnings aparecendo nos horários corretos.

---

### T10: Implementar Day Cycle (transição de dia)

**What**: Lógica de fim de dia (23:00 warning, 00:00 force-end) e início de novo dia
**Where**: `scenes/main/Main.gd` (extend)
**Depends on**: T9
**Requirement**: CLK-02

**Done when**:
- [ ] Às 23:00 mostra warning "Hora de dormir!"
- [ ] Às 00:00 force-end: penalidade de energia, transição para novo dia
- [ ] Novo dia: incrementa contador, mostra "Dia N" por 3 segundos
- [ ] Stats overnight diferentes para gritty vs smartle (gritty recupera menos)
- [ ] Emite `EventBus.day_started` e `EventBus.day_ended`

**Verify**: Deixar clock rodar até 00:00 — dia transiciona, "Dia 2" aparece, stats resetam com valores diferenciados.

---

## Parallel Execution Map

```
Phase 1 (Sequential):
  T1 ──→ T2

Phase 2 (Sequential):
  T2 ──→ T3 ──→ T4

Phase 3 (Parallel):
  T4 complete, then:
    ├── T5 [P] ClockDisplay UI
    ├── T6 [P] ScheduleManager
    └── T7 [P] WarningPopup UI

Phase 4 (Sequential):
  T5, T6, T7 complete, then:
    T8 ──→ T9 ──→ T10
```

---

## Task Granularity Check

| Task | Scope | Status |
| --- | --- | --- |
| T1: Projeto Godot + dirs | 1 setup | ✅ Granular |
| T2: GameClock autoload | 1 script | ✅ Granular |
| T3: GameState autoload | 1 script | ✅ Granular |
| T4: EventBus autoload | 1 script | ✅ Granular |
| T5: ClockDisplay UI | 1 scene + 1 script | ✅ Granular |
| T6: ScheduleManager | 1 script | ✅ Granular |
| T7: WarningPopup UI | 1 scene + 1 script | ✅ Granular |
| T8: CommuteManager | 1 script | ✅ Granular |
| T9: Main scene + HUD | 1 scene + 1 script | ✅ Granular |
| T10: Day Cycle logic | 1 script extend | ✅ Granular |

---

## Commit Plan

| Task | Commit |
| --- | --- |
| T1 | `chore(project): initialize Godot 4 project structure` |
| T2 | `feat(clock): add GameClock autoload with accumulator pattern` |
| T3 | `feat(state): add GameState FSM autoload` |
| T4 | `feat(events): add EventBus signal autoload` |
| T5 | `feat(ui): add ClockDisplay with pulse animation` |
| T6 | `feat(schedule): add ScheduleManager with activity windows` |
| T7 | `feat(ui): add WarningPopup with fade animation` |
| T8 | `feat(commute): add CommuteManager with lateness penalties` |
| T9 | `feat(main): create Main scene with integrated HUD` |
| T10 | `feat(cycle): add day transition and overnight stats` |
