//
//  BubbleGrid.swift
//  BubbleShooter
//

import Foundation

enum BubbleGridError: Error, Equatable {
    case invalidPosition(GridPosition)
    case occupied(GridPosition)
    case empty(GridPosition)
}

struct BubbleGrid: Equatable, Sendable {

    let configuration: GridConfiguration
    private(set) var cells: [GridPosition: Bubble]

    init(configuration: GridConfiguration = .default, cells: [GridPosition: Bubble] = [:]) {
        self.configuration = configuration
        self.cells = cells
    }

    var occupiedPositions: [GridPosition] {
        cells.keys.sorted()
    }

    func isValid(_ position: GridPosition) -> Bool {
        configuration.isValid(position)
    }

    func bubble(at position: GridPosition) -> Bubble? {
        cells[position]
    }

    func isOccupied(_ position: GridPosition) -> Bool {
        cells[position] != nil
    }

    func neighbors(of position: GridPosition) -> [GridPosition] {
        guard isValid(position) else { return [] }

        let deltas: [(Int, Int)]
        if position.row.isMultiple(of: 2) {
            // Odd-r layout: even rows (matches `HexLayout` honeycomb).
            deltas = [(-1, -1), (-1, 0), (0, -1), (0, 1), (1, -1), (1, 0)]
        } else {
            deltas = [(-1, 0), (-1, 1), (0, -1), (0, 1), (1, 0), (1, 1)]
        }

        return deltas.compactMap { dRow, dCol in
            let neighbor = GridPosition(row: position.row + dRow, col: position.col + dCol)
            return isValid(neighbor) ? neighbor : nil
        }
    }

    mutating func place(_ bubble: Bubble, at position: GridPosition) throws {
        guard isValid(position) else { throw BubbleGridError.invalidPosition(position) }
        guard !isOccupied(position) else { throw BubbleGridError.occupied(position) }
        cells[position] = bubble
    }

    @discardableResult
    mutating func remove(at position: GridPosition) throws -> Bubble {
        guard let bubble = cells.removeValue(forKey: position) else {
            throw BubbleGridError.empty(position)
        }
        return bubble
    }
}
