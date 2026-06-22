//
//  BubbleColor.swift
//  BubbleShooter
//

import UIKit

/// Fixed gameplay color set — index order must stay stable for determinism and Skillz params.
enum BubbleColor: Int, CaseIterable, Codable, Sendable {

    case ruby = 0
    case amber
    case lime
    case aqua
    case violet
    case rose

    /// Asset name for the active bubble skin pack.
    var spriteName: String {
        CosmeticSettings.bubbleSkinPack.spriteName(for: self)
    }

    /// Pop animation frames in `Assets.xcassets/Expression/`.
    var explosionFrameNames: [String] {
        switch self {
        case .amber:
            return ["Amber-explosion-1", "Amber- explosion-2"]
        default:
            let name = assetColorName
            return ["\(name)-explosion-1", "\(name)-explosion-2"]
        }
    }

    /// Prefix used by bubble and explosion assets (`Ruby`, `Amber`, …).
    var assetColorName: String {
        switch self {
        case .ruby: "Ruby"
        case .amber: "Amber"
        case .lime: "Lime"
        case .aqua: "Aqua"
        case .violet: "Violet"
        case .rose: "Rose"
        }
    }

    var themeUIColor: UIColor {
        Theme.Bubble.uiColor(at: rawValue)
    }
}
