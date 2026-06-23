# AI Prompt — Bubble Sprite (Planet Style)

Замініть `{COLOR}` на свій колір англійською (наприклад: warm golden yellow, coral red, electric cyan).

---

## MAIN PROMPT

```
Single game bubble sprite, perfect circle, isolated on pure solid white background (#FFFFFF), no shadows on background, centered composition, one bubble only, no text, no watermark.

A glossy spherical bubble ball in {COLOR}, planet-like appearance: smooth radial gradient from lighter SATURATED highlight on top-left to deeper tone on bottom-right, subtle internal colored flowing lines and iridescent shimmer, candy arcade style, semi-translucent gelatin look, clean crisp PERFECT CIRCLE silhouette (width equals height), sharp edges, vector-game-ready, mobile game asset, bubble shooter style, high resolution, 2D orthographic view, symmetrical sphere. NO white specular dot, NO white reflections inside bubble.
```

---

## NEGATIVE PROMPT

```
multiple bubbles, cluster, background scene, gradient background, gray background, checkerboard, square, oval, ellipse, deformed circle, white highlight inside bubble, white specular dot, white sparkles inside, blurry edges, jagged edges, flat solid fill without depth, 3D render scene, hands, text, logo, watermark, frame, border square, cast shadow on floor, realistic photo background, noise, jpeg artifacts, low resolution, cropped, cut off
```

---

## КОРОТКИЙ ВАРІАНТ

```
Perfect circle game bubble, {COLOR}, planet-like glossy sphere, radial gradient, top-left highlight, iridescent shimmer, glass candy style, crisp edges, isolated on pure white background, single object, bubble shooter asset, 2D, no shadow on bg
```

---

## ПРИКЛАДИ {COLOR}

| Колір гри | Вставте в {COLOR} |
|-----------|-------------------|
| Ruby | vivid coral red with pink undertones |
| Amber | warm golden yellow with orange depth |
| Lime | bright apple green with yellow-green core |
| Aqua | electric cyan blue with teal shift |
| Violet | rich purple with blue-violet glow |
| Rose | hot pink magenta with rose highlights |

---

## SHEET — 6 кульок (рекомендовано v3)

**Файл:** `.cursor/docs/bubble_previews/Bubble-Collection-6-Lines-v3.png`  
**Альтернатива:** `Bubble-Collection-6-Lines-v2.png`  
**Застаріло (білі дірки):** `Bubble-Collection-6-InnerGlow.png`

| # | Колір | Hex | Всередині |
|---|-------|-----|-----------|
| 1 | Ruby | `#FF3D62` | рожево-коралові лінії |
| 2 | Amber | `#FFAB2B` | золото-помаранчеві смуги |
| 3 | Lime | `#72E763` | жовто-зелені завитки |
| 4 | Aqua | `#22D4FF` | бірюзові стрічки |
| 5 | Violet | `#B460F8` | фіолетово-сині swirl |
| 6 | Rose | `#FF5299` | магента-фуксія лінії |

### Правила генерації (без дірок при видаленні фону)

- **Ідеальне коло** — orthographic, width = height, не овал
- **Білий лише зовні** — між кульками на фоні `#FFFFFF`
- **Без білого всередині** — ні відблисків, ні зірочок, ні ядра
- **Переливи** — лише світліші/темніші відтінки того ж кольору + лінії

### PROMPT (sheet v3)

```
Six PERFECT CIRCLES same diameter in one row on white #FFFFFF, wide gaps for crop. NO white inside bubbles. Inner colored flowing lines and ribbon swirls only. Ruby #FF3D62, Amber #FFAB2B, Lime #72E763, Aqua #22D4FF, Violet #B460F8, Rose #FF5299. Lighter saturated tones for lighting, never white. Bubble shooter 2D asset.
```

### Як вирізати без дірок

1. **Круглий crop** (Figma ellipse / Photoshop elliptical marquee) — не прямокутник
2. **Не flood-fill весь білий** — він зʼїсть світлі ділянки всередині
3. Краще: **маска по колу** → прозорий фон зовні кола, всередині PNG не чіпати
4. Або Magic Wand з низьким tolerance лише на **фоні між кульками**
