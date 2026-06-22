//
//  BackgroundMusicPlayer.swift
//  BubbleShooter
//

import AVFoundation

/// Looped background music — respects `GameSettings.isMusicEnabled`.
final class BackgroundMusicPlayer {

    static let shared = BackgroundMusicPlayer()

    private var player: AVAudioPlayer?
    private var isPrepared = false

    private init() {}

    func prepareIfNeeded() {
        guard !isPrepared else { return }

        guard let url = Bundle.main.url(
            forResource: Theme.Asset.Music.background,
            withExtension: "mp3"
        ) else {
            #if DEBUG
            print("[Music] Missing \(Theme.Asset.Music.background).mp3 in app bundle")
            #endif
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            player = audioPlayer
            isPrepared = true
        } catch {
            #if DEBUG
            print("[Music] Failed to load background track:", error)
            #endif
        }
    }

    func playIfEnabled() {
        prepareIfNeeded()
        guard GameSettings.isMusicEnabled else {
            stop()
            return
        }
        player?.play()
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
    }

    func applyMusicSetting() {
        if GameSettings.isMusicEnabled {
            playIfEnabled()
        } else {
            stop()
        }
    }
}
