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
    private var cannonPivot: CannonAimPivot?
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
        cannonPivot?.removeFromParent()

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
        let pivot = CannonAimPivot(
            cannonPosition: cannonPosition,
            bubbleDiameter: layout.bubbleVisualDiameter
        )
        if let shotQueue {
            pivot.cannon.update(current: shotQueue.current, next: shotQueue.next)
        }
        addChild(pivot)
        cannonPivot = pivot

        aimController = AimController(cannonPosition: cannonPosition)

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

    func updateHUD(
        grid: BubbleGrid,
        parameters: MatchGameplayParameters,
        lastPopCount: Int? = nil
    ) {
        hudLabel?.removeFromParent()

        let seed = matchContext?.matchSeed ?? "—"
        let popText = lastPopCount.map { "pop ×\($0)! · " } ?? ""
        let effectText = "\(BubblePopEffectPlayer.style.displayName) · "
        let label = SKLabelNode(fontNamed: Theme.Typography.skBody())
        label.text = "\(popText)\(effectText)\(grid.occupiedPositions.count) bubbles · aim & shoot · seed: \(seed)"
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

    func shotRay(toward scenePoint: CGPoint) -> ShotRay? {
        guard let aimController, let cannonPivot else { return nil }
        let aimAngle = aimController.clampedAngle(toward: scenePoint)
        cannonPivot.setAimAngle(aimAngle)
        return ShotRay(
            origin: cannonPivot.launchOrigin(in: self),
            direction: aimController.unitDirection(for: aimAngle)
        )
    }
}

// MARK: - Aiming & Shooting

private extension GameScene {

    func updateAim(toward scenePoint: CGPoint) {
        guard !isShooting,
              let layout = hexLayout,
              let grid,
              let gameplayParameters,
              let ray = shotRay(toward: scenePoint) else { return }

        let configuration = gameplayParameters.gridConfiguration
        let path = simulatedPath(
            from: ray,
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
        cannonPivot?.updateAimGuide(path: previewPath, in: self)
    }

    func fireShot(toward scenePoint: CGPoint) {
        guard !isShooting,
              let layout = hexLayout,
              let grid,
              let gameplayParameters,
              let shotQueue,
              let ray = shotRay(toward: scenePoint) else { return }

        let configuration = gameplayParameters.gridConfiguration
        let path = simulatedPath(
            from: ray,
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
        cannonPivot?.hideAimGuide()
        pendingShotPath = path

        let shotBubble = shotQueue.current
        cannonPivot?.cannon.hideCurrentBubble()

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
                resolveMatches(
                    at: snapPosition,
                    grid: &grid,
                    layout: layout,
                    configuration: configuration,
                    parameters: parameters
                )
            } catch {
                // Keep playing even if placement fails unexpectedly.
            }
        }

        if var queue = shotQueue, let random {
            queue.advance(random: random, colorCount: colorCount)
            shotQueue = queue
            cannonPivot?.cannon.update(current: queue.current, next: queue.next)
            cannonPivot?.cannon.showCurrentBubble()
        }
    }

    func resolveMatches(
        at position: GridPosition,
        grid: inout BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration,
        parameters: MatchGameplayParameters
    ) {
        var popCount: Int?

        if let group = MatchFinder.matchingGroup(including: position, in: grid) {
            popCount = group.count
            let specs = group.compactMap { gridPosition -> BubblePopSpec? in
                guard let bubble = grid.bubble(at: gridPosition) else { return nil }
                return BubblePopSpec(
                    center: layout.center(for: gridPosition, configuration: configuration),
                    color: bubble.color
                )
            }

            for gridPosition in group {
                try? grid.remove(at: gridPosition)
            }

            BubblePopEffectPlayer.playGroup(
                specs,
                bubbleDiameter: layout.bubbleVisualDiameter,
                in: self
            )
        }

        self.grid = grid
        gridRenderer?.render(grid: grid)
        updateHUD(grid: grid, parameters: parameters, lastPopCount: popCount)
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
        cannonPivot?.hideAimGuide()
    }
}
