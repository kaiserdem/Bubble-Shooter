# Achievements (Досягнення)

## Опис

Система досягнень з відстеженням прогресу, нагородами в монетах (базові) та розблокуванням скінів (найвищий рівень). Екран у головному меню поруч із Shop.

## Вимоги

- [x] 12 стартових досягнень у каталозі
- [x] Трекінг: матчі, pop, clear board, score, drop за матч, покупки, володіння косметикою
- [x] Нагороди: монети (tier 1–2), скіни (tier 3)
- [x] Збереження локально + sync Skillz Progression (`PlayerData`)
- [x] Екран `AchievementsListView` у головному меню
- [x] Автоматична видача нагороди при виконанні умови

## Стартовий набір

| ID | Назва | Умова | Нагорода |
|----|-------|-------|----------|
| firstSteps | First Steps | 1 матч | 25 coins |
| regularPlayer | Regular Player | 10 матчів | 50 coins |
| bubblePopper | Bubble Popper | 250 pop (lifetime) | 75 coins |
| boardMaster | Board Master | 1 clear board | 100 coins |
| highScorer | High Scorer | 8 000 очок за матч | 100 coins |
| dropArtist | Drop Artist | 25 drop за матч | 75 coins |
| shopper | Shopper | 1 покупка в Shop | 50 coins |
| dedicated | Dedicated | 50 матчів | 150 coins |
| veteran | Veteran | 100 матчів | Cannon Solar |
| perfectionist | Perfectionist | 10 clear board | Bubble Ribbon |
| legend | Legend | 20 000 очок за матч | Cannon Gold |
| collector | Collector | 5 платних скінів | Bubble Planet |

## Критерії приймання

1. Після матчу оновлюються лічильники та перевіряються досягнення
2. Після покупки в Shop оновлюється Shopper / Collector
3. Монети та скіни застосовуються через `SkillzProgressionService`
4. Екран показує прогрес (напр. 3/10) і статус Completed
5. Прогрес зберігається після перезапуску додатку

## Пов’язані файли

- `BubbleShooter/Achievements/*`
- `BubbleShooter/UI/MainMenu/AchievementsListView.swift`
- `SkillzProgressionService.swift`, `GameViewController.swift`
