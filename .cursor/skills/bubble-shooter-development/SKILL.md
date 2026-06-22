---
name: bubble-shooter-development
description: >-
  Покрокова розробка BubbleShooter для Skillz PvP (SpriteKit, детермінований
  геймплей). Використовувати при реалізації механіки, нових кроків ТЗ, hex-сітки,
  пострілу, match-3, score, Skillz інтеграції або коли користувач каже «крок N»,
  «ТЗ», «bubble shooter», «продовжи гру».
---

# BubbleShooter Development

## Перед початком

1. Прочитай `.cursor/specs/game/bubble_shooter_skillz.md`
2. Визнач поточний крок (зараз: **Крок 2**)
3. Реалізуй **лише один крок** за запитом
4. Переконайся, що проєкт збирається (`xcodebuild`)

## Workflow одного кроку

```
1. Прочитати ТЗ для цього кроку
2. Створити/оновити файли в Game/Model | Logic | Rendering
3. Підключити до GameScene мінімально (щоб перевірити в симуляторі)
4. Не використовувати системний random
5. Коротко повідомити користувача що зроблено і який наступний крок
```

## Кроки (чеклист)

Скопіюй і оновлюй статус після кожного кроку:

```
- [x] Крок 1: Фундамент (Skillz mock, DeterministicRandom, GameScene)
- [ ] Крок 2: BubbleColor, GridPosition, BubbleGrid
- [ ] Крок 3: LevelGenerator (детермінована стартова дошка)
- [ ] Крок 4: BubbleNode, GridRenderer
- [ ] Крок 5: AimController, ShotSimulator, FlyingBubble
- [ ] Крок 6: SnapResolver, колізії з сіткою
- [ ] Крок 7: MatchFinder, ConnectivityChecker, ScoreCalculator
- [ ] Крок 8: GameStateMachine, таймер, danger line, game over
- [ ] Крок 9: Детермінізм QA (однаковий seed = однаковий результат)
- [ ] Крок 10: Реальний Skillz SDK
- [ ] Крок 11: Мета (shop, achievements) — не MVP
```

## Крок 2 — деталі (наступний)

**Файли:**
- `Game/Model/BubbleColor.swift` — enum, 6 кольорів, `CaseIterable`
- `Game/Model/Bubble.swift` — struct з `color`
- `Game/Model/GridPosition.swift` — `row`, `col`; hex neighbors
- `Game/Model/BubbleGrid.swift` — storage, `place`, `remove`, `bubble(at:)`, `isOccupied`

**Hex neighbors (odd-r offset):**
```swift
// Для row % 2 == 0 та row % 2 == 1 — різні offset vectors
func neighbors(of position: GridPosition) -> [GridPosition]
```

**Тест детермінізму (ручний):** не потрібен на кроці 2; обов'язковий на кроці 9.

## Крок 3 — LevelGenerator

```swift
struct LevelGenerator {
    static func generate(
        random: DeterministicRandom,
        rows: Int,
        columns: Int,
        colorCount: Int
    ) -> BubbleGrid
}
```

- Кожна комірка: `colors[random.nextInt(upperBound: colorCount)]`
- Параметри з `SkillzMatchContext.gameParameters` з дефолтами

## Крок 5–6 — постріл (скорочено)

- Кут від вектора touch → cannon position
- Ray march з кроком; bounce від лівої/правої стіни
- Зіткнення з існуючою бульбашкою → SnapResolver

## Крок 7 — match + drop

```text
Після snap:
1. MatchFinder.groups(connected, minSize: 3, including: newPosition)
2. Видалити групи; нарахувати pop score
3. ConnectivityChecker.bubblesConnectedToCeiling(grid)
4. Усі інші — drop score
5. Порядок обходу: sorted by (row, col) — фіксований
```

## Заборони

| ❌ Не робити | ✅ Замість |
|-------------|-----------|
| `Int.random(in:)` для кольорів | `random.nextInt(upperBound:)` |
| Логіка в SKNode subclass | Окремі struct/class у Game/Logic |
| Skillz SDK на кроках 2–9 | MockSkillzService |
| Shop/achievements до кроку 11 | Зосередитись на MVP |

## GameScene інтеграція

```swift
// Після configure(matchContext:):
// 1. Створити BubbleGrid через LevelGenerator
// 2. GridRenderer показує дошку
// 3. GameStateMachine керує фазами (пізніші кроки)
```

## Додаткова документація

Повне ТЗ: [bubble_shooter_skillz.md](../../specs/game/bubble_shooter_skillz.md)
