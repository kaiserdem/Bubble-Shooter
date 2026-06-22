//
//  GridConfiguration.swift
//  BubbleShooter
//

import Foundation

struct GridConfiguration: Equatable, Sendable {

    /// Column count on even rows (`row % 2 == 0`). Odd rows use one fewer column.
    let columnCount: Int
    /// Maximum playable rows (ceiling anchor + danger zone).
    let maxRows: Int

    static let `default` = GridConfiguration(columnCount: 8, maxRows: 14)

    func columnCount(forRow row: Int) -> Int {
        guard row >= 0, row < maxRows else { return 0 }
        return row.isMultiple(of: 2) ? columnCount : columnCount - 1
    }

    func isValid(_ position: GridPosition) -> Bool {
        guard position.row >= 0, position.row < maxRows else { return false }
        guard position.col >= 0 else { return false }
        return position.col < columnCount(forRow: position.row)
    }
}
