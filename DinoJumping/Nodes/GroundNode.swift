import SpriteKit

final class GroundNode: SKShapeNode {
    init(width: CGFloat, height: CGFloat) {
        super.init()

        path = CGPath(
            rect: CGRect(
                x: -width / 2,
                y: -height / 2,
                width: width,
                height: height
            ),
            transform: nil
        )
        name = "ground"
        fillColor = SKColor(red: 0.16, green: 0.10, blue: 0.30, alpha: 1)
        strokeColor = SKColor(red: 0.67, green: 0.42, blue: 0.96, alpha: 1)
        lineWidth = 3

        physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: -width / 2, y: height / 2),
            to: CGPoint(x: width / 2, y: height / 2)
        )
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.ground
        physicsBody?.collisionBitMask = PhysicsCategory.player
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
