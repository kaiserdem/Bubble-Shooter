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

    private var random: DeterministicRandom?
    private var shotQueue: ShotQueue?
    private var hexLayout: HexLayout?

    private var gridRenderer: GridRenderer?
    private var cannonRenderer: CannonRenderer?
    private var aimGuide = AimGuideNode()
    private var aimController: AimController?
    private var hudLabel: SKLabelNode?

    private var isLayoutReady = false
    private var isShooting = false
    private var flyingBubble: BubbleNode?
    private var pendingShotPath: ShotPath?

    // MARK: - Configuration

    func configure(with matchContext: SkillzMatchContext) {
        self.matchContext = matchContext
        let parameters = MatchGameplayParameters(matchContext: matchContext)
        gameplayParameters = parameters

        let matchRandom = DeterministicRandom(matchSeed: matchContext.matchSeed)
        random = matchRandom
        grid = LevelGenerator.generate(random: matchRandom, parameters: parameters)
        shotQueue = ShotQueue(random: matchRandom, colorCount: parameters.colorCount)

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
        addChild(aimGuide)
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
        cannonRenderer?.removeFromParent()

        let layout = HexLayout(
            sceneSize: size,
            columnCount: gameplayParameters.gridConfiguration.columnCount
        )
        hexLayout = layout

        let renderer = GridRenderer(
            layout: layout,
            configuration: gameplayParameters.gridConfiguration
        )
        renderer.render(grid: grid)
        addChild(renderer.container)
        gridRenderer = renderer

        let cannonPosition = CGPoint(x: 0, y: -size.height / 2 + 112)
        let launchOrigin = CGPoint(
            x: cannonPosition.x,
            y: cannonPosition.y + layout.bubbleVisualDiameter * 0.55
        )
        let cannon = CannonRenderer(
            cannonPosition: cannonPosition,
            bubbleDiameter: layout.bubbleVisualDiameter
        )
        if let shotQueue {
            cannon.update(current: shotQueue.current, next: shotQueue.next)
        }
        addChild(cannon)
        cannonRenderer = cannon

        aimController = AimController(cannonPosition: launchOrigin)
        bringNodeToFront(aimGuide)

        updateHUD(grid: grid, parameters: gameplayParameters)
    }

    func playBounds(for layout: HexLayout) -> CGRect {
        let margin: CGFloat = 24
        let ceilingY = layout.topCenter.y + layout.bubbleVisualDiameter * 0.55
        return CGRect(
            x: -size.width / 2 + margin,
            y: -size.height / 2,
            width: size.width - margin * 2,
            height: ceilingY + size.height / 2
        )
    }

    func occupiedBubbleCenters(
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> [(position: GridPosition, center: CGPoint)] {
        grid.occupiedPositions.map { position in
            (position, layout.center(for: position, configuration: configuration))
        }
    }

    func updateHUD(grid: BubbleGrid, parameters: MatchGameplayParameters) {
        hudLabel?.removeFromParent()

        let seed = matchContext?.matchSeed ?? "—"
        let label = SKLabelNode(fontNamed: Theme.Typography.skBody())
        label.text = "\(grid.occupiedPositions.count) bubbles · aim & shoot · seed: \(seed)"
        label.fontSize = 13
        label.fontColor = Theme.SK.textPrimary.withAlphaComponent(0.75)
        label.position = CGPoint(x: 0, y: -size.height / 2 + 48)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 100
        addChild(label)
        hudLabel = label
    }

    func bringNodeToFront(_ node: SKNode) {
        node.removeFromParent()
        addChild(node)
    }
}

// MARK: - Aiming & Shooting

private extension GameScene {

    func updateAim(toward scenePoint: CGPoint) {
        guard !isShooting,
              let aimController,
              let layout = hexLayout,
              let grid,
              let gameplayParameters else { return }

        let configuration = gameplayParameters.gridConfiguration
        let path = simulatedPath(
            from: aimController.shotRay(toward: scenePoint),
            layout: layout,
            grid: grid,
            configuration: configuration
        )
        let previewPath = animationPath(
            for: path,
            grid: grid,
            layout: layout,
            configuration: configuration
        )
        aimGuide.update(path: previewPath)
    }

    func fireShot(toward scenePoint: CGPoint) {
        guard !isShooting,
              let aimController,
              let layout = hexLayout,
              let grid,
              let gameplayParameters,
              let shotQueue else { return }

        let configuration = gameplayParameters.gridConfiguration
        let path = simulatedPath(
            from: aimController.shotRay(toward: scenePoint),
            layout: layout,
            grid: grid,
            configuration: configuration
        )
        let animationPath = animationPath(
            for: path,
            grid: grid,
            layout: layout,
            configuration: configuration
        )

        isShooting = true
        aimGuide.update(path: nil)
        pendingShotPath = path

        let shotBubble = shotQueue.current
        cannonRenderer?.hideCurrentBubble()

        flyingBubble = FlyingBubbleNode.animate(
            bubble: shotBubble,
            diameter: layout.bubbleVisualDiameter,
            along: animationPath,
            in: self
        ) { [weak self] in
            guard let self else { return }
            self.finishShot(
                shotBubble: shotBubble,
                colorCount: gameplayParameters.colorCount
            )
        }
    }

    func animationPath(
        for path: ShotPath,
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> ShotPath {
        guard let snapPosition = SnapResolver.resolve(
            hit: path.hit,
            grid: grid,
            layout: layout,
            configuration: configuration
        ) else {
            return path
        }

        var points = path.points
        let snapCenter = layout.center(for: snapPosition, configuration: configuration)
        if points.isEmpty {
            points = [snapCenter]
        } else {
            points[points.count - 1] = snapCenter
        }
        return ShotPath(points: points, hit: path.hit)
    }

    func finishShot(
        shotBubble: Bubble,
        colorCount: Int
    ) {
        defer {
            pendingShotPath = nil
            flyingBubble?.removeFromParent()
            flyingBubble = nil
            isShooting = false
        }

        guard var grid,
              let path = pendingShotPath,
              let layout = hexLayout,
              let parameters = gameplayParameters else { return }

        let configuration = parameters.gridConfiguration

        if let snapPosition = SnapResolver.resolve(
            hit: path.hit,
            grid: grid,
            layout: layout,
            configuration: configuration
        ) {
            do {
                try grid.place(shotBubble, at: snapPosition)
                self.grid = grid
                gridRenderer?.render(grid: grid)
                updateHUD(grid: grid, parameters: parameters)
            } catch {
                // Keep playing even if placement fails unexpectedly.
            }
        }

        if var queue = shotQueue, let random {
            queue.advance(random: random, colorCount: colorCount)
            shotQueue = queue
            cannonRenderer?.update(current: queue.current, next: queue.next)
            cannonRenderer?.showCurrentBubble()
        }
    }

    func simulatedPath(
        from ray: ShotRay,
        layout: HexLayout,
        grid: BubbleGrid,
        configuration: GridConfiguration
    ) -> ShotPath {
        ShotSimulator.simulate(
            ray: ray,
            playBounds: playBounds(for: layout),
            occupiedBubbles: occupiedBubbleCenters(
                grid: grid,
                layout: layout,
                configuration: configuration
            ),
            bubbleRadius: layout.bubbleVisualDiameter / 2
        )
    }
}

// MARK: - Touch

extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateAim(toward: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateAim(toward: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        fireShot(toward: touch.location(in: self))
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        aimGuide.update(path: nil)
    }
}
