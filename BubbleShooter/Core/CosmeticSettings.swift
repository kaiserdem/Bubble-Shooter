//
//  CosmeticSettings.swift
//  BubbleShooter
//

import Foundation

/// Visual bubble sprite set — gameplay colors stay the same across packs.
enum BubbleSkinPack: String, CaseIterable, Codable, Sendable {

    case classic
    case ribbon
    case shimmer
    case planet
    case glossy

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .ribbon: "Ribbon"
        case .shimmer: "Shimmer"
        case .planet: "Planet"
        case .glossy: "Glossy"
        }
    }

    func spriteName(for color: BubbleColor) -> String {
        switch self {
        case .classic:
            return "Collection1/\(color.assetColorName)-1"
        case .ribbon:
            return "Collection2/\(color.assetColorName)-4"
        case .shimmer:
            return "Collection3/\(color.assetColorName)-5"
        case .planet:
            return "Collection4/\(color.assetColorName)-4"
        case .glossy:
            return "Collection5/\(color.assetColorName)-5"
        }
    }
}

/// Cannon artwork variant (`gun-1` … `gun-9` in Assets.xcassets/Guns).
enum CannonSkin: String, CaseIterable, Codable, Sendable {

    case standard
    case gold
    case nebula
    case solar
    case emerald
    case ruby
    case aurora
    case crystal
    case copper

    var displayName: String {
        switch self {
        case .standard: "Twilight Glass"
        case .gold: "Cosmic Gold"
        case .nebula: "Nebula Glow"
        case .solar: "Solar Flare"
        case .emerald: "Emerald Prism"
        case .ruby: "Ruby Eclipse"
        case .aurora: "Aurora Frost"
        case .crystal: "Crystal Nova"
        case .copper: "Copper Tide"
        }
    }

    /// Short label for the styles segmented control.
    var segmentTitle: String {
        switch self {
        case .standard: "Glass"
        case .gold: "Gold"
        case .nebula: "Nebula"
        case .solar: "Solar"
        case .emerald: "Emerald"
        case .ruby: "Ruby"
        case .aurora: "Aurora"
        case .crystal: "Crystal"
        case .copper: "Copper"
        }
    }

    var spriteName: String {
        switch self {
        case .standard: "gun-1"
        case .gold: "gun-2"
        case .nebula: "gun-3"
        case .solar: "gun-4"
        case .emerald: "gun-5"
        case .ruby: "gun-6"
        case .aurora: "gun-7"
        case .crystal: "gun-8"
        case .copper: "gun-9"
        }
    }

    /// Extra launch-port Y for gun art (SpriteKit points, +Y = up).
    var loadedBubbleYOffset: CGFloat {
        switch self {
        case .standard: -2
        case .gold: 12
        case .nebula: 14
        case .solar: 12
        case .emerald: 10
        case .ruby: 8
        case .aurora: 10
        case .crystal: 12
        case .copper: 10
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
            let pack = BubbleSkinPack(rawValue: raw) ?? .classic
            return CosmeticUnlockPolicy.canEquip(pack) ? pack : .classic
        }
        set {
            guard CosmeticUnlockPolicy.canEquip(newValue) else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.bubbleSkinPack)
            BubbleTextureCache.invalidate()
        }
    }

    static var cannonSkin: CannonSkin {
        get {
            let raw = UserDefaults.standard.string(forKey: Key.cannonSkin)
                ?? CannonSkin.standard.rawValue
            let skin = CannonSkin(rawValue: raw) ?? .standard
            return CosmeticUnlockPolicy.canEquip(skin) ? skin : .standard
        }
        set {
            guard CosmeticUnlockPolicy.canEquip(newValue) else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.cannonSkin)
        }
    }
}
