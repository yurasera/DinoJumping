import SpriteKit

final class ObstacleNode: SKSpriteNode {
    static func nextSpawnDelay() -> TimeInterval {
        .random(in: 1.5...3.2)
    }

    init() {
        let frameNames = Bool.random()
            ? ["sawit", "sawit2"]
            : ["sawit3", "sawit4", "sawit5"]
        let frames = frameNames.map(SKTexture.init(imageNamed:))
        frames.forEach { $0.filteringMode = .nearest }

        super.init(
            texture: frames[0],
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

        run(
            .repeatForever(.animate(with: frames, timePerFrame: 0.38)),
            withKey: "animateObstacle"
        )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
