//
//  SkillzSDKBridge.swift
//  BubbleShooter
//
//  Uncomment `USE_SKILLZ_SDK` in Build Settings → Swift Compiler - Custom Flags
//  after adding the Skillz.framework and bridging header.
//

import UIKit

#if USE_SKILLZ_SDK
import Skillz

/// Bridges native `SkillzDelegate` callbacks into our `SkillzGameDelegate` abstraction.
enum SkillzSDKBridge {

    static func initialize(
        gameID: String,
        environment: AppSkillzEnvironment,
        delegate: SkillzGameDelegate
    ) {
        let skillzEnvironment: SkillzEnvironment = switch environment {
        case .sandbox: .sandbox
        case .production: .production
        }

        Skillz.skillzInstance().initWithGameId(
            gameID,
            for: delegate as! SkillzDelegate,
            with: skillzEnvironment,
            allowExit: true
        )
    }

    static func launchSkillz() {
        Skillz.skillzInstance().launchSkillz()
    }

    static func matchContext(from gameParameters: [AnyHashable: Any]?) -> SkillzMatchContext {
        let matchInfo = Skillz.skillzInstance().getMatchInfo()
        let matchID = UInt64(matchInfo?.id ?? 0)
        let parameters = (gameParameters as? [String: String]) ?? [:]

        return SkillzMatchContext(
            matchID: matchID,
            matchSeed: String(matchID),
            gameParameters: parameters,
            isSynchronous: matchInfo?.isSynchronous ?? false
        )
    }
}

extension GameViewController: SkillzDelegate {

    func tournamentWillBegin(withGameParameters gameParameters: [AnyHashable: Any]!) {
        let context = SkillzSDKBridge.matchContext(from: gameParameters)
        tournamentWillBegin(matchContext: context)
    }

    func preferredSkillzInterfaceOrientation() -> SkillzOrientation {
        switch preferredSkillzInterfaceOrientation() {
        case .portrait:
            return .portrait
        case .landscapeLeft, .landscapeRight:
            return .landscape
        default:
            return .portrait
        }
    }
}
#endif
