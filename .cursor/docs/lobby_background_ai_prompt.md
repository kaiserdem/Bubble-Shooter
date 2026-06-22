# AI Prompt — Lobby Background (Cosmic Pop Twilight)

Фон для **головного меню** (Play / How to Play / Settings). Портретний мобільний екран, декоративний — UI лягає поверх (скляна картка по центру).

**Цільовий розмір:** `1290 × 2796 px` (iPhone @3x) або `1170 × 2532 px`. Формат: PNG.

---

## MAIN PROMPT

```
Vertical mobile game lobby background, portrait 9:19.5 aspect ratio, full-bleed illustration, no UI, no text, no buttons, no logo, no watermark.

Art direction: "Cosmic Pop Twilight" — dreamy twilight sky between deep indigo night and soft evening glow. Smooth vertical gradient from lighter periwinkle-indigo at top (#3D5288) to deep navy-indigo at bottom (#1A2648). Subtle cosmic atmosphere: faint star dust, soft nebula wisps in blue-violet (#7358FF) and cyan (#00DDE0), very gentle bokeh orbs, not busy.

Decorative glossy bubble spheres floating at the edges and corners only — leave the central 60% of the image calm and relatively empty for menu overlay. Bubbles are candy-glass planets with radial highlights, colors from the game palette: ruby red (#FF3D62), golden amber (#FFAB2B), lime green (#72E763), electric aqua (#22D4FF), violet purple (#B460F8), hot rose pink (#FF5299). Bubbles vary in size, slightly blurred depth-of-field on distant ones, soft glow halos, playful arcade mood, premium mobile game polish.

Lighting: soft studio twilight, top-left key light, no harsh shadows. Style: 2D painted digital illustration with subtle depth, NOT photorealistic, NOT 3D render scene with floor. Clean, readable, elegant, inviting, bubble shooter game menu wallpaper, high resolution, seamless edges.
```

---

## NEGATIVE PROMPT

```
game HUD, score, timer, buttons, text, typography, logo, watermark, frame, border, split screen, landscape, hex grid, bubble cluster filling center, cluttered center, busy pattern, checkerboard, realistic photo sky, sun, moon, characters, hands, cannon, weapon, UI mockup, low resolution, jpeg artifacts, noise, banding, oversaturated neon acid colors, horror, gritty, dark black void, flat single color fill
```

---

## КОРОТКИЙ ВАРІАНТ

```
Portrait mobile lobby wallpaper, Cosmic Pop Twilight, indigo twilight gradient #3D5288 to #1A2648, soft nebula and star dust, glossy candy bubbles in ruby amber lime aqua violet rose at edges only, empty calm center for menu, 2D game art, no text no UI, high res
```

---

## Нотатки для інтеграції

- Центр екрану має залишатись **спокійним** — там `GlassCardView` з кнопками.
- Якщо генератор обрізає краї — можна використати `GradientBackgroundView` як fallback під картинку.
- Для parallax (опційно): окремий шар з бульбашками на передньому плані з blur.
