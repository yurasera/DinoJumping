import SpriteKit

final class DinoGameScene: SKScene {
    private let player = PlayerNode()

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
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

        player.position = CGPoint(x: size.width * 0.18, y: size.height * 0.22)
        addChild(player)
    }
}
