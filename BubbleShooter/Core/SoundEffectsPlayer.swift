//
//  SoundEffectsPlayer.swift
//  BubbleShooter
//

import AudioToolbox

/// Short iOS system sounds for gameplay — respects `GameSettings.isSoundEnabled`.
/// Mixes with background music (`AVAudioSession` category `.ambient`).
enum SoundEffectsPlayer {

    /// Quiet keyboard-style tick — shot fired.
    private static let shot: SystemSoundID = 1104
    /// Soft bloom — matched group popped.
    private static let pop: SystemSoundID = 1114
    /// Gentle descent — detached cluster fell.
    private static let drop: SystemSoundID = 1117
    /// Subtle rise — danger zone entered.
    private static let warning: SystemSoundID = 1113
    /// Light chime — match finished.
    private static let matchEnd: SystemSoundID = 1115

    static func playShot() {
        play(shot)
    }

    static func playPop() {
        play(pop)
    }

    static func playDrop() {
        play(drop)
    }

    static func playWarning() {
        play(warning)
    }

    static func playMatchEnd() {
        play(matchEnd)
    }

    private static func play(_ soundID: SystemSoundID) {
        guard GameSettings.isSoundEnabled else { return }
        AudioServicesPlaySystemSound(soundID)
    }
}
