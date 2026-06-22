# Skillz + SpriteKit (UIKit): інструкція з інтеграції та вирішення проблем

Документ описує, як ми інтегрували **Skillz SDK** у **BubbleShooter** (SpriteKit + UIKit) і як вирішили типові краші. Використовуйте як чеклист для нових iOS-проєктів.

**Проєкт-еталон:** `BubbleShooter`  
**Game ID:** `102977` (sandbox)  
**SDK:** Skillz **2025.0.50** через CocoaPods + GeoComply з zip `skillz_ios_2025050`

---

## 1. Архітектура (що куди йде)

| Компонент | Джерело | Примітка |
|-----------|---------|----------|
| `Skillz.framework` | **CocoaPods** | Не додавати вручну в Xcode |
| Kochava, AppLovin, Rive | CocoaPods (транзитивно) | Embed через `[CP] Embed Pods Frameworks` |
| GeoComply | **Zip Skillz SDK** → `Vendor/Skillz/GeocomplySDKs/` | Embed вручну в Xcode |
| Гра (SpriteKit) | Ваш код | `GameViewController` + `SkillzGameDelegate` |

**Відкривати:** `BubbleShooter.xcworkspace` (не `.xcodeproj`).

---

## 2. Початкове налаштування

### 2.1 CocoaPods (`Podfile`)

```ruby
platform :ios, '16.6'
use_frameworks!

target 'YourApp' do
  pod 'Skillz', '2025.0.50'   # має збігатися з zip-архівом SDK
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.6'
    end
  end

  # Skillz Swift module несумісний з новим Xcode — викликаємо через ObjC bridging header
  swiftmodule = File.join(installer.sandbox.root, 'Skillz/Skillz.framework/Modules/Skillz.swiftmodule')
  disabled = "#{swiftmodule}.disabled"
  if Dir.exist?(swiftmodule) && !Dir.exist?(disabled)
    FileUtils.mv(swiftmodule, disabled)
  end
end
```

Після `pod install` — завжди workspace.

> **Застаріло:** `pod 'Skillz', '~> 29.0'` — Skillz давно на версіях `2025.x` / `2026.x`.

### 2.2 GeoComply з архіву Skillz

1. Завантажити iOS SDK з [Skillz Developer Console](https://developers.skillz.com) → Downloads  
   (у нас: `skillz_ios_2025050` / `skillz_ios_2025050.tgz`)
2. Оновити GeoComply:

```bash
./Scripts/update_geocomply_from_skillz_sdk.sh ~/Downloads/skillz_ios_2025050
```

3. У Xcode → Target → **Frameworks, Libraries, and Embedded Content** → **Embed & Sign**:
   - `GeoComplySDK.xcframework`
   - `GeoComplySDK2110.xcframework` (2025.x) або `GeoComplySDK280.xcframework` (2026.x)
   - `GCSDKDomain.xcframework`
4. `Pods_YourApp.framework` → **Do Not Embed** (це нормально)

**Правило:** версія **Skillz pod** і **GeoComply з zip** мають бути з **одного релізу**.

### 2.3 Build Phases (порядок важливий)

Останні фази мають бути так:

1. `Embed Frameworks` (GeoComply)
2. `[CP] Embed Pods Frameworks` (Skillz, Kochava, …)
3. **`Skillz Postprocess`** — **останній**

Run Script:

```bash
if [ -e "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Skillz.framework/postprocess.sh" ]; then
    /bin/sh "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Skillz.framework/postprocess.sh"
fi
```

### 2.4 Build Settings

- `USE_SKILLZ_SDK` — лише для **iphoneos** (реальний iPhone)
- Симулятор: `MockSkillzService`, без Skillz
- `INFOPLIST_KEY_UIApplicationSceneManifest_Generation = NO` — обов'язково для Skillz 2025.x
- Bridging header: device → `SkillzBridgingHeader.h`, simulator → порожній заголовок

### 2.5 Info.plist

Додати privacy keys (Skillz postprocess теж частину додає, але краще мати в plist):

- `NSContactsUsageDescription`
- `NSLocationWhenInUseUsageDescription` (+ Always якщо потрібно)
- `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`
- `NSUserTrackingUsageDescription`
- Bluetooth, Motion, Calendar — за документацією Skillz

---

## 3. Критично: НЕ використовувати UIScene (Skillz 2025.x)

### Симптом

```
Terminating app due to uncaught exception 'NSObjectNotAvailableException',
reason: 'UIAlertView is deprecated and unavailable for UIScene based applications'
```

Або: порожнє / нетактильне лобі, `App delegate found: (null)`.

### Рішення

Skillz **2025.0.50** використовує застарілий `UIAlertView`. На iOS 13+ з UIScene це **миттєвий краш**.

**Зробити:**

1. **Немає** `SceneDelegate.swift`
2. **Немає** `UIApplicationSceneManifest` у `Info.plist`
3. **Немає** `configurationForConnecting` у `AppDelegate`
4. У `AppDelegate` є `var window: UIWindow?`
5. У Build Settings: `INFOPLIST_KEY_UIApplicationSceneManifest_Generation = NO`
6. Skillz postprocess **видаляє** `UIApplicationSceneManifest` з бандла — це ОК

**Не робити:** хак `UIAlertView+SkillzFix.swift` — ненадійно.

**Майбутнє:** Skillz **2026.x** + GeoComply **280** з нового zip — тоді можна пробувати UIScene (перевірити на девайсі).

---

## 4. Типові краші та рішення

### 4.1 `Library not loaded: .../Skillz.framework`

Skillz не embed'иться в `.app`.

- Відкривати `.xcworkspace`
- Переконатися, що `[CP] Embed Pods Frameworks` є в Build Phases
- `Skillz Postprocess` — **після** embed
- Clean → видалити app з телефона → Run

### 4.2 `Library not loaded: .../KochavaCore.framework`

Те саме — Kochava йде з Skillz pod, embed через CocoaPods. Не додавати Kochava вручну.

### 4.3 `Symbol not found: _OBJC_CLASS_$_GCReasonCode`

**Причина:** Skillz pod **2026.x**, GeoComply з zip **2025.x** (або навпаки).

**Рішення:**

- Або `pod 'Skillz', '2025.0.50'` + GeoComply з `skillz_ios_2025050`
- Або `pod 'Skillz', '~> 2026.0'` + новий zip + `./Scripts/update_geocomply_from_skillz_sdk.sh` + `GeoComplySDK280`

Скрипт перевіряє наявність `GCReasonCode` у GeoComply binary.

### 4.4 `NSContactsUsageDescription` / Integration Error

- Додати ключі в `Info.plist`
- `Skillz Postprocess` має бути **останнім** (після `[CP] Embed Pods Frameworks`)

### 4.5 Порожнє / нетактильне лобі Play

Часто через UIScene або старий білд на телефоні.

- Вимкнути UIScene (розділ 3)
- Видалити app → Clean Build Folder → Run на **реальному iPhone**

### 4.6 Score `null` у Skillz Console

Під час гри:

```swift
SkillzSDKBridge.updateCurrentScore(state.score)
```

Після завершення (Submit Score):

```swift
SkillzSDKBridge.displayTournamentResults(score: results.finalScore) { ... }
```

---

## 5. Код інтеграції (SpriteKit + UIKit)

### 5.1 Файли Skillz

| Файл | Роль |
|------|------|
| `SkillzConfiguration.swift` | `gameID`, `environment` |
| `SkillzSDKBridge.swift` | init, launch, score, results |
| `SkillzAppCoordinator.swift` | `SkillzDelegate` |
| `SkillzBridgingHeader.h` | ObjC bridge до Skillz (device) |
| `MockSkillzService.swift` | Симулятор без SDK |

### 5.2 AppDelegate

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: ...) -> Bool {
        #if USE_SKILLZ_SDK
        SkillzSDKBridge.initialize(
            gameID: SkillzConfiguration.gameID,
            environment: SkillzConfiguration.environment,
            delegate: SkillzAppCoordinator.shared
        )
        #endif
        return true
    }
}
```

### 5.3 GameViewController (SpriteKit)

- Кнопка **Play** → `SkillzSDKBridge.launchSkillz()` (device) або mock (simulator)
- `SkillzGameDelegate.tournamentWillBegin` → старт `GameScene` з `matchSeed` / `gameParameters`
- Під час гри → `updateCurrentScore`
- Кінець матчу → `displayTournamentResults`

Skillz викликає `tournamentWillBegin` — ви презентуєте SpriteKit-сцену з параметрами турніру (`TimeLimit`, `ColorCount`, …).

### 5.4 Детермінізм для PvP

- Один `matchSeed` на матч → `DeterministicRandom`
- Заборонено `Int.random`, `UUID()`, `Date()` у геймплеї
- Див. `.cursor/specs/game/bubble_shooter_skillz.md`

---

## 6. Чеклист перед тестом на iPhone

- [ ] `pod install`, відкрито `.xcworkspace`
- [ ] Skillz pod версія = GeoComply zip версія
- [ ] GeoComply: Embed & Sign (3 xcframework)
- [ ] Skillz Postprocess — останній у Build Phases
- [ ] Немає UIScene / SceneDelegate
- [ ] `UIApplicationSceneManifest_Generation = NO`
- [ ] Privacy keys у Info.plist
- [ ] Target: **iPhone**, не Simulator (`USE_SKILLZ_SDK` only device)
- [ ] Видалити старий app → Clean → Run

---

## 7. Логи — що ігнорувати

| Лог | Норма? |
|-----|--------|
| `App delegate found: (null)` | Так, якщо немає крашу |
| `UIScene lifecycle will soon be required` | Так для Skillz 2025 без Scene |
| `CleverTap SDK not properly initialized` | Так (опційна аналітика) |
| `progression_rooms` 404 | Так, якщо Progression не налаштовано |
| `Datadog SDK usage error` | Так у Debug |
| Auto Layout constraints у Skillz UI | Внутрішній RN UI Skillz |

---

## 8. Оновлення до Skillz 2026.x (майбутнє)

1. Завантажити **новий** iOS SDK zip з Console (той самий реліз, що pod)
2. `./Scripts/update_geocomply_from_skillz_sdk.sh ~/Downloads/skillz_ios_XXXXX`
3. У `Podfile`: `pod 'Skillz', '~> 2026.0'`
4. `pod install`
5. У Xcode замінити `GeoComplySDK2110` → `GeoComplySDK280` (скрипт може зробити автоматично)
6. Протестувати UIScene (опційно) — 2026 може підтримувати `UIAlertController`
7. Clean + перевстановити на девайсі

---

## 9. Production

1. `SkillzConfiguration.environment` → `.production`
2. Зібрати Archive → `.ipa`
3. Upload у Skillz Console → Deployments
4. Sandbox-турніри не потребують upload для щоденного тесту

---

## 10. Корисні посилання

- [Installing Skillz iOS](https://docs.skillz.com/docs/installing-skillz-ios/)
- Skillz Developer Console: game ID, tournaments, game parameters
- Скрипт GeoComply: `Scripts/update_geocomply_from_skillz_sdk.sh`
- Spec гри: `.cursor/specs/game/bubble_shooter_skillz.md`

---

*Останнє оновлення: червень 2026 — BubbleShooter, Skillz 2025.0.50, iOS 26.x, Xcode 26.*
