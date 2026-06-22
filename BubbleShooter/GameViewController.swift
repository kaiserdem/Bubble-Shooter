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
}

// MARK: - Sandbox Lobby (DEBUG only)

#if DEBUG
private final class SandboxLobbyView: UIView {

    var onLaunchSkillz: (() -> Void)?
    var onStartSandboxMatch: (() -> Void)?
    var onStartDeterminismTest: (() -> Void)?

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let title = makeLabel("BubbleShooter — Sandbox")
        title.font = .boldSystemFont(ofSize: 22)

        let subtitle = makeLabel("Skillz SDK не підключено — використовуйте мок")
        subtitle.font = .preferredFont(forTextStyle: .footnote)
        subtitle.textColor = .secondaryLabel
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center

        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(subtitle)
        stackView.addArrangedSubview(makeButton("Launch Skillz (mock)", action: #selector(launchTapped)))
        stackView.addArrangedSubview(makeButton("Start Sandbox Match", action: #selector(matchTapped)))
        stackView.addArrangedSubview(makeButton("Determinism Test Match", action: #selector(determinismTapped)))

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .label
        return label
    }

    private func makeButton(_ title: String, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .systemBlue
        configuration.cornerStyle = .medium

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func launchTapped() { onLaunchSkillz?() }
    @objc private func matchTapped() { onStartSandboxMatch?() }
    @objc private func determinismTapped() { onStartDeterminismTest?() }
}
#endif
