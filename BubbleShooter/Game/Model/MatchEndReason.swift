//
//  MatchEndReason.swift
//  BubbleShooter
//

import Foundation

enum MatchEndReason: Equatable, Sendable {
    case timeUp
    case dangerLine
    case boardCleared
    case forfeit
}
