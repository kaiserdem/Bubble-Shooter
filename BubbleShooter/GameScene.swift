//
//  GameScene.swift
//  BubbleShooter
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {

    // MARK: - Match State

    private(set) var matchContext: SkillzMatchContext?
    private(set) var random: DeterministicRandom?

    private var lastUpdateTime: TimeInterval = 0
    private var debugLabel: SKLabelNode?

    // MARK: - Configuration

    func configure(with matchContext: SkillzMatchContext) {
        self.matchContext = matchContext
        random = DeterministicRandom(matchSeed: matchContext.matchSeed)
        setupPlaceholderUI()
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = Theme.SK.backgroundDeep
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        _ = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
    }
}

// MARK: - Placeholder UI (Step 1 verification)

private extension GameScene {

    func setupPlaceholderUI() {
        removeAllChildren()

        guard let matchContext, let random else { return }

        let title = makeLabel(
            text: "Match Ready",
            fontSize: 28,
            position: CGPoint(x: 0, y: size.height * 0.30)
        )

        let seedLabel = makeLabel(
            text: "Seed: \(matchContext.matchSeed)",
            fontSize: 16,
            position: CGPoint(x: 0, y: size.height * 0.18)
        )
        seedLabel.fontColor = Theme.SK.textPrimary.withAlphaComponent(0.65)

        let sampleValues = (0..<5).map { _ in random.nextInt(upperBound: 100) }
        let rngLabel = makeLabel(
            text: "RNG preview: \(sampleValues.map(String.init).joined(separator: ", "))",
            fontSize: 14,
            position: CGPoint(x: 0, y: size.height * 0.10)
        )
        rngLabel.fontColor = Theme.SK.accentCyan

        debugLabel = makeLabel(
            text: "Tap to roll next value",
            fontSize: 14,
            position: CGPoint(x: 0, y: -size.height * 0.30)
        )
        debugLabel?.fontColor = Theme.SK.textPrimary

        addChild(title)
        addChild(seedLabel)
        addChild(rngLabel)
        if let debugLabel {
            addChild(debugLabel)
        }
    }

    func makeLabel(text: String, fontSize: CGFloat, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Theme.Typography.skBody(fontSize))
        label.text = text
        label.fontSize = fontSize
        label.fontColor = Theme.SK.textPrimary
        label.position = position
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}

// MARK: - Touch (debug RNG roll)

extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let random else { return }
        let value = random.nextInt(upperBound: 100)
        debugLabel?.text = "Next RNG [0,100): \(value)"
    }
}
