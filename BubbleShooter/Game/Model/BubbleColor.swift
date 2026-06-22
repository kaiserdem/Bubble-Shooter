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

    /// Pop animation frames in `Assets.xcassets/Expression/`, when available.
    var explosionFrameNames: [String]? {
        switch self {
        case .ruby: ["Ruby-explosion-1", "Ruby-explosion-2"]
        default: nil
        }
    }

    var themeUIColor: UIColor {
        Theme.Bubble.uiColor(at: rawValue)
    }
}
