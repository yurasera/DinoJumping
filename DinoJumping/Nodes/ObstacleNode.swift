import SpriteKit

final class ObstacleNode: SKSpriteNode {
    init() {
        super.init(
            texture: SKTexture(imageNamed: "sawit"),
            color: .clear,
            size: CGSize(width: 100, height: 100)
        )
        name = "obstacle"
        zPosition = 1

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 100))
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.player
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
