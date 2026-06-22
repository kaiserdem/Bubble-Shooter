//
//  MockSkillzService.swift
//  BubbleShooter
//

import Foundation

/// Local sandbox substitute when the Skillz SDK is not linked.
final class MockSkillzService: SkillzProviding {

    static let shared = MockSkillzService()

    private(set) var isMatchInProgress = false
    private weak var delegate: SkillzGameDelegate?

    private init() {}

    func initialize(
        gameID: String,
        environment: AppSkillzEnvironment,
        delegate: SkillzGameDelegate
    ) {
        self.delegate = delegate
        #if DEBUG
        print("[MockSkillz] Initialized gameID=\(gameID) environment=\(environment.rawValue)")
        #endif
    }

    func launchSkillz() {
        #if DEBUG
        print("[MockSkillz] launchSkillz() — Skillz UI is mocked in sandbox builds.")
        #endif
    }

    /// Simulates Skillz calling `tournamentWillBegin` after a player joins a tournament.
    func simulateTournamentStart(
        matchID: UInt64 = 42_001,
        matchSeed: String = "sandbox-match-seed-42001",
        gameParameters: [String: String] = ["TimeLimit": "120"],
        isSynchronous: Bool = false
    ) {
        isMatchInProgress = true
        let context = SkillzMatchContext(
            matchID: matchID,
            matchSeed: matchSeed,
            gameParameters: gameParameters,
            isSynchronous: isSynchronous
        )
        delegate?.tournamentWillBegin(matchContext: context)
    }

    func simulateSkillzExit() {
        isMatchInProgress = false
        delegate?.skillzWillExit()
    }
}
