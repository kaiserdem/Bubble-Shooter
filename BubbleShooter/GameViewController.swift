//
//  GameViewController.swift
//  BubbleShooter
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    // MARK: - Configuration

    private enum Config {
        static let skillzGameID = "YOUR_SKILLZ_GAME_ID"
        static let skillzEnvironment: AppSkillzEnvironment = .sandbox
    }

    // MARK: - State

    private var skillzService: SkillzProviding = MockSkillzService.shared
    private var gameScene: GameScene?
    private var lobbyView: SandboxLobbyView?
    #if DEBUG
    private var designPreviewController: DesignPreviewViewController?
    #endif

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSpriteKitView()
        configureSkillz()
        showSandboxLobbyIfNeeded()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

// MARK: - SkillzGameDelegate

extension GameViewController: SkillzGameDelegate {

    func tournamentWillBegin(matchContext: SkillzMatchContext) {
        hideSandboxLobby()
        presentGameScene(with: matchContext)
    }

    func skillzWillExit() {
        gameScene?.removeFromParent()
        gameScene = nil
        showSandboxLobbyIfNeeded()
    }

    func preferredSkillzInterfaceOrientation() -> UIInterfaceOrientationMask {
        .portrait
    }
}

// MARK: - Scene Presentation

private extension GameViewController {

    func configureSpriteKitView() {
        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #else
        skView.showsFPS = false
        skView.showsNodeCount = false
        #endif
    }

    func configureSkillz() {
        #if USE_SKILLZ_SDK
        SkillzSDKBridge.initialize(
            gameID: Config.skillzGameID,
            environment: Config.skillzEnvironment,
            delegate: self
        )
        #else
        skillzService.initialize(
            gameID: Config.skillzGameID,
            environment: Config.skillzEnvironment,
            delegate: self
        )
        #endif
    }

    func presentGameScene(with matchContext: SkillzMatchContext) {
        guard let skView = view as? SKView else { return }

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.configure(with: matchContext)

        gameScene = scene
        skView.presentScene(scene, transition: .crossFade(withDuration: 0.35))
    }

    func showSandboxLobbyIfNeeded() {
        #if DEBUG
        guard lobbyView == nil else { return }

        let lobby = SandboxLobbyView()
        lobby.onLaunchSkillz = { [weak self] in
            #if USE_SKILLZ_SDK
            SkillzSDKBridge.launchSkillz()
            #else
            self?.skillzService.launchSkillz()
            #endif
        }
        lobby.onStartSandboxMatch = { [weak self] in
            MockSkillzService.shared.simulateTournamentStart()
        }
        lobby.onStartDeterminismTest = { [weak self] in
            MockSkillzService.shared.simulateTournamentStart(
                matchID: 99_999,
                matchSeed: "determinism-test-seed"
            )
        }
        lobby.onOpenDesignPreview = { [weak self] in
            self?.showDesignPreview()
        }

        lobby.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lobby)
        NSLayoutConstraint.activate([
            lobby.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lobby.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lobby.topAnchor.constraint(equalTo: view.topAnchor),
            lobby.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        lobbyView = lobby
        #endif
    }

    func hideSandboxLobby() {
        lobbyView?.removeFromSuperview()
        lobbyView = nil
    }

    #if DEBUG
    func showDesignPreview() {
        guard designPreviewController == nil else { return }

        hideSandboxLobby()

        let preview = DesignPreviewViewController()
        preview.onClose = { [weak self] in
            self?.hideDesignPreview()
            self?.showSandboxLobbyIfNeeded()
        }

        addChild(preview)
        preview.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preview.view)
        NSLayoutConstraint.activate([
            preview.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            preview.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            preview.view.topAnchor.constraint(equalTo: view.topAnchor),
            preview.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        preview.didMove(toParent: self)
        designPreviewController = preview
    }

    func hideDesignPreview() {
        guard let preview = designPreviewController else { return }
        preview.willMove(toParent: nil)
        preview.view.removeFromSuperview()
        preview.removeFromParent()
        designPreviewController = nil
    }
    #endif
}
