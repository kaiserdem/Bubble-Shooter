//
//  SkillzAppCoordinator.swift
//  BubbleShooter
//
//  Owns the Skillz SDK delegate at app launch (AppDelegate). Forwards callbacks to GameViewController.
//

import UIKit

#if USE_SKILLZ_SDK

final class SkillzAppCoordinator: NSObject {

    static let shared = SkillzAppCoordinator()

    private weak var gameDelegate: SkillzGameDelegate?

    private override init() {
        super.init()
    }

    func attach(_ delegate: SkillzGameDelegate) {
        gameDelegate = delegate
    }

    func detach(_ delegate: SkillzGameDelegate) {
        guard let gameDelegate, gameDelegate === delegate as AnyObject else { return }
        self.gameDelegate = nil
    }
}

extension SkillzAppCoordinator: SkillzDelegate {

    func tournamentWillBegin(
        _ gameParameters: [AnyHashable: Any],
        with matchInfo: SKZMatchInfo
    ) {
        let context = SkillzSDKBridge.matchContext(from: gameParameters, matchInfo: matchInfo)
        gameDelegate?.tournamentWillBegin(matchContext: context)
    }

    func skillzWillExit() {
        gameDelegate?.skillzWillExit()
    }

    func preferredSkillzInterfaceOrientation() -> SkillzOrientation {
        gameDelegate?.preferredSkillzInterfaceOrientation() == .portrait
            ? SkillzOrientation(rawValue: 0)!
            : SkillzOrientation(rawValue: 1)!
    }
}

#endif
