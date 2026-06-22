# ТЗ: BubbleShooter — Skillz PvP

## Опис

Асинхронна змагальна гра Bubble Shooter для платформи **Skillz** (iOS 16+, SpriteKit + UIKit + GameplayKit).

Гравці змагаються за **найвищий рахунок** у матчі з однаковими стартовими умовами. Геймплей **100% детермінований**: усі «випадкові» події генеруються лише через `DeterministicRandom` з `matchSeed`.

## Ключові обмеження

- [ ] Заборонено: `Int.random`, `arc4random`, `UUID()`, `Date()` для геймплею
- [ ] Дозволено: `DeterministicRandom(matchSeed:)` / `GKLinearCongruentialRandomSource`
- [ ] Один матч = один seed = однакова послідовність для всіх гравців турніру
- [ ] Логіка гри — чистий Swift (без SpriteKit у моделях); візуалізація — SpriteKit
- [ ] Skillz SDK підключається після робочого геймплей-циклу (працює мок `MockSkillzService`)

## Архітектура

```
BubbleShooter/
├── Core/           # RNG, хешування seed
├── Skillz/         # SDK абстракція, мок, bridge
├── Game/
│   ├── Model/      # Bubble, Grid, MatchState, Score (без SKNode)
│   ├── Logic/      # Shoot, Match, Pop, Gravity, LevelGen
│   └── Rendering/  # SpriteKit nodes, анімації
├── GameScene.swift       # Координатор сцени
└── GameViewController.swift  # SkillzGameDelegate, презентація
```

## Механіка гри

### 1. Сітка (Hex / Staggered Grid)

- Ряди зміщені (odd-row offset): парні/непарні ряди мають різну кількість комірок або зміщення по X
- Кожна комірка: `GridPosition(row, col)` або axial coords `(q, r)`
- Радіус бульбашки `R`, відстань між центрами сусідів = `2R`
- Сусідство: 6 напрямків (hex)
- Порожня комірка = `nil`; зайнята = `Bubble(color:)`

### 2. Кольори бульбашок

- Базово **6 кольорів** (enum `BubbleColor`)
- Кольори стартової дошки та черги пострілу — лише з `DeterministicRandom`
- Кількість кольорів може зменшуватись у `gameParameters` Skillz (напр. `"ColorCount": "4"`)

### 3. Стартова дошка

- Генерація з seed: заповнити верхні N рядів бульбашками випадкових кольорів
- Без «мертвих» стартових матчів 3+ (опційно: перевірка після генерації)
- Параметри з `SkillzMatchContext.gameParameters`:
  - `TimeLimit` — секунди (int)
  - `ColorCount` — кількість кольорів
  - `InitialRows` — початкові ряди

### 4. Постріл

- Гравець цілиться дотиком/перетягуванням від пушки (нижній центр екрана)
- Кут обмежений (напр. 15°–165° від горизонталі)
- Постріл: рух по прямій з відбиттям від **бокових** стін
- Швидкість постійна; без гравітації для летючої бульбашки
- При зіткненні зі сіткою або верхньою межею — **прилипання** до найближчої вільної hex-комірки

### 5. Прилипання (Snap)

- Знайти комірку зіткнення + сусідню вільну комірку в напрямку руху
- Якщо немає вільної — snap до найближчої валідної сусідньої
- Після прилипання — перевірка матчів

### 6. Знищення груп (Match)

- BFS/DFS від нової бульбашки: група одного кольору розміром **≥ 3**
- Знищені бульбашки дають очки: базово `10 × кількість`
- Анімація pop (scale/fade) — лише візуал; стан моделі оновлюється одразу для детермінізму

### 7. Висячі кластери (Drop)

- Після pop: знайти всі бульбашки, з'єднані з **стелою** (верхній ряд / anchor row)
- Бульбашки без зв'язку з стелою — падають і дають бонус: `20 × кількість`
- Порядок обробки фіксований (напр. зверху-вниз, зліва-направо) для детермінізму

### 8. Черга пострілу

- `currentBubble` + `nextBubble`
- Після пострілу: current ← next; next ← random color (з кольорів на полі або з повного набору)
- Кнопка swap (опційно): обмін current ↔ next без RNG

### 9. Умови завершення

| Умова | Результат |
|-------|-----------|
| Таймер = 0 | Кінець матчу, фіксація score |
| Бульбашки перетнули **danger line** | Програш / штраф до score |
| Поле очищене | Бонус до score |
| Немає валідного пострілу (рідко) | Кінець або штраф |

### 10. Рахунок (Score)

- Pop: `+10` за бульбашку в групі
- Drop: `+20` за упавшу
- Time bonus: `+floor(remainingSeconds × multiplier)` — multiplier з gameParameters
- Фінальний score передається в Skillz: `displayTournamentResultsWithScore`

### 11. Skillz інтеграція (після геймплею)

- `tournamentWillBegin` → `GameScene.configure(matchContext:)`
- Під час гри: `updatePlayersCurrentScore` при зміні score
- Кінець: `displayTournamentResultsWithScore` / mock equivalent
- Sandbox: `MockSkillzService.simulateTournamentStart()`

## Покроковий план реалізації

### Крок 1 — Фундамент ✅ (зроблено)

- [x] Очищення шаблону SpriteKit
- [x] `SkillzGameDelegate` + `MockSkillzService`
- [x] `DeterministicRandom` + `MatchSeedHasher`
- [x] Програмна `GameScene`

### Крок 2 — Модель сітки

- [ ] `BubbleColor`, `Bubble`, `GridPosition`
- [ ] `BubbleGrid`: hex сусіди, place/remove, bounds
- [ ] Unit-тести: сусідство, place, occupied

### Крок 3 — Генерація рівня

- [ ] `LevelGenerator.generate(seed:rows:colorCount:)` — лише через RNG
- [ ] Тест: однаковий seed → однакова дошка

### Крок 4 — Рендеринг

- [ ] `BubbleNode` (SKShapeNode або SKSpriteNode)
- [ ] `GridRenderer`: позиціонування hex на екрані
- [ ] Відображення стартової дошки в `GameScene`

### Крок 5 — Прицілювання та постріл

- [ ] `AimController`: кут від touch
- [ ] `ShotSimulator`: raycast + wall bounce
- [ ] `FlyingBubble` node до зіткнення

### Крок 6 — Прилипання та колізії

- [ ] `SnapResolver`: найближча вільна hex-комірка
- [ ] Оновлення `BubbleGrid` після snap

### Крок 7 — Match + Drop

- [ ] `MatchFinder`: групи ≥ 3
- [ ] `ConnectivityChecker`: зв'язок зі стелою
- [ ] `ScoreCalculator`: детермінований підрахунок

### Крок 8 — Ігровий цикл

- [ ] `GameStateMachine`: aim → shoot → resolve → next bubble
- [ ] Таймер матчу з `gameParameters["TimeLimit"]`
- [ ] Danger line
- [ ] Game over UI + фінальний score

### Крок 9 — Детермінізм QA

- [ ] Два запуски з одним seed — ідентичний score і дошка
- [ ] Лог replay: seed + список дій (для дебагу)

### Крок 10 — Skillz SDK

- [ ] `USE_SKILLZ_SDK`, bridging header, Game ID
- [ ] `SkillzSDKBridge` — реальні callback
- [ ] Sandbox tournament test

### Крок 11 — Мета (майбутнє, не MVP)

- [ ] Shop, achievements, progression
- [ ] Звук, частинки, полірування UI

## Критерії приймання MVP

1. Матч стартує з mock або Skillz з `matchSeed`
2. Гравець може цілитись і стріляти
3. Бульбашки прилипають, групи 3+ зникають, висячі падають
4. Таймер і score працюють
5. Однаковий seed + однакові дії = однаковий фінальний score
6. Після матчу score відображається / відправляється в Skillz

## Нотатки для агента Cursor

- Реалізувати **один крок за раз**; не переходити до наступного без завершення поточного
- Перед RNG у геймплеї — перевірити, що використовується `gameState.random`, не системний random
- Нові файли класти в `BubbleShooter/Game/Model|Logic|Rendering`
- Зберігати сумісність з iOS 16.6+ (deployment target проєкту)
