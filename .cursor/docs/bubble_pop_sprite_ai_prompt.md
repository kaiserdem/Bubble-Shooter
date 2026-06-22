# AI Prompt — Bubble Pop / Burst Frames (Cosmic Pop Twilight)

Документ для генерації **3 кадрів розпаду кульки** під bubble shooter.  
Стиль має збігатися з існуючими спрайтами `Collection1/*-1` (планетна скляна кулька).

---

## Концепція (для людини / AI)

Замість процедурної анімації в грі показуємо **3 послідовні PNG** на одну кульку:

| Кадр | Файл | Стан |
|------|------|------|
| **1** | `{Name}-Pop-1` | Початок вибуху: кулька ще читається, перші тріщини / дрібні бризки |
| **2** | `{Name}-Pop-2` | Розліт: кулька розсипається, більше крапель по колу |
| **3** | `{Name}-Pop-3` | Згасання: лише розлітлі бризки, центр майже порожній |

Усі 3 кадри — **один і той самий розмір полотна**, кулька по центру, фон **чисто білий `#FFFFFF`**.

---

## Який колір у вибуху (рішення для проєкту)

### Рекомендація: **колір кульки + космічне ядро**

| Шар | Колір | Навіщо |
|-----|-------|--------|
| **Ядро спалаху** | білий → `#EAF0FF` | читається на темному фоні гри `#243558` |
| **Бризки / уламки** | **той самий `{COLOR}` що й кулька** | гравець бачить, який колір зник |
| **Дрібні іскри (5–10%)** | electric cyan `#00DDE0` або gold `#FFC44B` | фірмовий акцент Cosmic Pop, не перебиває колір кульки |

**Не робити:** один універсальний помаранчевий/червоний «arcade explosion» для всіх кольорів — втратиться зв’язок з палітрою гри.

**Не робити:** повністю інший колір бризок (наприклад, зелена кулька → фіолетовий вибух) — плутанина при match-3.

### Альтернатива (менше ассетів)

Один нейтральний набір `Pop-1/2/3` (білі бризки) + **tint у коді** кольором кульки. Швидше, але гірша якість ніж 6 окремих наборів.

**Для MVP якості:** генерувати **6 наборів × 3 кадри = 18 PNG** (Ruby, Amber, Lime, Aqua, Violet, Rose).

---

## Технічні вимоги до PNG

- Формат: **PNG**, квадрат **512×512** (або той самий розмір, що й `*-1` спрайти)
- Фон: **суцільний білий `#FFFFFF`**, без тіні на фоні
- Композиція: **по центру**, ~70–80% діаметра полотна займає ефект
- Стиль: glossy gelatin / candy planet — як у [bubble_sprite_ai_prompt.md](./bubble_sprite_ai_prompt.md)
- Без тексту, логотипів, рамок, сцени, інших кульок
- Краї чіткі, mobile game asset, 2D, камера фронтально

### Імена файлів (покласти в `Assets.xcassets/Collection1/`)

```
Ruby-Pop-1.png   Ruby-Pop-2.png   Ruby-Pop-3.png
Amber-Pop-1.png  ...
Lime-Pop-1.png   ...
Aqua-Pop-1.png   ...
Violet-Pop-1.png ...
Rose-Pop-1.png   ...
```

---

## MAIN PROMPT — Кадр 1 (початок вибуху)

Замініть `{COLOR}` і `{NAME}` (Ruby / Amber / …).

```
Single bubble pop animation frame 1 of 3, game VFX sprite, isolated on pure solid white background (#FFFFFF), centered composition, no text, no watermark.

A glossy {COLOR} candy-planet bubble beginning to burst: the sphere is still mostly intact but cracking, small glossy droplets and shards peeling off the surface, radial splash starting outward, semi-translucent gelatin glass look, top-left specular highlight, subtle iridescent shimmer, tiny cosmic sparkles in electric cyan (#00DDE0) and soft white core glow, bubble shooter mobile game style, 2D flat camera, crisp edges, high resolution, one effect only.
```

---

## MAIN PROMPT — Кадр 2 (розліт)

```
Single bubble pop animation frame 2 of 3, game VFX sprite, isolated on pure solid white background (#FFFFFF), centered composition, no text, no watermark.

A {COLOR} glossy bubble mid-explosion: the main sphere breaking into 4-6 curved jelly fragments, many droplets and splash beads flying outward in a ring, stronger radial motion than frame 1, candy arcade gelatin style, bright white flash at the center (#FFFFFF), faint cyan (#00DDE0) micro-sparkles, planet-bubble material matching Cosmic Pop Twilight game, 2D game asset, sharp silhouette, mobile bubble shooter, high resolution, one effect only.
```

---

## MAIN PROMPT — Кадр 3 (згасання)

```
Single bubble pop animation frame 3 of 3, game VFX sprite, isolated on pure solid white background (#FFFFFF), centered composition, no text, no watermark.

Final fade stage of a {COLOR} bubble pop: no solid sphere left, only scattered small glossy droplets and tiny shards spreading outward and dissolving, fewer and smaller particles than frame 2, softer opacity on splashes, faint white mist in the center, subtle cyan (#00DDE0) glitter dots, candy gelatin bubble shooter style, 2D, crisp edges, high resolution, one effect only.
```

---

## NEGATIVE PROMPT (для всіх 3 кадрів)

```
full intact bubble only, second bubble, cluster of bubbles, fire explosion, smoke cloud, realistic photo, pixel art, low resolution, blurry, jpeg artifacts, gray background, gradient background, checkerboard, ground shadow, text, logo, watermark, frame border, blood, violent explosion, dark background, 3D scene render, hands, weapons
```

---

## КОРОТКИЙ ВАРІАНТ (одним рядком)

**Pop-1:** `{COLOR} bubble starting to crack, small splashes, white core, white bg`  
**Pop-2:** `{COLOR} bubble shattering outward, many jelly droplets, white flash center, white bg`  
**Pop-3:** `{COLOR} splash remnants only, fading droplets, almost gone, white bg`

---

## Таблиця `{COLOR}` (як у bubble sprites)

| Name | `{COLOR}` для промпту |
|------|------------------------|
| Ruby | vivid coral red with pink undertones |
| Amber | warm golden yellow with orange depth |
| Lime | bright apple green with yellow-green core |
| Aqua | electric cyan blue with teal shift |
| Violet | rich purple with blue-violet glow |
| Rose | hot pink magenta with rose highlights |

---

## Як це буде в грі (для розробника, пізніше)

1. Після match ≥ 3 — показати `BubbleColor.popFrame1/2/3` (~0.08–0.10 с на кадр).
2. Позиція = центр hex-комірки, розмір = `bubbleVisualDiameter`.
3. Після кадру 3 — прибрати node, кульки вже видалені з `BubbleGrid`.
4. Процедурні `CosmicShatter` / `Supernova` можна вимкнути, коли ассети готові.

---

## Чеклист після генерації

- [ ] 18 файлів (6 кольорів × 3 кадри)
- [ ] Однаковий розмір і центрування у всіх кадрах одного кольору
- [ ] Білий фон без сірого ореолу
- [ ] Бризки того ж відтінку, що й кулька `{Name}-1`
- [ ] Кадр 1 слабший за кадр 2; кадр 3 найрозрідженийший

---

## Референс стилю

- Гра: **Cosmic Pop Twilight**
- Фон сцени: `#243558`
- Акценти: cyan `#00DDE0`, gold `#FFC44B`
- Існуючі кульки: `Assets.xcassets/Collection1/{Name}-1.imageset`
