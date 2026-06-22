//
//  CosmeticSettings.swift
//  BubbleShooter
//

import Foundation

/// Visual bubble sprite set — gameplay colors stay the same across packs.
enum BubbleSkinPack: String, CaseIterable, Codable, Sendable {

    case classic
    case planet
    case glossy

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .planet: "Planet"
        case .glossy: "Glossy"
        }
    }

    private var assetSuffix: String {
        switch self {
        case .classic: "1"
        case .planet: "4"
        case .glossy: "5"
        }
    }

    func spriteName(for color: BubbleColor) -> String {
        "\(color.assetColorName)-\(assetSuffix)"
    }
}

/// Cannon artwork variant.
enum CannonSkin: String, CaseIterable, Codable, Sendable {

    case standard
    case gold
    case nebula

    var displayName: String {
        switch self {
        case .standard: "Standard"
        case .gold: "Gold"
        case .nebula: "Nebula"
        }
    }

    var spriteName: String {
        switch self {
        case .standard: "gun-1"
        case .gold: "gun-2"
        case .nebula: "gun-3"
        }
    }

    /// Extra launch-port Y for non-default gun art (SpriteKit points, +Y = up).
    var loadedBubbleYOffset: CGFloat {
        switch self {
        case .standard: -2
        case .gold: 12
        case .nebula: 14
        }
    }
}

/// Player cosmetic choices — applied on the next match.
enum CosmeticSettings {

    private enum Key {
        static let bubbleSkinPack = "cosmetics.bubbleSkinPack"
        static let cannonSkin = "cosmetics.cannonSkin"
    }

    static func installDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.bubbleSkinPack: BubbleSkinPack.classic.rawValue,
            Key.cannonSkin: CannonSkin.standard.rawValue,
        ])
    }

    static var bubbleSkinPack: BubbleSkinPack {
        get {
            let raw = UserDefaults.standard.string(forKey: Key.bubbleSkinPack)
                ?? BubbleSkinPack.classic.rawValue
            return BubbleSkinPack(rawValue: raw) ?? .classic
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.bubbleSkinPack)
            BubbleTextureCache.invalidate()
        }
    }

    static var cannonSkin: CannonSkin {
        get {
            let raw = UserDefaults.standard.string(forKey: Key.cannonSkin)
                ?? CannonSkin.standard.rawValue
            return CannonSkin(rawValue: raw) ?? .standard
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.cannonSkin)
        }
    }
}
