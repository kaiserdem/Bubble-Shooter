# Visual Style Guide — Cosmic Pop Twilight

## Концепція

**Twilight** — проміжний варіант між темним космосом і світлим небом: приглушений індиго-фон, яскраві але не «кислотні» акценти, світлий текст, скляні панелі.

## Палітра

### Фони
| Token | Hex | Використання |
|-------|-----|--------------|
| `Background.deep` | `#243558` | Game scene |
| `Background.mid` | `#2E4268` | Gradient mid |
| `Background.gradientTop` | `#3D5288` | Menu top (світліший) |
| `Background.gradientBottom` | `#1A2648` | Menu bottom (темніший) |
| `Background.elevated` | `#3A5080` | HUD blocks |

### Акценти
| Token | Hex |
|-------|-----|
| `Accent.primary` | `#468AFF` |
| `Accent.primaryGlow` | `#7358FF` |
| `Accent.secondary` | `#00DDE0` |
| `Accent.gold` | `#FFC44B` |
| `Accent.danger` | `#FF4C6B` |

### Текст
| Token | Hex |
|-------|-----|
| `Text.primary` | `#EAF0FF` |
| `Text.secondary` | `#A8B8D8` |
| `Text.muted` | `#7A8AAA` |
| `Text.onDark` | `#FFFFFF` (кнопки) |

### Бульбашки
| Index | Hex |
|-------|-----|
| 0 ruby | `#FF3D62` |
| 1 amber | `#FFAB2B` |
| 2 lime | `#72E763` |
| 3 aqua | `#22D4FF` |
| 4 violet | `#B460F8` |
| 5 rose | `#FF5299` |

## Порівняння варіантів

| | Dark v1 | **Twilight** | Bright v2 |
|---|---------|--------------|-----------|
| Фон гри | `#0B1026` | `#243558` | `#C8E8FF` |
| Текст | світлий | світлий | темний |
| Настрій | космос | вечірнє небо | полудень |

## Джерело коду

`BubbleShooter/Design/Theme.swift`
