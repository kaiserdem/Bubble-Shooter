# Cannon Design — Cosmic Pop Twilight (Diamond Muzzle)

## Концепція

Пушка стоїть **внизу по центру екрану**. Кульки вилітають **вгору** через **ромбовидний (diamond) порт** — фірмова форма Cosmic Pop.

### 9 варіантів (обрати / комбінувати)

| Варіант | Файл | Палітра | Характер |
|---------|------|---------|----------|
| **A — Twilight Glass** | `Cannon-Glass-1` | Cyan + indigo | Скляна пушка, мінімалізм |
| **B — Cosmic Gold** | `Cannon-Gold-1` | Gold + navy | Темна основа + золотий ромб |
| **C — Nebula Glow** | `Cannon-Nebula-1` | Violet + pink | Космічне світіння |
| **D — Aurora Frost** | `Cannon-Aurora-1` | Ice cyan + silver | Крижане скло, аврора |
| **E — Solar Flare** | `Cannon-Solar-1` | Gold + orange + red | Полум'я, сонячне ядро |
| **F — Crystal Nova** | `Cannon-Crystal-1` | Violet + magenta + cyan | Кристал, магічні іскри |
| **G — Emerald Prism** | `Cannon-Emerald-1` | Emerald `#2EE89A` + jade | Зелений кристал, золоті листки |
| **H — Ruby Eclipse** | `Cannon-Ruby-1` | Ruby `#E63946` + charcoal | Червоний кристал, срібний обідок |
| **I — Copper Tide** | `Cannon-Copper-1` | Copper `#C87941` + teal `#1ABC9C` | Мідь + океанічний бірюзовий |

**Превʼю:** `.cursor/docs/cannon_previews/Cannon-*.png`

### Прозорий порт (обовʼязково для всіх)

Ромб зверху має бути **порожнім всередині** — кулька малюється **під** рамкою ромба, щоб її колір було видно крізь порт.

```
     ╔═══╗
     ║ ○ ║  ← тут видно колір бульбашки (alpha = 0 у PNG)
     ╚═══╝
    │ base │
```

Після генерації AI: прибрати білий `#FFFFFF` у центрі ромба (Photoshop / Figma / `pngtools`) → **alpha transparent**.  
У грі: `anchorPoint (0.5, 0.0)`, кулька `zPosition` вище фону, але під верхньою рамкою пушки.

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

## MAIN PROMPT — Варіант D (Aurora Frost)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Unique Aurora Frost arcade cannon: upward diamond rhombus muzzle with HOLLOW SEE-THROUGH TRANSPARENT CENTER (empty hole in rhombus, only glowing icy frame visible, interior must stay empty white for alpha keying), frosted crystal glass frame with pale cyan (#00DDE0) aurora rim and silver chrome wings on sides, deep indigo cosmic glass base (#3A5080) with starfield texture and central blue gem, Cosmic Pop Twilight, glossy 2D game sprite, crisp edges, bubble color visible through diamond port.
```

---

## MAIN PROMPT — Варіант E (Solar Flare)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Unique Solar Flare bubble cannon: thick golden diamond rhombus frame pointing up with HOLLOW TRANSPARENT CENTER (empty launch port, no fill inside diamond), molten gold-orange rim (#FFC44B) with red solar flare wisps, dark navy cylindrical base (#243558) with glowing red core gem and orange energy vents on sides, premium arcade launcher, 2D mobile sprite, Cosmic Pop Twilight, empty see-through diamond window.
```

---

## MAIN PROMPT — Варіант F (Crystal Nova)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Unique Crystal Nova cosmic cannon: upward diamond rhombus with HOLLOW TRANSPARENT CENTER (clear hole through muzzle for bubble to show through), prismatic violet-pink nebula crystal frame (#7358FF) with magenta glow, ornate dark indigo pedestal base with gold trim and cyan star LEDs (#00DDE0), magical floating purple energy wisps, Cosmic Pop Twilight candy glass, 2D game asset, sharp silhouette, distinct ornate fantasy style.
```

---

## MAIN PROMPT — Варіант G (Emerald Prism)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Unique Emerald Prism cannon: upward diamond rhombus with HOLLOW TRANSPARENT CENTER (empty see-through launch port), glowing emerald jade glass frame (#2EE89A) with mint highlights, dark forest-teal cosmic base (#1A4D4A) with subtle gold leaf accents, lush magical arcade style, glossy 2D game sprite, unique green palette not blue purple or orange.
```

---

## MAIN PROMPT — Варіант H (Ruby Eclipse)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Unique Ruby Eclipse cannon: upward diamond rhombus muzzle with HOLLOW TRANSPARENT CENTER (clear hole for bubble color), deep ruby red crystal frame (#E63946) with dark rose inner glow, charcoal-plum pedestal base (#2A1F3D) with polished silver chrome trim, dramatic eclipse mood, glossy 2D mobile sprite, unique crimson red palette.
```

---

## MAIN PROMPT — Варіант I (Copper Tide)

```
Single mobile game bubble shooter cannon, isolated on pure solid white background (#FFFFFF), centered in lower half of frame, no text, no watermark, one object only.

Unique Copper Tide cannon: upward diamond rhombus with HOLLOW SEE-THROUGH CENTER (empty launch port), warm copper bronze frame (#C87941) with teal tide accents (#1ABC9C), deep ocean teal base (#1B3A4B) with coral copper energy veins, nautical-cosmic fusion style, glossy candy glass 2D asset, unique copper-teal palette.
```

---

## NEGATIVE PROMPT

```
realistic tank, military weapon, gun barrel, rifle, human hands, character, full scene, gradient background, gray background, multiple cannons, loaded bubble inside, solid filled diamond center, opaque muzzle interior, text, logo, watermark, blurry, low resolution, side view only, horizontal barrel, square muzzle, circular-only muzzle without diamond shape
```

---

## Інтеграція в грі

| Asset | CannonSkin | Назва |
|-------|------------|-------|
| `gun-1` | `.standard` | Twilight Glass |
| `gun-2` | `.gold` | Cosmic Gold (shop) |
| `gun-3` | `.nebula` | Nebula Glow |
| `gun-4` | `.solar` | Solar Flare |
| `gun-5` | `.emerald` | Emerald Prism |
| `gun-6` | `.ruby` | Ruby Eclipse |
| `gun-7` | `.aurora` | Aurora Frost |
| `gun-8` | `.crystal` | Crystal Nova |
| `gun-9` | `.copper` | Copper Tide |

- `CannonRenderer` + `CosmeticSettings.cannonSkin` → `SKSpriteNode(texture:)`
- Кулька в ромбі: `zPosition` нижче рамки пушки
- `anchorPoint` спрайта: `(0.5, 0.0)`
- Вибір: **Main Menu → Styles → Cannon**
