//
//  SkillzSDKBridge.swift
//  BubbleShooter
//
//  Enabled via `USE_SKILLZ_SDK` in Build Settings → Active Compilation Conditions.
//  Skillz APIs are exposed through `SkillzBridgingHeader.h` (no Swift `import Skillz`).
//

import UIKit

#if USE_SKILLZ_SDK

/// Bridges native Skillz SDK calls into our game layer.
enum SkillzSDKBridge {

    static func initialize(
        gameID: String,
        environment: AppSkillzEnvironment,
        delegate: SkillzDelegate
    ) {
        let skillzEnvironment = SkillzEnvironment(
            rawValue: environment == .sandbox ? 1 : 0
        )!

        Skillz.skillzInstance().initWithGameId(
            gameID,
            for: delegate,
            with: skillzEnvironment,
            allowExit: true
        )

        #if DEBUG
        print("[Skillz] SDK initialized — gameID=\(gameID), environment=\(environment.rawValue), bundle=\(Bundle.main.bundleIdentifier ?? "nil")")
        #endif
    }

    static func launchSkillz() {
        Skillz.skillzInstance().launch()
    }

    static func returnToSkillz(completion: @escaping () -> Void) {
        Skillz.skillzInstance().returnToSkillz(completion: completion)
    }

    static func matchContext(
        from gameParameters: [AnyHashable: Any]?,
        matchInfo: SKZMatchInfo
    ) -> SkillzMatchContext {
        let matchID = matchInfo.id.uint64Value
        let parameters = (gameParameters as? [String: String]) ?? [:]

        return SkillzMatchContext(
            matchID: matchID,
            matchSeed: String(matchID),
            gameParameters: parameters,
            isSynchronous: matchInfo.isSynchronous
        )
    }

    static func updateCurrentScore(_ score: Int, matchID: UInt64? = nil) {
        let scoreNumber = NSNumber(value: score)
        if let matchID {
            Skillz.skillzInstance().updatePlayersCurrentScore(
                scoreNumber,
                withMatchId: NSNumber(value: matchID)
            )
        } else {
            Skillz.skillzInstance().updatePlayersCurrentScore(scoreNumber)
        }

        #if DEBUG
        print("[Skillz] updateCurrentScore=\(score), matchID=\(matchID.map(String.init) ?? "active")")
        #endif
    }

    static func displayTournamentResults(
        score: Int,
        matchID: UInt64? = nil,
        completion: @escaping () -> Void
    ) {
        let scoreNumber = NSNumber(value: score)

        #if DEBUG
        print("[Skillz] displayTournamentResults score=\(score), matchID=\(matchID.map(String.init) ?? "active")")
        #endif

        if let matchID {
            Skillz.skillzInstance().displayTournamentResults(
                withScore: scoreNumber,
                withMatchId: NSNumber(value: matchID),
                withCompletion: completion
            )
        } else {
            Skillz.skillzInstance().displayTournamentResults(
                withScore: scoreNumber,
                withCompletion: completion
            )
        }
    }
}

#endif
