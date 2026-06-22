//
//  ConnectivityChecker.swift
//  BubbleShooter
//

import Foundation

/// Finds bubbles anchored to the ceiling (row 0) vs floating clusters.
enum ConnectivityChecker {

    /// Occupied positions connected to the ceiling through neighbor links.
    static func anchoredPositions(in grid: BubbleGrid) -> Set<GridPosition> {
        var anchored = Set<GridPosition>()
        var queue: [GridPosition] = []

        for position in grid.occupiedPositions where position.row == 0 {
            guard anchored.insert(position).inserted else { continue }
            queue.append(position)
        }

        while !queue.isEmpty {
            let current = queue.removeFirst()
            for neighbor in grid.neighbors(of: current) {
                guard grid.isOccupied(neighbor), anchored.insert(neighbor).inserted else { continue }
                queue.append(neighbor)
            }
        }

        return anchored
    }

    /// Occupied positions with no path to row 0, sorted for deterministic removal.
    static func floatingPositions(in grid: BubbleGrid) -> [GridPosition] {
        let anchored = anchoredPositions(in: grid)
        return grid.occupiedPositions.filter { !anchored.contains($0) }
    }
}
