//
//  GameScene.swift
//  BubbleShooter
//

import SpriteKit

final class GameScene: SKScene {

    // MARK: - Match State

    private(set) var matchContext: SkillzMatchContext?
    private(set) var grid: BubbleGrid?
    private(set) var gameplayParameters: MatchGameplayParameters?

    private var gridRenderer: GridRenderer?
    private var hudLabel: SKLabelNode?
    private var isLayoutReady = false

    // MARK: - Configuration

    func configure(with matchContext: SkillzMatchContext) {
        self.matchContext = matchContext
        let parameters = MatchGameplayParameters(matchContext: matchContext)
        gameplayParameters = parameters

        let random = DeterministicRandom(matchSeed: matchContext.matchSeed)
        grid = LevelGenerator.generate(random: random, parameters: parameters)

        if isLayoutReady {
            applyLayout()
        }
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = Theme.SK.backgroundDeep
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        isLayoutReady = true
        BubbleTextureCache.preload()
        applyLayout()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard isLayoutReady, size.width > 1, size.height > 1 else { return }
        guard oldSize != size else { return }
        applyLayout()
    }
}

// MARK: - Layout

private extension GameScene {

    func applyLayout() {
        guard let grid, let gameplayParameters, size.width > 1, size.height > 1 else { return }

        gridRenderer?.container.removeFromParent()

        let layout = HexLayout(
            sceneSize: size,
            columnCount: gameplayParameters.gridConfiguration.columnCount
        )
        let renderer = GridRenderer(
            layout: layout,
            configuration: gameplayParameters.gridConfiguration
        )
        renderer.render(grid: grid)
        addChild(renderer.container)
        gridRenderer = renderer

        updateHUD(grid: grid, parameters: gameplayParameters)
    }

    func updateHUD(grid: BubbleGrid, parameters: MatchGameplayParameters) {
        hudLabel?.removeFromParent()

        let seed = matchContext?.matchSeed ?? "—"
        let label = SKLabelNode(fontNamed: Theme.Typography.skBody())
        label.text = "\(grid.occupiedPositions.count) bubbles · seed: \(seed)"
        label.fontSize = 13
        label.fontColor = Theme.SK.textPrimary.withAlphaComponent(0.75)
        label.position = CGPoint(x: 0, y: -size.height / 2 + 48)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 100
        addChild(label)
        hudLabel = label
    }
}
