# Track B — Game UI MVP (паралельна розробка)

> **Гілка / вікно:** UI + Design  
> **Не чіпати:** `Game/Logic/*`, `Game/Model/BubbleGrid.swift`, `SnapResolver`, `MatchFinder`, `ShotSimulator`, `LevelGenerator`  
> **Інша сесія робить:** Drop, Score, Timer, game loop у `Game/Logic`

## Мета

Зробити **production UI** для матчу (HUD, intro, results, danger line візуал) у стилі **Cosmic Pop Twilight**, з **mock-даними** і чітким контрактом для підключення геймплею пізніше.

## Обовʼязкове читання перед стартом

1. `.cursor/skills/bubble-shooter-design/SKILL.md`
2. `.cursor/specs/design/visual_style_guide.md`
3. `.cursor/rules/bubble-shooter-design.mdc`
4. `BubbleShooter/Design/Theme.swift`
5. `BubbleShooter/UI/SandboxLobbyView.swift` — референс стилю
6. `BubbleShooter/GameViewController.swift` — точка інтеграції

## Заборони

| ❌ | ✅ |
|----|-----|
| `Int.random`, `Date()` для геймплею | Mock-стан у UI |
| Змінювати логіку пострілу / snap / match | Тільки відображення |
| Хардкод hex кольорів | `Theme.*` |
| `.systemBlue`, raw `UILabel` стилі | `ArcadeLabel`, `ArcadeButton` |
| Великий рефактор `GameScene` | Мінімальний delegate/protocol |

## Файли — тільки ці (створити / редагувати)

### Нові

```
BubbleShooter/UI/MatchHUDState.swift          # display model (struct)
BubbleShooter/UI/GameHUDView.swift            # overlay HUD
BubbleShooter/UI/MatchResultsView.swift       # фінальний екран
BubbleShooter/UI/MatchIntroOverlayView.swift  # countdown GO
BubbleShooter/Game/Rendering/DangerLineNode.swift  # візуал лінії (SKNode)
BubbleShooter/Game/GameSceneHUDDelegate.swift # protocol (тонкий контракт)
```

### Можна редагувати обережно

```
BubbleShooter/GameViewController.swift   # додати HUD overlay, results, intro
BubbleShooter/UI/DesignPreviewViewController.swift  # секція preview HUD/Results
```

### Не чіпати

```
BubbleShooter/GameScene.swift            # лише 3–5 рядків: weak var hudDelegate (якщо потрібно)
BubbleShooter/Game/Logic/**
BubbleShooter/Game/Model/** (крім читання BubbleColor)
```

---

## Крок 1 — `MatchHUDState` (контракт)

```swift
struct MatchHUDState: Equatable {
    var score: Int
    var timeRemainingSeconds: Int
    var nextBubble: BubbleColor
    var currentBubble: BubbleColor
    var isDangerActive: Bool      // бульбашки близько до danger line
    var canSwap: Bool

    static let preview: MatchHUDState = .init(
        score: 12_450,
        timeRemainingSeconds: 87,
        nextBubble: .aqua,
        currentBubble: .ruby,
        isDangerActive: false,
        canSwap: true
    )
}
```

Пізніше Track A оновлюватиме цей стан з `GameScene` / `MatchScore` / `MatchTimer`.

---

## Крок 2 — `GameHUDView`

UIKit overlay поверх `SKView` у `GameViewController`.

**Layout (portrait):**

```
┌─────────────────────────────┐
│  SCORE          ⏱ 1:27      │  ← top safe area
│  12,450                     │
├─────────────────────────────┤
│                             │
│      (SpriteKit гра)        │
│                             │
│  ─ ─ ─ DANGER ─ ─ ─         │  ← DangerLineNode в SK або UI
│                             │
│         [swap]              │  ← optional, ghost style
└─────────────────────────────┘
```

**Елементи:**

- Score — `ArcadeLabel` `.title`, gold accent при великому рахунку (опційно)
- Timer — `ArcadeLabel`, при ≤10 сек `Theme.Accent.danger`
- Next bubble — маленький preview (`BubbleNode` у SK overlay **або** UIImage з Collection1)
- Swap — `ArcadeButton` style `.ghost`, `isEnabled` з `canSwap`
- Danger — червона лінія + легка пульсація коли `isDangerActive`

**API:**

```swift
final class GameHUDView: UIView {
    func update(with state: MatchHUDState)
    var onSwapTapped: (() -> Void)?
}
```

---

## Крок 3 — `MatchIntroOverlayView`

- Fullscreen поверх гри на 2–3 сек
- `GlassCardView` по центру: «GET READY» → «3» «2» «1» «GO!»
- Cosmic Pop: gradient bg напівпрозорий
- API: `func playCountdown(completion: @escaping () -> Void)`
- Показувати в `GameViewController` після `presentGameScene`, перед unlock input

---

## Крок 4 — `MatchResultsView`

Повноекранний overlay після матчу.

**Контент:**

```swift
struct MatchResultsState: Equatable {
    var finalScore: Int
    var popPoints: Int
    var dropPoints: Int
    var timeBonus: Int
    var isNewBest: Bool
    var didClearBoard: Bool
    var didLoseOnDanger: Bool
}
```

**UI:**

- `GlassCardView`
- Title: «MATCH COMPLETE» / «TIME'S UP» / «DANGER!»
- Score великий (count-up анімація 0.8 сек)
- Розбивка: Pop / Drop / Time bonus — `ArcadeLabel` `.caption`
- `ArcadeButton` «Continue» style `.primary`
- API: `var onContinue: (() -> Void)?`

**Mock flow у GameViewController (DEBUG):**

- Кнопка в sandbox або triple-tap на HUD → показати `MatchResultsView` з preview state

---

## Крок 5 — `DangerLineNode` (SpriteKit)

- Горизонтальна лінія в `GameScene` (не логіка — тільки візуал)
- Колір `Theme.Accent.danger`, alpha 0.6
- Пунктир або glow
- Позиція Y: ~72% від top grid area (константа `DangerLineNode.defaultNormalizedY`)
- Метод `setAlert(_ active: Bool)` — пульсація

Track A пізніше викличе `setAlert` з game logic.

---

## Крок 6 — `GameSceneHUDDelegate` (тонкий міст)

```swift
protocol GameSceneHUDDelegate: AnyObject {
    func gameScene(_ scene: GameScene, didUpdateHUD state: MatchHUDState)
    func gameSceneDidRequestMatchEnd(_ scene: GameScene, results: MatchResultsState)
}
```

У `GameScene` — лише `weak var hudDelegate: GameSceneHUDDelegate?`  
Поки Track A не готовий — **не викликати**; `GameViewController` оновлює HUD mock-таймером у DEBUG.

---

## Крок 7 — Інтеграція в `GameViewController`

1. Після `presentGameScene`:
   - показати `MatchIntroOverlayView` → по completion приховати
   - додати `GameHUDView` constraints до edges `SKView`
2. DEBUG: `Timer` кожну секунду зменшує mock `timeRemainingSeconds`
3. `MatchResultsView` — hidden за замовчуванням; `onContinue` → `MockSkillzService.simulateSkillzExit()` або hide
4. Не ламати існуючий `SandboxLobbyView` flow

---

## Крок 8 — Design Preview

Додати в `DesignPreviewViewController` секції:

- «Match HUD» — embedded `GameHUDView` з `.preview` state
- «Match Results» — embedded card preview
- Danger active / timer low варіанти

---

## Acceptance Criteria

- [ ] `xcodebuild -scheme BubbleShooter -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` — SUCCESS
- [ ] Start Match → intro countdown → гра з HUD поверх SK
- [ ] HUD оновлюється (mock timer) без крашів
- [ ] Results overlay показується (mock trigger у DEBUG)
- [ ] Жодного хардкоду кольорів поза Theme
- [ ] Не змінена логіка пострілу / match
- [ ] `MatchHUDState` + `MatchResultsState` готові для Track A

---

## Збірка

```bash
cd /Users/yaroslavgolinskiy/Documents/Developer/BubbleShooter
xcodebuild -scheme BubbleShooter \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Після завершення Track B

Повідом у чаті:

1. Список нових файлів
2. Скріншот / опис HUD + Results
3. Як тригерити mock results
4. Чи додано `GameSceneHUDDelegate` у GameScene

Track A підключить реальний score/timer/drop.
