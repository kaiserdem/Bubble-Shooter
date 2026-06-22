# AI Prompt — Game Screen Background v2 (Bright Cosmic Pop)

Фон для **ігрового екрану** — **той самий настрій, що й лобі** (`lobby background`): яскраве космічне небо, бірюзово-фіолетова туманність, зоряний блиск. Але **без чітких кульок** у зоні гри, щоб не плутались з геймплеєм.

**Референс стилю:** `Assets.xcassets/Backgrounds/lobby background` — luminous, vibrant, glossy cosmic pop.  
**Проблема v1:** занадто темний, сірий, «мертвий» ground. **v2:** світліший, насичений, живий.

**Цільовий розмір:** `1290 × 2796 px` (iPhone @3x). Формат: PNG.  
**Ім’я ассету:** `game background` → `Assets.xcassets/Backgrounds/game background.imageset/`

---

## MAIN PROMPT

```
Vertical mobile bubble shooter gameplay background, portrait 9:19.5 aspect ratio, full-bleed illustration, no UI, no text, no watermark, no logo.

MATCH THE VISUAL STYLE of a bright cosmic bubble-shooter lobby wallpaper: vivid luminous space scene, rich saturated blues and purples, glowing teal-cyan nebula clouds (#22D4FF, #00DDE0), violet nebula streaks (#7358FF, #B460F8), sparkling star particles with soft cross flares, magical arcade atmosphere, premium casual mobile game art, 2D painted digital illustration with soft depth — NOT dark gray, NOT muddy, NOT desaturated, NOT photorealistic NASA space photo.

The playfield ground must feel BRIGHT and ALIVE: luminous periwinkle-blue cosmic glow in the center and upper two-thirds (#3D5288, #468AFF, soft #5B7FD4 highlights), like twilight sky lit from within. Smooth vertical gradient — brighter and more colorful in the middle play area, gently deeper indigo only at the very bottom edge (#2E4268) for the cannon zone. No flat gray floor, no charcoal fog, no dull monochrome.

Composition for gameplay layers (no labels in image):
- Top 12%: clean bright cosmic sky for HUD overlay
- Middle 58%: radiant calm playfield — soft nebula haze, subtle star sparkles, LOW detail, high readability for colorful game bubbles on top
- Bottom 30%: slightly richer indigo-violet glow, still colorful not gray, for shooter area

Decorative elements ONLY at far edges: optional heavily blurred soft-color bokeh orbs (ruby, amber, lime, aqua, violet, rose) pushed to corners, extremely out of focus, low opacity — must NOT look like playable bubbles. Center must stay clear.

Style: same family as bright glossy bubble lobby art — joyful, vibrant, cosmic pop twilight, high resolution, seamless edges, no hex grid, no cannon, no sharp bubble cluster.
```

---

## NEGATIVE PROMPT

```
dark gray background, charcoal, muddy brown, desaturated, dull, flat single color, foggy ash, storm clouds, realistic dark space photo, black void, playable sharp glossy bubbles, bubble cluster in center, hex grid, grid lines, honeycomb, cannon, shooter, aim line, HUD, score, timer, buttons, text, logo, watermark, busy center, high contrast clutter, horror, gritty, landscape orientation, low resolution, jpeg artifacts, banding, neon acid oversaturation
```

---

## КОРОТКИЙ ВАРІАНТ

```
Portrait bubble shooter game background, bright cosmic pop like vibrant lobby wallpaper, luminous blue-purple-teal nebula, sparkling stars, radiant periwinkle playfield center NOT gray, soft indigo bottom, blurred colorful bokeh only at edges, no sharp bubbles no grid no UI, 2D game art, high res
```

---

## Порівняння з лобі

| | Lobby | Game v2 |
|---|-------|---------|
| Яскравість | Висока | Так само висока |
| Кульки | Чіткі по краях | Лише розмиті на краях або без них |
| Центр | Порожній під меню | Порожній під hex-сітку |
| Настрій | Святковий | Святковий, але спокійніший центр |

---

## Нотатки для інтеграції

- Після генерації: `game background.png` → `Backgrounds/game background.imageset/`
- Підключення: `MatchLayoutView` + прозорий `GameScene.backgroundColor` (окремий крок)
- `DangerLineNode` і HUD малюються в коді — не додавай на арт
