import Foundation
import SpriteKit
import UIKit

final class DinoGameScene: SKScene, SKPhysicsContactDelegate {
    private let player = PlayerNode()
    private var ground: GroundNode?
    private var sun: SKShapeNode?
    private var moon: SKShapeNode?
    private var clouds: [CloudNode] = []
    
    private var gameState: GameState = .ready
    var onGameStateChange: ((GameState) -> Void)?
    var onScoreChange: ((Int, Int) -> Void)?
    private var canJump = true
    private let jumpHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let landingHaptic = UIImpactFeedbackGenerator(style: .light)
    private var gameStartTime: TimeInterval?
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: "DinoJumping.highScore")
    private var gameSpeedMultiplier: CGFloat = 1
    private var nextGroundGapScore = 500
    private var isWaitingToCreateGroundGap = false
    private var groundContactCount = 0
    private let groundGapClearance: CGFloat = 560
    private let obstacleAfterGapClearance: CGFloat = 840
    private let groundGapExitPadding: CGFloat = 64
    private let groundGapScoreInterval = 120

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = GameViewTheme.spriteKitBackground()
        physicsWorld.gravity = CGVector(dx: 0, dy: -900)
        physicsWorld.contactDelegate = self
        jumpHaptic.prepare()
        landingHaptic.prepare()

        addMoon()
        addSun()
        addClouds()
        addGround()
        addPlayer()
    }

    private func addSun() {
        let sun = SKShapeNode(circleOfRadius: 28)
        sun.fillColor = SKColor(red: 1.0, green: 0.72, blue: 0.24, alpha: 1)
        sun.strokeColor = SKColor(red: 1.0, green: 0.91, blue: 0.55, alpha: 1)
        sun.lineWidth = 3
        sun.glowWidth = 8
        sun.position = CGPoint(x: size.width * 0.82, y: size.height * 0.78)
        sun.zPosition = -1
        addChild(sun)
        self.sun = sun

        updateSunPosition()
        run(
            .repeatForever(.sequence([
                .wait(forDuration: 1),
                .run { [weak self] in self?.updateSunPosition() }
            ])),
            withKey: "updateSunPosition"
        )
    }

    private func addMoon() {
        let moon = SKShapeNode(circleOfRadius: 28)
        moon.fillColor = SKColor(red: 0.88, green: 0.92, blue: 1.0, alpha: 1)
        moon.strokeColor = SKColor(red: 0.68, green: 0.76, blue: 0.94, alpha: 1)
        moon.lineWidth = 2
        moon.glowWidth = 5
        moon.zPosition = -1
        addChild(moon)
        self.moon = moon

        moon.run(
            .repeatForever(.rotate(byAngle: -.pi * 2, duration: 90)),
            withKey: "rotateMoon"
        )

        addMoonCrater(to: moon, position: CGPoint(x: -10, y: 8), radius: 6)
        addMoonCrater(to: moon, position: CGPoint(x: 11, y: -7), radius: 8)
        addMoonCrater(to: moon, position: CGPoint(x: 4, y: 17), radius: 3)
    }

    private func addMoonCrater(to moon: SKShapeNode, position: CGPoint, radius: CGFloat) {
        let crater = SKShapeNode(circleOfRadius: radius)
        crater.fillColor = SKColor(red: 0.66, green: 0.72, blue: 0.87, alpha: 0.55)
        crater.strokeColor = .clear
        crater.position = position
        moon.addChild(crater)
    }

    private func updateSunPosition() {
        backgroundColor = GameViewTheme.spriteKitBackground()

        let time = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        let hour = CGFloat(time.hour ?? 0)
            + CGFloat(time.minute ?? 0) / 60
            + CGFloat(time.second ?? 0) / 3_600
        let daylightProgress = min(max((hour - 6) / 12, 0), 1)

        sun?.position = CGPoint(
            x: size.width * (0.1 + 0.8 * daylightProgress),
            y: size.height * (0.28 + sin(daylightProgress * .pi) * 0.55)
        )
        sun?.isHidden = hour < 6 || hour >= 18

        let nightProgress = hour >= 18
            ? (hour - 18) / 12
            : (hour + 6) / 12
        moon?.position = CGPoint(
            x: size.width * (0.1 + 0.8 * nightProgress),
            y: size.height * (0.28 + sin(nightProgress * .pi) * 0.55)
        )
        let moonScale = min(0.5 + nightProgress, 1)
        moon?.setScale(moonScale)
        moon?.isHidden = hour >= 6 && hour < 18
    }

    private func addGround() {
        let terrainSheet = SKTexture(imageNamed: "Terrain")
        terrainSheet.filteringMode = .nearest

        // Terrain is a 17 × 5 sheet of 32-point tiles. Select its solid
        // grass-platform tile and let GroundNode repeat it across the floor.
        let terrainTile = SKTexture(
            rect: CGRect(
                x: 1.0 / 17.0,
                y: 0,
                width: 1.0 / 17.0,
                height: 1.0 / 5.0
            ),
            in: terrainSheet
        )
        terrainTile.filteringMode = .nearest

        // Third tile from the left on the bottom row: a marker before a gap.
        let preGapTile = SKTexture(
            rect: CGRect(
                x: 2.0 / 17.0,
                y: 0,
                width: 1.0 / 17.0,
                height: 1.0 / 5.0
            ),
            in: terrainSheet
        )
        preGapTile.filteringMode = .nearest

        // First tile from the left on the bottom row: terrain after a gap.
        let postGapTile = SKTexture(
            rect: CGRect(
                x: 0,
                y: 0,
                width: 1.0 / 17.0,
                height: 1.0 / 5.0
            ),
            in: terrainSheet
        )
        postGapTile.filteringMode = .nearest

        let ground = GroundNode(
            width: size.width * 2,
            height: 72,
            terrainTexture: terrainTile,
            preGapTexture: preGapTile,
            postGapTexture: postGapTile
        )
        ground.position = CGPoint(x: size.width / 2, y: 36)
        addChild(ground)
        self.ground = ground
    }

    private func addClouds() {
        let cloudAssets = (1...7).map { String(format: "Clouds_%02d", $0) }.shuffled()
        let lanes: [CGFloat] = [0.08, 0.31, 0.54, 0.77, 1.02, 1.27, 1.52]
        let heights: [CGFloat] = [0.88, 0.70, 0.82, 0.63, 0.91, 0.75, 0.85].shuffled()

        clouds = zip(lanes, heights).enumerated().map { index, layout in
            let (lane, height) = layout
            let width = CGFloat.random(in: 190...280)
            let cloud = CloudNode(
                assetName: cloudAssets[index],
                size: CGSize(width: width, height: width * CloudNode.aspectRatio),
                position: CGPoint(x: size.width * lane, y: size.height * height),
                opacity: CGFloat.random(in: 0.40...0.60)
            )
            addChild(cloud)
            return cloud
        }
    }

    // Perubahan fix: scroll tile visual, tetapi physics ground tidak ikut bergerak.
    private func startGroundMovement() {
        let obstacleSpeed = (size.width + 100) / 3
        ground?.startScrolling(speed: obstacleSpeed * gameSpeedMultiplier)
        clouds.forEach {
            $0.startScrolling(speed: obstacleSpeed * gameSpeedMultiplier * 0.18, sceneWidth: size.width)
        }
    }

    // Perubahan fix: kembalikan posisi tile tanpa mengubah physics ground.
    private func resetGround() {
        removeAction(forKey: "restoreGroundGap")
        ground?.resetScrolling()
        ground?.speed = 1
        clouds.forEach {
            $0.resetScrolling()
            $0.speed = 1
        }
    }

    private func addObstacle() {
        removeAction(forKey: "spawnObstacle")
        spawnObstacle()
        scheduleNextObstacle()
    }

    private func scheduleNextObstacle() {
        let wait = SKAction.wait(forDuration: ObstacleNode.nextSpawnDelay())
        let schedule = SKAction.run { [weak self] in
            guard let self, self.gameState == .playing else { return }
            self.spawnObstacle()
            self.scheduleNextObstacle()
        }
        run(.sequence([wait, schedule]), withKey: "spawnObstacle")
    }

    private func resumeObstacleSpawning(after delay: TimeInterval) {
        let resume = SKAction.run { [weak self] in
            guard let self, self.gameState == .playing else { return }
            self.spawnObstacle()
            self.scheduleNextObstacle()
        }
        run(.sequence([.wait(forDuration: delay), resume]), withKey: "spawnObstacle")
    }

    private func createGroundGapWhenClear() {
        guard isWaitingToCreateGroundGap else { return }

        var hasObstacleTooClose = false
        enumerateChildNodes(withName: "obstacle") { node, _ in
            if node.position.x > self.size.width - self.groundGapClearance {
                hasObstacleTooClose = true
            }
        }
        guard !hasObstacleTooClose else { return }

        ground?.createGapAtRightEdge(sceneWidth: size.width)
        nextGroundGapScore = score + groundGapScoreInterval
        isWaitingToCreateGroundGap = false

        let scrollSpeed = (size.width + 100) / 3 * gameSpeedMultiplier
        restoreGroundGap(after: TimeInterval((size.width + groundGapExitPadding) / scrollSpeed))
        resumeObstacleSpawning(after: TimeInterval(obstacleAfterGapClearance / scrollSpeed))
    }

    private func restoreGroundGap(after delay: TimeInterval) {
        let restore = SKAction.run { [weak self] in
            self?.ground?.restoreGap()
        }
        run(.sequence([.wait(forDuration: delay), restore]), withKey: "restoreGroundGap")
    }

    private func spawnObstacle() {
        guard gameState == .playing else { return }

        let obstacle = ObstacleNode()
        obstacle.position = CGPoint(x: size.width + 50, y: 122)
        addChild(obstacle)

        obstacle.run(.sequence([
            .moveTo(x: -50, duration: 3 / gameSpeedMultiplier),
            .removeFromParent()
        ]))
    }

    private func addPlayer() {
        guard player.parent == nil else { return }

        player.position = CGPoint(x: size.width * 0.18, y: 105)
        addChild(player)
    }

    func startGame() {
        gameState = .playing
        onGameStateChange?(.playing)

        score = 0
        gameStartTime = nil
        gameSpeedMultiplier = 1
        nextGroundGapScore = 500
        isWaitingToCreateGroundGap = false
        groundContactCount = 0
        publishScore()
        canJump = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero
        player.startRunningAnimation(speedMultiplier: gameSpeedMultiplier)

        startGroundMovement()
        addObstacle()
    }

    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }

        if gameStartTime == nil {
            gameStartTime = currentTime
        }

        guard let gameStartTime else { return }
        if player.position.y < -80 {
            showGameOver()
            return
        }
        let updatedScore = Int((currentTime - gameStartTime) * 10)
        guard updatedScore > score else { return }

        score = updatedScore
        if score >= 1000, gameSpeedMultiplier == 1 {
            gameSpeedMultiplier = 1.25
            player.startRunningAnimation(speedMultiplier: gameSpeedMultiplier)
            ground?.speed = gameSpeedMultiplier
            clouds.forEach { $0.speed = gameSpeedMultiplier }
            enumerateChildNodes(withName: "obstacle") { node, _ in
                node.speed = self.gameSpeedMultiplier
            }
        }
        if score >= nextGroundGapScore {
            if !isWaitingToCreateGroundGap {
                // Do not introduce a new obstacle while reserving a safe gap.
                removeAction(forKey: "spawnObstacle")
                isWaitingToCreateGroundGap = true
            }
            createGroundGapWhenClear()
        }
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "DinoJumping.highScore")
        }
        publishScore()
    }

    func publishScore() {
        onScoreChange?(score, highScore)
    }

    func jump() {
        guard gameState == .playing,
              canJump,
              player.action(forKey: "jump") == nil else { return }

        canJump = false
        jumpHaptic.impactOccurred()
        jumpHaptic.prepare()

        let groundY = player.position.y
        let jumpHeight: CGFloat = 150

        player.physicsBody?.isDynamic = false

        let jump = SKAction.customAction(withDuration: 0.9) { node, elapsedTime in
            let progress = min(max(elapsedTime / 0.9, 0), 1)
            let arc = 4 * progress * (1 - progress)
            node.position.y = groundY + jumpHeight * arc
        }

        let resumePhysics = SKAction.run { [weak self] in
            self?.player.position.y = groundY
            self?.player.physicsBody?.isDynamic = true
            self?.landingHaptic.impactOccurred()
            self?.landingHaptic.prepare()
        }

        player.run(.sequence([jump, resumePhysics]), withKey: "jump")
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]

        if names.contains("ground") {
            groundContactCount += 1
            canJump = true
        }

        if names.contains("obstacle") {
            showGameOver()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]

        if names.contains("ground") {
            groundContactCount = max(groundContactCount - 1, 0)
            canJump = groundContactCount > 0
        }
    }
    
    private func showGameOver() {
        guard gameState == .playing else { return }

        gameState = .gameOver
        onGameStateChange?(.gameOver)
        gameStartTime = nil
        publishScore()

        removeAction(forKey: "spawnObstacle")
        removeAction(forKey: "restoreGroundGap")
        ground?.stopScrolling()
        clouds.forEach { $0.stopScrolling() }

        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeAllActions()
        }

        player.removeAction(forKey: "running")
        player.removeAction(forKey: "jump")
        player.physicsBody?.isDynamic = false
        player.physicsBody?.velocity = .zero
    }
    
    func restartGame() {
        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeFromParent()
        }

        player.removeAction(forKey: "jump")
        player.position = CGPoint(x: size.width * 0.18, y: 105)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero
        player.colorBlendFactor = 0

        resetGround()
        startGame()
    }
}
