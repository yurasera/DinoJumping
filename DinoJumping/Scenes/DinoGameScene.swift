import Foundation
import SpriteKit

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
    private var gameStartTime: TimeInterval?
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: "DinoJumping.highScore")

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

        addMoon()
        addSun()
        addClouds()
        addGround()
        addPlayer()
    }

    private func addSun() {
        let sun = SKShapeNode(circleOfRadius: 42)
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

        let ground = GroundNode(
            width: size.width * 2,
            height: 72,
            terrainTexture: terrainTile
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
        ground?.startScrolling(speed: obstacleSpeed)
        clouds.forEach { $0.startScrolling(speed: obstacleSpeed * 0.18, sceneWidth: size.width) }
    }

    // Perubahan fix: kembalikan posisi tile tanpa mengubah physics ground.
    private func resetGround() {
        ground?.resetScrolling()
        clouds.forEach { $0.resetScrolling() }
    }

    private func addObstacle() {
        removeAction(forKey: "spawnObstacle")
        
        let spawn = SKAction.run { [weak self] in
            guard let self, self.gameState == .playing else { return }

            let obstacle = ObstacleNode()
            obstacle.position = CGPoint(
                x: self.size.width + 50,
                y: 122
            )

            self.addChild(obstacle)

            let move = SKAction.moveTo(
                x: -50,
                duration: 3
            )

            obstacle.run(.sequence([
                move,
                .removeFromParent()
            ]))
        }

        let wait = SKAction.wait(forDuration: 2)

        run(
            .repeatForever(.sequence([spawn, wait])),
            withKey: "spawnObstacle"
        )
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
        publishScore()
        canJump = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero
        player.startRunningAnimation()

        startGroundMovement()
        addObstacle()
    }

    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }

        if gameStartTime == nil {
            gameStartTime = currentTime
        }

        guard let gameStartTime else { return }
        let updatedScore = Int((currentTime - gameStartTime) * 10)
        guard updatedScore > score else { return }

        score = updatedScore
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "DinoJumping.highScore")
        }
        publishScore()
    }

    func publishScore() {
        onScoreChange?(score, highScore)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchedNodes = nodes(at: touch.location(in: self))

        if touchedNodes.contains(where: { $0.name == "startButton" }) {
            startGame()
            return
        }

        if touchedNodes.contains(where: { $0.name == "restartButton" }) {
            restartGame()
            return
        }

        if gameState == .playing {
            jump()
        }
    }

    func jump() {
        guard gameState == .playing,
              canJump,
              player.action(forKey: "jump") == nil else { return }

        canJump = false

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
            self?.canJump = true
        }

        player.run(.sequence([jump, resumePhysics]), withKey: "jump")
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]

        if names.contains("ground") {
            canJump = true
        }

        if names.contains("obstacle") {
            showGameOver()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]

        if names.contains("ground") {
            canJump = false
        }
    }
    
    private func showGameOver() {
        guard gameState == .playing else { return }

        gameState = .gameOver
        onGameStateChange?(.gameOver)
        gameStartTime = nil
        publishScore()

        removeAction(forKey: "spawnObstacle")
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
