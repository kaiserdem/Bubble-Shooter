//
//  SkillzGameDelegate.swift
//  BubbleShooter
//
//  Abstraction over the native Skillz SDK delegate (`SkillzDelegate`).
//  GameViewController conforms to this protocol and bridges to the SDK when linked.
//

import UIKit

enum AppSkillzEnvironment: String {
    case sandbox
    case production
}

/// Contract mirrored from Skillz iOS SDK delegate callbacks.
protocol SkillzGameDelegate: AnyObject {
    func tournamentWillBegin(matchContext: SkillzMatchContext)
    func skillzWillExit()
    func progressionRoomWillEnter()
    func preferredSkillzInterfaceOrientation() -> UIInterfaceOrientationMask
}

extension SkillzGameDelegate {
    func progressionRoomWillEnter() {}
    func preferredSkillzInterfaceOrientation() -> UIInterfaceOrientationMask {
        .portrait
    }
}
