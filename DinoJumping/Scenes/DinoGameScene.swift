import SpriteKit

final class DinoGameScene: SKScene, SKPhysicsContactDelegate {
    private let player = PlayerNode()
    private let gameOverlay = GameOverlay()
    
    private var gameState: GameState = .ready
    private var canJump = true

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(
            red: 0.10,
            green: 0.06,
            blue: 0.22,
            alpha: 1
        )
        physicsWorld.gravity = CGVector(dx: 0, dy: -900)
        physicsWorld.contactDelegate = self

        addGround()
        addPlayer()
        
        gameOverlay.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        gameOverlay.zPosition = 100
        addChild(gameOverlay)

        gameOverlay.showStart()
    }

    private func addGround() {
        let ground = GroundNode(width: size.width * 2, height: 72)
        ground.position = CGPoint(x: size.width / 2, y: 36)
        addChild(ground)
    }

    private func addObstacle() {
        removeAction(forKey: "spawnObstacle")
        
        let spawn = SKAction.run { [weak self] in
            guard let self, self.gameState == .playing else { return }

            let obstacle = ObstacleNode()
            obstacle.position = CGPoint(
                x: self.size.width + 50,
                y: 110
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

        player.position = CGPoint(x: size.width * 0.18, y: 111)
        addChild(player)
    }

    func startGame() {
        gameState = .playing
        canJump = true

        gameOverlay.hide()

        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero

        player.startRunningAnimation()
        addObstacle()
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

        let resumePhysics = SKAction.run { [weak player] in
            player?.position.y = groundY
            player?.physicsBody?.isDynamic = true
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
    
    enum PhysicsCategory {
        static let player: UInt32 = 1 << 0
        static let ground: UInt32 = 1 << 1
        static let obstacle: UInt32 = 1 << 2
    }
    
    private func showGameOver() {
        guard gameState == .playing else { return }

        gameState = .gameOver

        removeAction(forKey: "spawnObstacle")

        player.removeAction(forKey: "running")
        player.removeAction(forKey: "jump")
        player.physicsBody?.isDynamic = false
        player.physicsBody?.velocity = .zero

        gameOverlay.showGameOver()
    }
    
    private func restartGame() {
        gameOverlay.hide()

        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeFromParent()
        }

        player.removeAction(forKey: "jump")
        
        player.position = CGPoint(x: size.width * 0.18, y: 111)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero

        player.colorBlendFactor = 0

        startGame()
    }
}
