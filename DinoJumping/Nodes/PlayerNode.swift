import SpriteKit

final class PlayerNode: SKSpriteNode {
    private static let frameCount = 8
    private static let frameSize = CGSize(width: 1.0 / CGFloat(frameCount), height: 1.0)


    init() {
        let initialTexture = PlayerNode.texture(forFrame: 0)
        super.init(texture: initialTexture, color: .clear, size: CGSize(width: 88, height: 88))

        name = "player"
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 78))
        physicsBody?.isDynamic = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle
        physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        physicsBody?.usesPreciseCollisionDetection = true

        startRunningAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private static func texture(forFrame frame: Int) -> SKTexture {
        let normalizedFrame = CGFloat(frame) / CGFloat(frameCount)
        let rect = CGRect(
            x: normalizedFrame,
            y: 0,
            width: frameSize.width,
            height: frameSize.height
        )
        return SKTexture(rect: rect, in: SKTexture(imageNamed: "dino"))
    }

    func startRunningAnimation() {
        let frames = (0..<Self.frameCount).map { Self.texture(forFrame: $0) }
        let animation = SKAction.animate(with: frames, timePerFrame: 0.12, resize: false, restore: false)
        run(.repeatForever(animation), withKey: "running")
    }
}
