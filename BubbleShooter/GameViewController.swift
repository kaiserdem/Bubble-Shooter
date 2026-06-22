//
//  GameViewController.swift
//  BubbleShooter
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    // MARK: - Configuration

    private enum Config {
        static let skillzGameID = SkillzConfiguration.gameID
        static let skillzEnvironment = SkillzConfiguration.environment
    }

    // MARK: - State

    private var skillzService: SkillzProviding = MockSkillzService.shared
    var gameScene: GameScene?
    private var mainMenuView: MainMenuContainerView?
    private var matchLayoutView: MatchLayoutView?
    private var matchIntroOverlay: MatchIntroOverlayView?
    private var matchResultsView: MatchResultsView?
    private var activeMatchContext: SkillzMatchContext?
    private var pendingMatchResults: MatchResultsState?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Background.gradientBottom
        configureSkillz()
        BackgroundMusicPlayer.shared.playIfEnabled()
        showMainMenuIfNeeded()
    }

    deinit {
        #if USE_SKILLZ_SDK
        SkillzAppCoordinator.shared.detach(self)
        #endif
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
        presentGameScene(with: matchContext)
    }

    func skillzWillExit() {
        teardownMatchUI()
        BackgroundMusicPlayer.shared.playIfEnabled()
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
        SkillzAppCoordinator.shared.attach(self)
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
        if let menu = mainMenuView {
            containerView.insertSubview(layout, belowSubview: menu)
        } else {
            containerView.addSubview(layout)
        }
        NSLayoutConstraint.activate([
            layout.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            layout.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            layout.topAnchor.constraint(equalTo: containerView.topAnchor),
            layout.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        matchLayoutView = layout

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

        containerView.layoutIfNeeded()
        hideMainMenu()

        let sceneSize = layout.gameSKView.bounds.size
        guard sceneSize.width > 1, sceneSize.height > 1 else { return }

        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        scene.configure(with: matchContext)
        activeMatchContext = matchContext

        gameScene = scene
        scene.hudDelegate = self
        layout.gameSKView.presentScene(scene)
        scene.previewMatchHUD()

        results.onContinue = { [weak self] in
            guard let self, let results = self.pendingMatchResults else { return }
            self.matchResultsView?.dismiss { [weak self] in
                guard let self else { return }
                #if USE_SKILLZ_SDK
                SkillzSDKBridge.displayTournamentResults(score: results.finalScore) { [weak self] in
                    self?.teardownMatchUI()
                }
                #else
                MockSkillzService.shared.simulateSkillzExit()
                #endif
            }
        }

        #if DEBUG
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(handleHUDTripleTap))
        tripleTap.numberOfTapsRequired = 3
        layout.hudView.addGestureRecognizer(tripleTap)
        #endif

        intro.playCountdown { [weak self] in
            self?.gameScene?.beginMatch()
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
        activeMatchContext = nil
        pendingMatchResults = nil
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
        #if USE_SKILLZ_SDK
        SkillzSDKBridge.updateCurrentScore(state.score)
        #endif
    }

    func gameSceneDidRequestMatchEnd(_ scene: GameScene, results: MatchResultsState) {
        pendingMatchResults = results
        #if USE_SKILLZ_SDK
        SkillzSDKBridge.updateCurrentScore(results.finalScore)
        #endif
        matchResultsView?.present(with: results)
    }
}
