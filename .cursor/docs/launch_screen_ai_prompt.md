# AI Prompt — Launch / Loading Screen (Cosmic Pop Twilight)

Фон для **екрану завантаження** на старті додатку (замість білого екрану). Портретний мобільний екран, яскравий і «вау» — різнокольорові бульбашки, космічне небо, енергія arcade.

**Цільовий розмір:** `1290 × 2796 px` (iPhone @3x) або мінімум `1170 × 2532 px`. Формат: **PNG**, без прозорості (повний фон).

**Ім’я ассету (після імпорту):** `launch background` → `Assets.xcassets/Backgrounds/launch background.imageset/`

---

## Концепція

Екран «перед грою»: гравець ще не в меню — лише атмосфера Bubble Shooter. Багато **великих і середніх** скляних кульок різних кольорів, ніби вони летять у космосі або збираються в кластер. Центр може бути трохи спокійніший (для майбутнього логотипу), але **не порожній білий** — увесь екран насичений кольором.

Палітра кульок (як у грі):
| Колір | Hex |
|-------|-----|
| Ruby | `#FF3D62` |
| Amber | `#FFAB2B` |
| Lime | `#72E763` |
| Aqua | `#22D4FF` |
| Violet | `#B460F8` |
| Rose | `#FF5299` |

Фон неба: twilight indigo `#3D5288` → deep navy `#1A2648`, м’які туманності cyan `#00DDE0` і violet `#7358FF`, зоряний пил.

---

## MAIN PROMPT (рекомендований)

```
Vertical mobile game launch screen wallpaper, portrait 9:19.5 aspect ratio, full-bleed edge-to-edge illustration, no UI chrome, no buttons, no watermark.

Art direction: "Cosmic Pop Twilight" bubble shooter — EXPLOSIVE joyful energy at app startup. Dozens of glossy candy-glass bubble spheres floating in luminous cosmic space, all six game colors vividly represented: ruby red (#FF3D62), golden amber (#FFAB2B), lime green (#72E763), electric aqua (#22D4FF), violet purple (#B460F8), hot rose pink (#FF5299).

Composition: dynamic diagonal flow of bubbles from bottom-left toward top-right, like bubbles launching upward into a starry twilight sky. Mix of bubble sizes — 3–4 hero bubbles large in foreground with crisp specular highlights, many medium bubbles, tiny sparkles and bokeh orbs in depth. Some bubbles slightly overlap with soft glow halos. Background: rich vertical gradient periwinkle-indigo (#3D5288) at top to deep navy (#1A2648) at bottom, soft nebula clouds in cyan and violet, subtle star dust and cross-flare sparkles, magical arcade mood.

Bubbles look like playable game assets: perfect circles, planet-like glass shells, radial highlights top-left, iridescent inner shimmer, semi-translucent gelatin candy look — NOT flat emoji circles, NOT matte plastic balls.

Center area: still colorful and filled with atmosphere (nebula + distant bubbles), slightly less cluttered than edges so a game logo COULD be placed later — but NO logo, NO text in this image.

Style: premium 2D painted mobile game splash art, vibrant saturated colors, high contrast, inviting, playful, high resolution, seamless edges. NOT photorealistic, NOT dark gray void, NOT white background, NOT single color fill, NOT horror, NOT gritty.
```

---

## NEGATIVE PROMPT

```
white background, blank screen, flat solid color, black void, gray fog, muddy desaturated, dark charcoal only, text, typography, logo, watermark, app name, loading bar, progress bar, percentage, buttons, HUD, score, timer, cannon, gun, weapon, aim line, hex grid, honeycomb, bubble shooter UI mockup, realistic photo, 3D render with floor, landscape orientation, split screen, characters, hands, faces, low resolution, jpeg artifacts, banding, oversaturated neon acid, horror, scary, cluttered unreadable noise in exact center only
```

---

## КОРОТКИЙ ВАРІАНТ (Midjourney / швидка генерація)

```
Portrait mobile game splash, Cosmic Pop Twilight, explosive cluster of glossy candy bubbles ruby amber lime aqua violet rose flying upward through luminous indigo cosmic sky, nebula cyan violet, star sparkles, dynamic arcade energy, full bleed colorful, no text no logo, 2D premium bubble shooter art, high res
```

---

## ВАРІАНТ B — «Burst from center» (альтернатива)

Якщо перший варіант занадто «рівномірний» — спробуй радіальний вибух кульок від центру:

```
Portrait mobile launch splash, cosmic twilight indigo sky, giant colorful glossy bubble burst radiating from center outward, six candy-glass colors ruby amber lime aqua violet rose, motion trails and sparkle particles, joyful bubble shooter arcade, full bleed, no text, vibrant 2D game illustration, high resolution
```

---

## Після генерації

1. Експорт **PNG** у повному портретному розмірі.
2. Імпорт у Xcode: `Assets.xcassets/Backgrounds/launch background.imageset/`
3. Підключити як:
   - **Launch Screen** (статичний перший кадр), або
   - **Фон у `GameViewController`** / splash `UIView` поки ініціалізується Skillz і меню.

### Launch Screen (Info.plist / Storyboard)

Зараз у `Info.plist` стоїть чорний колір (`UIColorName: Black`). Після додавання ассету можна замінити на image-based launch screen у storyboard або `UIImage` у коді splash-в’ю.

### Поради

- Уникай **чистого білого** по краях — iOS на секунду показує launch screen; темний або кольоровий край безпечніший.
- Якщо AI дає квадрат — crop до **9:19.5** з центром на кластері бульбашок.
- Для @2x/@3x: поклади один великий PNG у `imageset` з `scale: 1x` або згенеруй 1290×2796 як universal.

---

## Референси стилю в проєкті

- Лобі: `Assets.xcassets/Backgrounds/lobby background`
- Гра: `Assets.xcassets/Backgrounds/game background`
- Кульки: `Assets.xcassets/Collection1/*-1`

Стиль launch screen має бути **яскравішим і з більшою кількістю чітких кульок**, ніж game background (там центр навмисно спокійний).
