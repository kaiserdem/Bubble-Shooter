# Skillz Production — Archive, Deploy, Smoke Test

Game ID: `102977`  
Bundle: `com.hbubbleshooter.game`  
Version: `1.0` (build `1`)  
Environment in code: **production**

## 1. Archive + IPA (Xcode)

1. Відкрий **`BubbleShooter.xcworkspace`** (не `.xcodeproj`).
2. Destination: **Any iOS Device (arm64)**.
3. `Product → Archive`.
4. Organizer → **Distribute App**.
5. **App Store Connect → Export** (або Ad Hoc / Custom для прямої установки).
6. У Distribution Options **вимкни** **Manage Version and Build Number**.
7. Збережи `.ipa` (наприклад `~/Desktop/BubbleShooter-1.0-1.ipa`).

## 2. Upload у Skillz Console

1. [developers.skillz.com](https://developers.skillz.com) → гра `102977` → **Deployments**.
2. **Add game build** → вибери той самий `.ipa`.
3. Version `1.0` / build notes → **Save**.
4. Дочекайся, поки білд стане доступним. Якщо не enable — `integrations@skillz.com`.

## 3. Встановлення на iPhone

Встанови **exported** `.ipa` (Devices and Simulators / TestFlight / Apple Configurator).  
Не покладайся лише на Run з Xcode — Skillz звіряє бінарник з uploaded.

## 4. Smoke test

- [ ] App стартує без крашу на Skillz `init`
- [ ] Launch Skillz з меню гри
- [ ] Логін у **Production** акаунт (не sandbox)
- [ ] Старт турніру → матч SpriteKit
- [ ] Score оновлюється / results повертають у Skillz
- [ ] Abort / forfeit з підтвердженням
- [ ] Cash / entry (якщо турніри налаштовані)
- [ ] Shop / Progression (якщо вже в Console)
- [ ] Немає крашу при `returnToSkillz` / exit

## 5. Якщо init падає

Найчастіше: `.ipa` ще не в Deployments, або на девайсі **інший** білд ніж uploaded.  
Залити знову той самий Archive export і перевстановити.

## 6. Далі (App Store)

- Apple **Organization** account (не Individual)
- Той самий бінарник у App Store Connect
- Skillz Production login для App Review
- Publish on Skillz Games → лінк на App Store
