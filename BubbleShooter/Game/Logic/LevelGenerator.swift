//
//  LevelGenerator.swift
//  BubbleShooter
//

import Foundation

enum LevelGenerator {

    static func generate(
        random: DeterministicRandom,
        parameters: MatchGameplayParameters
    ) -> BubbleGrid {
        generate(
            random: random,
            configuration: parameters.gridConfiguration,
            initialRows: parameters.initialRows,
            colorCount: parameters.colorCount
        )
    }

    static func generate(
        random: DeterministicRandom,
        configuration: GridConfiguration,
        initialRows: Int,
        colorCount: Int
    ) -> BubbleGrid {
        var grid = BubbleGrid(configuration: configuration)
        let palette = Array(BubbleColor.allCases.prefix(colorCount))
        guard !palette.isEmpty else { return grid }

        let rows = min(max(initialRows, 0), configuration.maxRows)

        for row in 0..<rows {
            let columns = configuration.columnCount(forRow: row)
            for col in 0..<columns {
                let position = GridPosition(row: row, col: col)
                let color = palette[random.nextInt(upperBound: palette.count)]
                try? grid.place(Bubble(color: color), at: position)
            }
        }

        return grid
    }
}
