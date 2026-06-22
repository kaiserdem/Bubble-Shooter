//
//  GridPosition.swift
//  BubbleShooter
//

import Foundation

/// Odd-row horizontal offset hex cell on a staggered bubble grid.
struct GridPosition: Hashable, Codable, Sendable, Comparable {

    let row: Int
    let col: Int

    static func < (lhs: GridPosition, rhs: GridPosition) -> Bool {
        if lhs.row != rhs.row { return lhs.row < rhs.row }
        return lhs.col < rhs.col
    }
}
