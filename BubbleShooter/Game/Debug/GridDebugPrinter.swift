//
//  GridDebugPrinter.swift
//  BubbleShooter
//

import CoreGraphics
import Foundation

#if DEBUG

enum GridDebugPrinter {

    static var isEnabled = true
    private static var didPrintLegend = false

    // MARK: - Shot logging

    static func logShot(
        hit: ShotHit,
        shotBubble: Bubble,
        grid: BubbleGrid,
        configuration: GridConfiguration,
        analysis: SnapResolver.Analysis
    ) {
        guard isEnabled else { return }
        printLegendIfNeeded()

        let hitPosition: GridPosition? = {
            if case .bubble(let position) = hit.target { return position }
            return nil
        }()

        var lines: [String] = []
        lines.append(divider())
        lines.append("🎯 ПОСТРІЛ → \(shotBubble.color.debugEmoji) \(shotBubble.color.debugName)")
        lines.append("   Кульок на полі: \(grid.occupiedPositions.count)")
        lines.append("   Удар: \(describe(hit: hit))")
        lines.append("   Точка impact: (\(fmt(hit.point.x)), \(fmt(hit.point.y)))")

        if let hitPosition {
            lines.append("   Сусіди удару \(coord(hitPosition)):")
            lines.append(neighborLine(around: hitPosition, grid: grid, highlight: shotBubble.color))
        }

        if analysis.candidates.isEmpty {
            lines.append("   ⚠️ Кандидатів snap немає")
        } else {
            lines.append("   Кандидати snap (score = розмір групи того ж кольору):")
            for candidate in analysis.candidates.sorted(by: SnapResolver.Analysis.Candidate.sortForDisplay) {
                let marker = candidate.position == analysis.chosen ? " ← обрано" : ""
                lines.append(
                    "     \(coord(candidate.position)) " +
                    "score=\(candidate.connectionScore) dist=\(fmt(candidate.distanceToImpact))\(marker)"
                )
            }
        }

        if let chosen = analysis.chosen {
            lines.append("   📌 Snap → \(coord(chosen))")
            lines.append("   Сусіди snap \(coord(chosen)):")
            lines.append(neighborLine(around: chosen, grid: grid, highlight: shotBubble.color))

            var preview = grid
            guard (try? preview.place(shotBubble, at: chosen)) != nil else {
                lines.append("   ❌ Симуляція place не вдалась")
                lines.append(divider())
                print(lines.joined(separator: "\n"))
                return
            }

            let group = MatchFinder.connectedGroup(including: chosen, in: preview)
            let match = group.count >= MatchFinder.minimumMatchSize
            lines.append(
                "   🔗 Група \(shotBubble.color.debugEmoji) після snap: \(group.count) " +
                "→ \(formatPositions(group))"
            )
            lines.append(
                match
                    ? "   💥 Match ≥ \(MatchFinder.minimumMatchSize) — ТАК"
                    : "   💨 Match ≥ \(MatchFinder.minimumMatchSize) — НІ (колір пострілу ≠ кластер?)"
            )

            lines.append("")
            lines.append("   ▼ Як на симуляторі ЗАРАЗ (\(grid.occupiedPositions.count) кульок):")
            lines.append(
                render(
                    grid: grid,
                    configuration: configuration,
                    incomingShot: shotBubble.color,
                    snap: chosen,
                    matchGroup: match ? Set(group) : [],
                    hit: hitPosition
                )
            )

            lines.append("")
            lines.append("   ▼ Після snap (попередній перегляд, без pop):")
            lines.append(
                render(
                    grid: preview,
                    configuration: configuration,
                    incomingShot: shotBubble.color,
                    matchGroup: Set(group),
                    hit: hitPosition
                )
            )
        } else {
            lines.append("   ❌ Snap не знайдено")
            lines.append("")
            lines.append("   ▼ Сітка зараз:")
            lines.append(render(grid: grid, configuration: configuration))
        }

        lines.append(divider())
        print(lines.joined(separator: "\n"))
    }

    static func logMatchResult(
        at position: GridPosition,
        grid: BubbleGrid,
        configuration: GridConfiguration,
        group: [GridPosition]?
    ) {
        guard isEnabled else { return }

        var lines: [String] = []
        lines.append("   ── resolveMatches @ \(coord(position)) ──")

        if let group {
            let color = grid.bubble(at: position)?.color
            lines.append(
                "   💥 POP \(group.count) \(color?.debugEmoji ?? "?") " +
                "→ \(formatPositions(group))"
            )
            lines.append(
                render(
                    grid: grid,
                    configuration: configuration,
                    matchGroup: Set(group)
                )
            )
        } else {
            let connected = MatchFinder.connectedGroup(including: position, in: grid)
            let color = grid.bubble(at: position)?.color
            lines.append(
                "   💨 Без вибуху — \(color?.debugEmoji ?? "?") група \(connected.count) " +
                "(\(formatPositions(connected))), потрібно ≥ \(MatchFinder.minimumMatchSize)"
            )
            lines.append("   Сусіди \(coord(position)):")
            lines.append(neighborLine(around: position, grid: grid, highlight: color))
        }

        print(lines.joined(separator: "\n"))
    }

    // MARK: - Grid render

    /// Text grid with odd-row half-cell indent (same honeycomb idea as `HexLayout`).
    static func render(
        grid: BubbleGrid,
        configuration: GridConfiguration,
        incomingShot: BubbleColor? = nil,
        snap: GridPosition? = nil,
        matchGroup: Set<GridPosition> = [],
        hit: GridPosition? = nil
    ) -> String {
        let occupiedRows = grid.occupiedPositions.map(\.row)
        let minRow = occupiedRows.min() ?? 0
        let maxRow = max(
            (occupiedRows.max() ?? 0) + 1,
            snap?.row ?? 0,
            hit?.row ?? 0
        )

        var lines: [String] = []
        let evenColumns = configuration.columnCount

        lines.append(columnHeader(evenColumns: evenColumns, oddRow: false))

        for row in minRow...min(maxRow, configuration.maxRows - 1) {
            let cols = configuration.columnCount(forRow: row)
            let oddOffset = row.isMultiple(of: 2) ? "" : "  "
            var cells: [String] = []

            for col in 0..<cols {
                let position = GridPosition(row: row, col: col)
                cells.append(
                    cellSymbol(
                        at: position,
                        grid: grid,
                        incomingShot: incomingShot,
                        snap: snap,
                        matchGroup: matchGroup,
                        hit: hit
                    )
                )
            }

            lines.append("\(oddOffset)r\(row) \(cells.joined(separator: ""))")
            if row == minRow {
                lines.append("\(oddOffset)    \(columnIndices(count: cols, oddRow: !row.isMultiple(of: 2)))")
            }
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private static func cellSymbol(
        at position: GridPosition,
        grid: BubbleGrid,
        incomingShot: BubbleColor?,
        snap: GridPosition?,
        matchGroup: Set<GridPosition>,
        hit: GridPosition?
    ) -> String {
        if let bubble = grid.bubble(at: position) {
            let emoji = bubble.color.debugEmoji
            if matchGroup.contains(position) { return slot("💥\(emoji)") }
            if position == hit { return slot("\(emoji)🎯") }
            return slot(emoji)
        }

        if position == snap {
            let shot = incomingShot?.debugEmoji ?? "?"
            return slot("⭐\(shot)")
        }

        if position == hit { return slot("🎯·") }

        return slot("·")
    }

  /// Fixed-width cell so odd/even rows align like honeycomb.
    private static func slot(_ content: String) -> String {
        let padded = content.padding(toLength: 3, withPad: " ", startingAt: 0)
        return "\(padded) "
    }

    private static func columnHeader(evenColumns: Int, oddRow: Bool) -> String {
        let oddOffset = oddRow ? "  " : ""
        var labels: [String] = []
        for col in 0..<evenColumns {
            labels.append(slot("c\(col)"))
        }
        return "\(oddOffset)    \(labels.joined())"
    }

    private static func columnIndices(count: Int, oddRow: Bool) -> String {
        let oddOffset = oddRow ? "  " : ""
        var labels: [String] = []
        for col in 0..<count {
            labels.append(slot("\(col)"))
        }
        return "\(oddOffset)    \(labels.joined())"
    }

    private static func neighborLine(
        around position: GridPosition,
        grid: BubbleGrid,
        highlight: BubbleColor?
    ) -> String {
        let parts = grid.neighbors(of: position).map { neighbor -> String in
            let label = coord(neighbor)
            guard let bubble = grid.bubble(at: neighbor) else {
                return "\(label)=·"
            }
            let same = bubble.color == highlight ? "✓" : "×"
            return "\(label)=\(bubble.color.debugEmoji)\(same)"
        }
        return "     \(parts.joined(separator: "  "))"
    }

    private static func coord(_ position: GridPosition) -> String {
        "r\(position.row)c\(position.col)"
    }

    private static func describe(hit: ShotHit) -> String {
        switch hit.target {
        case .bubble(let position):
            return "куля \(coord(position))"
        case .ceiling:
            return "стеля"
        case .leftWall:
            return "ліва стіна"
        case .rightWall:
            return "права стіна"
        }
    }

    private static func formatPositions(_ positions: [GridPosition]) -> String {
        positions.map { coord($0) }.joined(separator: ", ")
    }

    private static func fmt(_ value: CGFloat) -> String {
        String(format: "%.1f", value)
    }

    private static func divider() -> String {
        String(repeating: "━", count: 48)
    }

    private static func printLegendIfNeeded() {
        guard !didPrintLegend else { return }
        didPrintLegend = true
        print(
            """
            📋 Легенда (як на екрані, odd-ряд зсунутий вправо):
               🔴Ruby 🟠Amber 🟢Lime 🔵Aqua 🟣Violet 🩷Rose · порожньо
               🔵🎯 = удар по цій кульці   ⭐🔵 = сюди ляже постріл
               💥🔵 = у групі вибуху      ✓/× у сусідах = той самий/інший колір
            """
        )
    }
}

extension BubbleColor {

    var debugEmoji: String {
        switch self {
        case .ruby: "🔴"
        case .amber: "🟠"
        case .lime: "🟢"
        case .aqua: "🔵"
        case .violet: "🟣"
        case .rose: "🩷"
        }
    }

    var debugName: String {
        switch self {
        case .ruby: "Ruby"
        case .amber: "Amber"
        case .lime: "Lime"
        case .aqua: "Aqua"
        case .violet: "Violet"
        case .rose: "Rose"
        }
    }
}

#endif
