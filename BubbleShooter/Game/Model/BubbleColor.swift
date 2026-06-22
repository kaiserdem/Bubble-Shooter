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

    /// Asset name in `Assets.xcassets/Collection1/`.
    var spriteName: String {
        switch self {
        case .ruby: "Ruby-1"
        case .amber: "Amber-1"
        case .lime: "Lime-1"
        case .aqua: "Aqua-1"
        case .violet: "Violet-1"
        case .rose: "Rose-1"
        }
    }

    var themeUIColor: UIColor {
        Theme.Bubble.uiColor(at: rawValue)
    }
}
