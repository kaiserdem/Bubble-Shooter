//
//  GameSettings.swift
//  BubbleShooter
//

import Foundation

/// Player preferences — persisted in `UserDefaults` between app launches.
enum GameSettings {

    private enum Key {
        static let soundEnabled = "settings.soundEnabled"
        static let musicEnabled = "settings.musicEnabled"
        static let hapticsEnabled = "settings.hapticsEnabled"
    }

    /// Call once at launch before reading any preference.
    static func installDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.soundEnabled: true,
            Key.musicEnabled: true,
            Key.hapticsEnabled: true,
        ])
    }

    static var isSoundEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Key.soundEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Key.soundEnabled) }
    }

    static var isMusicEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Key.musicEnabled) }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.musicEnabled)
            BackgroundMusicPlayer.shared.applyMusicSetting()
        }
    }

    static var isHapticsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Key.hapticsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Key.hapticsEnabled) }
    }
}
