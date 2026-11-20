import SpriteKit

final class DinoGameScene: SKScene, SKPhysicsContactDelegate {
    private let player = PlayerNode()
    private var canJump = true
    private var isGameOver = false

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
        addObstacle()
        addPlayer()
    }

    private func addGround() {
        let ground = GroundNode(width: size.width * 2, height: 72)
        ground.position = CGPoint(x: size.width / 2, y: 36)
        addChild(ground)
    }

    private func addObstacle() {
        let obstacle = ObstacleNode()
        obstacle.position = CGPoint(x: size.width * 0.72, y: 110)
        addChild(obstacle)
    }

    private func addPlayer() {
        guard player.parent == nil else { return }

        player.position = CGPoint(x: size.width * 0.18, y: 111)
        addChild(player)
    }

    func startGame() {
        isGameOver = false
        canJump = true
        isPaused = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jump()
    }

    func jump() {
        guard !isGameOver, player.action(forKey: "jump") == nil else { return }

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
            isGameOver = true
            player.removeAction(forKey: "running")
            player.color = .white
            player.colorBlendFactor = 0.5
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]

        if names.contains("ground") {
            canJump = false
        }
    }
}
