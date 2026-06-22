//
//  SkillzProviding.swift
//  BubbleShooter
//

import Foundation

/// Abstraction over the Skillz SDK for local development and testing.
protocol SkillzProviding: AnyObject {
    var isMatchInProgress: Bool { get }
    func initialize(gameID: String, environment: AppSkillzEnvironment, delegate: SkillzGameDelegate)
    func launchSkillz()
}
