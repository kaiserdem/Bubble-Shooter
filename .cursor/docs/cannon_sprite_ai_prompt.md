# Cannon Design — Cosmic Pop Twilight (Diamond Muzzle)

## Концепція

Пушка стоїть **внизу по центру екрану**. Кульки вилітають **вгору** через **ромбовидний (diamond) порт** — фірмова форма Cosmic Pop.

### 3 варіанти (обрати один пізніше)

| Варіант | Файл | Характер |
|---------|------|----------|
| **A — Twilight Glass** | `Cannon-Glass-1` | Скляна пушка, cyan обводка, мінімалізм |
| **B — Cosmic Gold** | `Cannon-Gold-1` | Темна основа + золотий ромб-обідок |
| **C — Nebula Glow** | `Cannon-Nebula-1` | Фіолетове світіння, космічний настрій |

### Анатомія (спільна для всіх)

```
        ◇  ← ромб-порт (кульки вилітають вгору)
       ╱ ╲
      ╱   ╲
     │ base │  ← корпус / підставка
     └─────┘
```

- **Ромб** — верхня частина, орієнтована вершиною вгору (◇)
- **Корпус** — скляна / металева підставка, ширша за ромб
- **Колір фону PNG:** `#FFFFFF` (як у кульок)
- **Розмір:** 512×512, пушка по центру нижньої половини кадру (місце для кульки над ромбом)

### Палітра (з Theme.swift)

- Фон гри: `#243558`
- Elevated: `#3A5080`
- Cyan: `#00DDE0`
- Gold: `#FFC44B`
- Violet glow: `#7358FF`
- Primary blue: `#468AFF`

---

## MAIN PROMPT — Варіант A (Twilight Glass)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

A sleek arcade cannon for Cosmic Pop Twilight style: the launch muzzle is a clear diamond rhombus shape pointing upward (◇), made of glossy translucent glass with electric cyan (#00DDE0) rim light and soft white inner glow, supported by a compact rounded indigo glass base (#3A5080), candy arcade semi-translucent look, subtle specular highlight top-left, cosmic twilight mood, 2D game asset flat camera, crisp edges, bubble shooter bottom turret, high resolution, no bubble loaded, empty diamond port ready to shoot upward.
```

---

## MAIN PROMPT — Варіант B (Cosmic Gold)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Cosmic Pop Twilight arcade cannon: diamond rhombus muzzle pointing up, thick golden rim (#FFC44B) around the diamond port, deep twilight blue body (#2E4268) with glass panels, small cyan accent LEDs (#00DDE0), premium arcade launcher look, glossy highlights, 2D mobile game sprite, crisp silhouette, empty launch port, bubbles exit upward through diamond shape, high resolution.
```

---

## MAIN PROMPT — Варіант C (Nebula Glow)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Fantasy cosmic bubble cannon for mobile game: upward-pointing diamond rhombus launch opening with violet nebula glow (#7358FF) and soft pink-magenta edge light, dark indigo metallic-glass base (#243558), floating energy feel, subtle cyan sparks (#00DDE0), Cosmic Pop Twilight style, glossy candy glass, 2D game asset, sharp edges, empty diamond muzzle, high resolution, no loaded bubble.
```

---

## NEGATIVE PROMPT

```
realistic tank, military weapon, gun barrel, rifle, human hands, character, full scene, gradient background, gray background, multiple cannons, loaded bubble inside, text, logo, watermark, blurry, low resolution, side view only, horizontal barrel, square muzzle, circular-only muzzle without diamond shape
```

---

## Інтеграція в грі (пізніше)

- Замінити `CannonRenderer` `SKShapeNode` base на `SKSpriteNode(texture:)`
- Кулька над ромбом: `y + bubbleDiameter * 0.55` (як зараз)
- `anchorPoint` спрайта: `(0.5, 0.0)` — низ по центру екрану
