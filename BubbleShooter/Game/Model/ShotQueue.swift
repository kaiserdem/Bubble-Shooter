//
//  ShotQueue.swift
//  BubbleShooter
//

import Foundation

struct ShotQueue: Equatable, Sendable {
    var current: Bubble
    var next: Bubble

    init(random: DeterministicRandom, colorCount: Int) {
        let palette = Array(BubbleColor.allCases.prefix(colorCount))
        precondition(!palette.isEmpty, "ShotQueue requires at least one color")

        current = Bubble(color: palette[random.nextInt(upperBound: palette.count)])
        next = Bubble(color: palette[random.nextInt(upperBound: palette.count)])
    }

    mutating func advance(random: DeterministicRandom, colorCount: Int) {
        let palette = Array(BubbleColor.allCases.prefix(colorCount))
        guard !palette.isEmpty else { return }

        current = next
        next = Bubble(color: palette[random.nextInt(upperBound: palette.count)])
    }
}
