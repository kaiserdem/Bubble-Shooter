//
//  GameSceneHUDDelegate.swift
//  BubbleShooter
//

import Foundation

/// Thin bridge between gameplay (`GameScene`) and UIKit HUD overlays.
protocol GameSceneHUDDelegate: AnyObject {

    func gameScene(_ scene: GameScene, didUpdateHUD state: MatchHUDState)
    func gameSceneDidRequestMatchEnd(_ scene: GameScene, results: MatchResultsState)
}
