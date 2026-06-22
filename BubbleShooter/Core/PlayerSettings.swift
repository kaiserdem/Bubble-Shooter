//
//  PlayerSettings.swift
//  BubbleShooter
//

import Foundation

/// Boots persisted player preferences before any screen reads them.
enum PlayerSettings {

    static func installDefaults() {
        GameSettings.installDefaults()
        CosmeticSettings.installDefaults()
    }
}
