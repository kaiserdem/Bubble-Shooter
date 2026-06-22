//
//  MatchFinder.swift
//  BubbleShooter
//

import Foundation

/// Finds connected same-color bubble groups on the hex grid.
enum MatchFinder {

    static let minimumMatchSize = 3

    /// Connected same-color component that includes `position` (any size).
    static func connectedGroup(
        including position: GridPosition,
        in grid: BubbleGrid
    ) -> [GridPosition] {
        guard let originColor = grid.bubble(at: position)?.color else { return [] }

        var group: [GridPosition] = []
        var visited: Set<GridPosition> = []
        var queue = [position]
        visited.insert(position)

        while !queue.isEmpty {
            let current = queue.removeFirst()
            group.append(current)

            for neighbor in grid.neighbors(of: current) {
                guard !visited.contains(neighbor),
                      grid.bubble(at: neighbor)?.color == originColor else { continue }
                visited.insert(neighbor)
                queue.append(neighbor)
            }
        }

        return group.sorted()
    }

    /// Connected component of the same color that includes `position`.
    /// Returns sorted positions when size is at least `minimumMatchSize`.
    static func matchingGroup(
        including position: GridPosition,
        in grid: BubbleGrid,
        minimumSize: Int = minimumMatchSize
    ) -> [GridPosition]? {
        let group = connectedGroup(including: position, in: grid)
        guard group.count >= minimumSize else { return nil }
        return group
    }

    /// `true` when three or more connected bubbles of the same color include `position`.
    static func hasMatch(
        including position: GridPosition,
        in grid: BubbleGrid,
        minimumSize: Int = minimumMatchSize
    ) -> Bool {
        matchingGroup(including: position, in: grid, minimumSize: minimumSize) != nil
    }
}
