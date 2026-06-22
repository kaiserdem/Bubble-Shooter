//
//  MatchGameplayParameters.swift
//  BubbleShooter
//

import Foundation

struct MatchGameplayParameters: Equatable, Sendable {

    let timeLimitSeconds: Int
    let colorCount: Int
    let initialRows: Int
    let gridConfiguration: GridConfiguration

    static let `default` = MatchGameplayParameters(
        timeLimitSeconds: 120,
        colorCount: 6,
        initialRows: 5,
        gridConfiguration: .default
    )

    init(
        timeLimitSeconds: Int,
        colorCount: Int,
        initialRows: Int,
        gridConfiguration: GridConfiguration
    ) {
        self.timeLimitSeconds = timeLimitSeconds
        self.colorCount = colorCount
        self.initialRows = initialRows
        self.gridConfiguration = gridConfiguration
    }

    init(matchContext: SkillzMatchContext) {
        let params = matchContext.gameParameters
        timeLimitSeconds = Self.parseInt(params["TimeLimit"], default: 120, range: 30...600)
        colorCount = Self.parseInt(params["ColorCount"], default: 6, range: 3...6)
        initialRows = Self.parseInt(params["InitialRows"], default: 5, range: 3...10)
        gridConfiguration = .default
    }

    private static func parseInt(_ value: String?, default defaultValue: Int, range: ClosedRange<Int>) -> Int {
        guard let value, let parsed = Int(value) else { return defaultValue }
        return min(max(parsed, range.lowerBound), range.upperBound)
    }
}
