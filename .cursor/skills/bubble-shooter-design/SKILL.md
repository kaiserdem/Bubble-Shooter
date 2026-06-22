---
name: bubble-shooter-design
description: >-
  Дизайн-система Cosmic Pop для BubbleShooter: Theme, ArcadeButton, GlassCard,
  палітра бульбашок. Використовувати при створенні UI, меню, HUD, кнопок,
  стилізації SpriteKit, або коли користувач згадує дизайн, стиль, кольори, UI kit.
---

# BubbleShooter Design (Cosmic Pop)

## Швидкий старт

1. Прочитай `.cursor/specs/design/visual_style_guide.md`
2. Використовуй `Theme` — не invent colors
3. Перевикористовуй компоненти з `BubbleShooter/Design/Components/`

## Компоненти

```swift
// Фон меню
let bg = GradientBackgroundView()

// Картка
let card = GlassCardView()
card.contentView.addSubview(...)

// Кнопки
let play = ArcadeButton(title: "Play", style: .primary)
play.addAction(UIAction { ... }, for: .touchUpInside)

// Текст
let title = ArcadeLabel("Bubble Shooter", style: .title)
let hint = ArcadeLabel("...", style: .caption)

// Badge
let badge = BadgeView(text: "PvP", tint: Theme.Accent.gold)
```

## Кольори бульбашок

```swift
let color = Theme.Bubble.uiColor(at: colorIndex)  // UIKit
let skColor = Theme.Bubble.skColor(at: colorIndex) // SpriteKit
```

Порядок кольорів фіксований — index має збігатися з `BubbleColor` enum (майбутній крок).

## Стилі кнопок

| Style | Use case |
|-------|----------|
| `.primary` | Play, Continue, Submit |
| `.secondary` | Alt modes, tests |
| `.ghost` | Settings, Back, Launch Skillz |
| `.danger` | Abort match, Forfeit |

## SpriteKit labels

```swift
SKLabelNode(fontNamed: Theme.Typography.skTitle())
label.fontColor = Theme.SK.textPrimary
scene.backgroundColor = Theme.SK.backgroundDeep
```

## Checklist нового екрану

- [ ] Фон через `GradientBackgroundView` або `Theme.SK.backgroundDeep`
- [ ] Немає raw hex / `.systemBlue` / `.white`
- [ ] Кнопки — `ArcadeButton`
- [ ] Відступи — `Theme.Metrics.*`

## Повний гайд

[visual_style_guide.md](../../specs/design/visual_style_guide.md)
