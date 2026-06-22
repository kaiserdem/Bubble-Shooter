//
//  GameScene.swift
//  BubbleShooter
//

import SpriteKit

final class GameScene: SKScene {

    weak var hudDelegate: GameSceneHUDDelegate?

    // MARK: - Match State

    private(set) var matchContext: SkillzMatchContext?
    private(set) var grid: BubbleGrid?
    private(set) var gameplayParameters: MatchGameplayParameters?
    var matchScore = MatchScore()

    var matchTimer: MatchTimer?
    var isMatchActive = false
    var isMatchEnded = false
    var lastUpdateTime: TimeInterval = 0

    private var random: DeterministicRandom?
    var shotQueue: ShotQueue?
    var hexLayout: HexLayout?

    private var gridRenderer: GridRenderer?
    private var cannonPivot: CannonAimPivot?
    private var aimController: AimController?
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
        matchScore = MatchScore()

        if isLayoutReady {
            applyLayout()
        }
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isOpaque = false
        view.layer.isOpaque = false
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

    override func update(_ currentTime: TimeInterval) {
        tickMatch(currentTime: currentTime)
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

        let cannonPosition = CGPoint(x: 0, y: CannonRenderer.pivotY(sceneHeight: size.height))
        let pivot = CannonAimPivot(
            cannonPosition: cannonPosition,
            bubbleDiameter: layout.bubbleVisualDiameter
        )
        if let shotQueue {
            pivot.cannon.update(current: shotQueue.current)
        }
        addChild(pivot)
        cannonPivot = pivot

        aimController = AimController(cannonPosition: cannonPosition)

        if isMatchActive {
            publishHUD()
        }
    }

    func playBounds(for layout: HexLayout) -> CGRect {
        let margin = HexLayout.Metrics.horizontalEdgeInset
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
        guard isMatchActive, !isMatchEnded,
              !isShooting,
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
        let previewPath = path
        cannonPivot?.updateAimGuide(path: previewPath, in: self)
    }

    func fireShot(toward scenePoint: CGPoint) {
        guard isMatchActive, !isMatchEnded,
              !isShooting,
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
        let shotBubble = shotQueue.current
        let flightPath = visualFlightPath(from: path, layout: layout)

        if var queue = self.shotQueue, let random = self.random {
            queue.advance(random: random, colorCount: gameplayParameters.colorCount)
            self.shotQueue = queue
        }
        publishHUD()

        isShooting = true
        cannonPivot?.hideAimGuide()
        pendingShotPath = path

        cannonPivot?.cannon.beginShot()

        flyingBubble = FlyingBubbleNode.animate(
            bubble: shotBubble,
            diameter: layout.bubbleVisualDiameter,
            along: flightPath,
            in: self
        ) { [weak self] in
            guard let self else { return }
            self.finishShot(shotBubble: shotBubble)
        }
    }

    func finishShot(shotBubble: Bubble) {
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

        let snapAnalysis = SnapResolver.analyze(
            hit: path.hit,
            shotBubble: shotBubble,
            grid: grid,
            layout: layout,
            configuration: configuration
        )

        #if DEBUG
        GridDebugPrinter.logShot(
            hit: path.hit,
            shotBubble: shotBubble,
            grid: grid,
            configuration: configuration,
            analysis: snapAnalysis
        )
        #endif

        if let snapPosition = snapAnalysis.chosen {
            do {
                try grid.place(shotBubble, at: snapPosition)
                resolveTurn(
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

        if let queue = shotQueue {
            cannonPivot?.cannon.setCurrent(queue.current)
        }

        publishHUD()
    }

    func resolveTurn(
        at position: GridPosition,
        grid: inout BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration,
        parameters: MatchGameplayParameters
    ) {
        var lastPopCount: Int?
        var lastDropCount: Int?

        if let group = MatchFinder.matchingGroup(including: position, in: grid) {
            #if DEBUG
            GridDebugPrinter.logMatchResult(
                at: position,
                grid: grid,
                configuration: configuration,
                group: group
            )
            #endif

            lastPopCount = group.count
            matchScore.addPop(bubbleCount: group.count)
            let popSpecs = popSpecs(
                for: group,
                grid: grid,
                layout: layout,
                configuration: configuration
            )
            let popPoints = ScoreCalculator.popPoints(forBubbleCount: group.count)
            removeGroup(
                group,
                from: &grid,
                layout: layout,
                configuration: configuration,
                playPopEffect: true
            )
            ScoreFloater.play(points: popPoints, near: popSpecs, kind: .pop, in: self)
        } else {
            #if DEBUG
            GridDebugPrinter.logMatchResult(
                at: position,
                grid: grid,
                configuration: configuration,
                group: nil
            )
            #endif
        }

        let floating = ConnectivityChecker.floatingPositions(in: grid)
        if !floating.isEmpty {
            lastDropCount = floating.count
            matchScore.addDrop(bubbleCount: floating.count)
            let dropSpecs = popSpecs(
                for: floating,
                grid: grid,
                layout: layout,
                configuration: configuration
            )
            let dropPoints = ScoreCalculator.dropPoints(forBubbleCount: floating.count)
            removeGroup(
                floating,
                from: &grid,
                layout: layout,
                configuration: configuration,
                playPopEffect: false
            )
            ScoreFloater.play(points: dropPoints, near: dropSpecs, kind: .drop, in: self)
        }

        self.grid = grid
        gridRenderer?.render(grid: grid)
        evaluateMatchEndAfterTurn()
    }

    func popSpecs(
        for positions: [GridPosition],
        grid: BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration
    ) -> [BubblePopSpec] {
        positions.compactMap { gridPosition -> BubblePopSpec? in
            guard let bubble = grid.bubble(at: gridPosition) else { return nil }
            return BubblePopSpec(
                center: layout.center(for: gridPosition, configuration: configuration),
                color: bubble.color
            )
        }
    }

    func removeGroup(
        _ positions: [GridPosition],
        from grid: inout BubbleGrid,
        layout: HexLayout,
        configuration: GridConfiguration,
        playPopEffect: Bool
    ) {
        let specs = popSpecs(for: positions, grid: grid, layout: layout, configuration: configuration)

        for gridPosition in positions {
            try? grid.remove(at: gridPosition)
        }

        guard !specs.isEmpty else { return }

        if playPopEffect {
            BubblePopEffectPlayer.playGroup(
                specs,
                bubbleDiameter: layout.bubbleVisualDiameter,
                in: self
            )
        } else {
            BubbleDropEffect.playGroup(
                specs,
                bubbleDiameter: layout.bubbleVisualDiameter,
                in: self
            )
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
            bubbleRadius: layout.bubbleCollisionRadius
        )
    }

    /// Pulls the flight endpoint back so the sprite touches the target, not the inflated raycast shell.
    func visualFlightPath(from path: ShotPath, layout: HexLayout) -> ShotPath {
        guard path.points.count >= 2 else { return path }

        switch path.hit.target {
        case .bubble:
            break
        case .ceiling, .leftWall, .rightWall:
            return path
        }

        var points = path.points
        let before = points[points.count - 2]
        let hit = points[points.count - 1]
        let dx = hit.x - before.x
        let dy = hit.y - before.y
        let length = hypot(dx, dy)
        guard length > 0 else { return path }

        let collisionReach = layout.bubbleCollisionRadius * 2 + 1
        let visualReach = layout.bubbleVisualDiameter
        let pullBack = max(0, collisionReach - visualReach)
        guard pullBack > 0 else { return path }

        points[points.count - 1] = CGPoint(
            x: hit.x - dx / length * pullBack,
            y: hit.y - dy / length * pullBack
        )
        return ShotPath(points: points, hit: path.hit)
    }
}

// MARK: - Match lifecycle

extension GameScene {

    func beginMatch() {
        guard let parameters = gameplayParameters else { return }

        isMatchEnded = false
        isMatchActive = true
        lastUpdateTime = 0
        matchTimer = MatchTimer(durationSeconds: parameters.timeLimitSeconds)
        publishHUD()
    }

    func tickMatch(currentTime: TimeInterval) {
        guard isMatchActive, !isMatchEnded else { return }
        guard var timer = matchTimer else { return }

        let delta: TimeInterval
        if lastUpdateTime > 0 {
            delta = currentTime - lastUpdateTime
        } else {
            delta = 0
        }
        lastUpdateTime = currentTime

        guard delta > 0 else { return }

        if timer.advance(delta: delta) {
            matchTimer = timer
            publishHUD()

            if timer.isExpired {
                endMatch(reason: .timeUp)
            }
        }
    }

    func publishHUD() {
        guard let parameters = gameplayParameters,
              let layout = hexLayout,
              let grid,
              let shotQueue,
              let timer = matchTimer else { return }

        let configuration = parameters.gridConfiguration
        let dangerY = layout.dangerLineY(sceneHeight: size.height)
        let isDanger = DangerLineLogic.isWarningActive(
            grid: grid,
            layout: layout,
            configuration: configuration,
            dangerLineY: dangerY
        )

        let state = MatchHUDState(
            score: matchScore.total,
            timeRemainingSeconds: timer.remainingSeconds,
            nextBubble: shotQueue.next.color,
            currentBubble: shotQueue.current.color,
            isDangerActive: isDanger,
            canSwap: false
        )

        hudDelegate?.gameScene(self, didUpdateHUD: state)
    }

    func evaluateMatchEndAfterTurn() {
        guard isMatchActive, !isMatchEnded,
              let grid,
              let layout = hexLayout,
              let configuration = gameplayParameters?.gridConfiguration else { return }

        if grid.occupiedPositions.isEmpty {
            endMatch(reason: .boardCleared)
            return
        }

        let dangerY = layout.dangerLineY(sceneHeight: size.height)
        if DangerLineLogic.hasBubbleBelowLine(
            grid: grid,
            layout: layout,
            configuration: configuration,
            dangerLineY: dangerY
        ) {
            endMatch(reason: .dangerLine)
        }
    }

    func endMatch(reason: MatchEndReason) {
        guard !isMatchEnded else { return }

        isMatchEnded = true
        isMatchActive = false

        if reason == .timeUp, let timer = matchTimer {
            matchScore.setTimeBonus(remainingSeconds: timer.remainingSeconds)
        }

        let results = MatchResultsState(
            finalScore: matchScore.total,
            popPoints: matchScore.popPoints,
            dropPoints: matchScore.dropPoints,
            timeBonus: matchScore.timeBonusPoints,
            isNewBest: false,
            didClearBoard: reason == .boardCleared,
            didLoseOnDanger: reason == .dangerLine
        )

        publishHUD()
        hudDelegate?.gameSceneDidRequestMatchEnd(self, results: results)
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
