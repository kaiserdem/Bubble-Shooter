//
//  HapticsPlayer.swift
//  BubbleShooter
//

import UIKit

/// Light tactile feedback — respects `GameSettings.isHapticsEnabled`.
enum HapticsPlayer {

    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)

    static func playLight() {
        guard GameSettings.isHapticsEnabled else { return }
        lightImpact.prepare()
        if #available(iOS 13.0, *) {
            lightImpact.impactOccurred(intensity: 0.55)
        } else {
            lightImpact.impactOccurred()
        }
    }
}
