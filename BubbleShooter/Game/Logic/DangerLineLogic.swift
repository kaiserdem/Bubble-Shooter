//
//  DangerLineLogic.swift
//  BubbleShooter
//

import CoreGraphics
import Foundation

enum DangerLineLogic {

    /// `true` when any occupied bubble center is below the danger line (lost).
    static func hasBubbleBelowLine(
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration,
        dangerLineY: CGFloat
    ) -> Bool {
        grid.occupiedPositions.contains { position in
            let centerY = layout.center(for: position, configuration: configuration).y
            return centerY < dangerLineY
        }
    }

    /// Warning band — bubbles approaching the danger threshold.
    static func isWarningActive(
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration,
        dangerLineY: CGFloat,
        warningRowSpan: Int = 2
    ) -> Bool {
        let rowStep = layout.verticalRowStep * CGFloat(warningRowSpan)
        let warningThreshold = dangerLineY + rowStep

        return grid.occupiedPositions.contains { position in
            let centerY = layout.center(for: position, configuration: configuration).y
            return centerY < warningThreshold
        }
    }
}
