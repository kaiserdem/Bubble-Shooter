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
    var gameScene: GameScene?
    private var mainMenuView: MainMenuContainerView?
    private var matchLayoutView: MatchLayoutView?
    private var matchIntroOverlay: MatchIntroOverlayView?
    private var matchResultsView: MatchResultsView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSkillz()
        showMainMenuIfNeeded()
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
        hideMainMenu()
        DispatchQueue.main.async { [weak self] in
            self?.presentGameScene(with: matchContext)
        }
    }

    func skillzWillExit() {
        teardownMatchUI()
        showMainMenuIfNeeded()
    }

    func preferredSkillzInterfaceOrientation() -> UIInterfaceOrientationMask {
        .portrait
    }
}

// MARK: - Scene Presentation

private extension GameViewController {

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
        guard let containerView = view else { return }

        let layout = MatchLayoutView()
        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.isHidden = true
        containerView.addSubview(layout)
        NSLayoutConstraint.activate([
            layout.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            layout.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            layout.topAnchor.constraint(equalTo: containerView.topAnchor),
            layout.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        matchLayoutView = layout

        containerView.layoutIfNeeded()
        let sceneSize = layout.gameSKView.bounds.size
        guard sceneSize.width > 1, sceneSize.height > 1 else { return }

        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        scene.configure(with: matchContext)

        gameScene = scene
        scene.hudDelegate = self
        layout.gameSKView.presentScene(scene, transition: .crossFade(withDuration: 0.35))
        setupMatchUI()
    }

    func setupMatchUI() {
        guard let containerView = view, let layout = matchLayoutView else { return }

        let intro = MatchIntroOverlayView()
        intro.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(intro)
        matchIntroOverlay = intro

        let results = MatchResultsView()
        results.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(results)
        matchResultsView = results

        NSLayoutConstraint.activate([
            intro.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            intro.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            intro.topAnchor.constraint(equalTo: containerView.topAnchor),
            intro.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            results.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            results.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            results.topAnchor.constraint(equalTo: containerView.topAnchor),
            results.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        results.onContinue = { [weak self] in
            self?.matchResultsView?.dismiss { [weak self] in
                MockSkillzService.shared.simulateSkillzExit()
            }
        }

        #if DEBUG
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(handleHUDTripleTap))
        tripleTap.numberOfTapsRequired = 3
        layout.hudView.addGestureRecognizer(tripleTap)
        #endif

        intro.playCountdown { [weak self] in
            self?.matchLayoutView?.isHidden = false
            self?.gameScene?.beginMatch()
            #if DEBUG
            // Triple-tap HUD still opens results preview.
            #endif
        }
    }

    func teardownMatchUI() {
        matchLayoutView?.gameSKView.presentScene(nil)
        matchLayoutView?.removeFromSuperview()
        matchIntroOverlay?.removeFromSuperview()
        matchResultsView?.dismiss(animated: false)
        matchResultsView?.removeFromSuperview()

        matchLayoutView = nil
        matchIntroOverlay = nil
        matchResultsView = nil
        gameScene = nil
    }

    #if DEBUG
    @objc func handleHUDTripleTap() {
        matchResultsView?.present(with: .preview)
    }
    #endif

    func showMainMenuIfNeeded() {
        guard mainMenuView == nil else { return }

        let menu = MainMenuContainerView()
        menu.onPlay = {
            #if USE_SKILLZ_SDK
            SkillzSDKBridge.launchSkillz()
            #else
            MockSkillzService.shared.simulateTournamentStart()
            #endif
        }

        view.addSubview(menu)
        NSLayoutConstraint.activate([
            menu.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menu.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menu.topAnchor.constraint(equalTo: view.topAnchor),
            menu.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        mainMenuView = menu
    }

    func hideMainMenu() {
        mainMenuView?.removeFromSuperview()
        mainMenuView = nil
    }
}

extension GameViewController: GameSceneHUDDelegate {

    func gameScene(_ scene: GameScene, didUpdateHUD state: MatchHUDState) {
        matchLayoutView?.update(with: state)
    }

    func gameSceneDidRequestMatchEnd(_ scene: GameScene, results: MatchResultsState) {
        matchResultsView?.present(with: results)
    }
}
