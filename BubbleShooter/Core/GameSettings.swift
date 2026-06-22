//
//  GameSettings.swift
//  BubbleShooter
//

import Foundation

/// Player preferences — persisted locally. Gameplay reads these when audio/haptics are added.
enum GameSettings {

    private enum Key {
        static let soundEnabled = "settings.soundEnabled"
        static let musicEnabled = "settings.musicEnabled"
        static let hapticsEnabled = "settings.hapticsEnabled"
    }

    static var isSoundEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Key.soundEnabled) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Key.soundEnabled) }
    }

    static var isMusicEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Key.musicEnabled) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Key.musicEnabled) }
    }

    static var isHapticsEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Key.hapticsEnabled) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Key.hapticsEnabled) }
    }
}
