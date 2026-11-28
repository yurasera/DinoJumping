import SpriteKit

final class FireballNode: SKNode {
    private let radius: CGFloat = 24

    override init() {
        super.init()

        name = "obstacle"
        zPosition = 2

        let outerGlow = SKShapeNode(circleOfRadius: radius * 1.35)
        outerGlow.fillColor = SKColor(red: 1.0, green: 0.18, blue: 0.02, alpha: 0.18)
        outerGlow.strokeColor = .clear
        outerGlow.glowWidth = 14
        addChild(outerGlow)

        let fireball = SKShapeNode(circleOfRadius: radius)
        fireball.fillColor = SKColor(red: 0.95, green: 0.12, blue: 0.02, alpha: 1)
        fireball.strokeColor = SKColor(red: 1.0, green: 0.55, blue: 0.03, alpha: 1)
        fireball.lineWidth = 3
        fireball.glowWidth = 8
        addChild(fireball)

        let core = SKShapeNode(circleOfRadius: radius * 0.54)
        core.fillColor = SKColor(red: 1.0, green: 0.84, blue: 0.16, alpha: 1)
        core.strokeColor = SKColor(red: 1.0, green: 0.97, blue: 0.60, alpha: 1)
        core.lineWidth = 2
        core.glowWidth = 5
        addChild(core)

        let flamePath = CGMutablePath()
        flamePath.move(to: CGPoint(x: radius * 0.72, y: 0))

        flamePath.addCurve(
            to: CGPoint(x: radius * 1.85, y: 0),
            control1: CGPoint(x: radius * 1.05, y: radius * 0.62),
            control2: CGPoint(x: radius * 1.55, y: radius * 0.28)
        )

        flamePath.addCurve(
            to: CGPoint(x: radius * 0.72, y: 0),
            control1: CGPoint(x: radius * 1.55, y: -radius * 0.28),
            control2: CGPoint(x: radius * 1.05, y: -radius * 0.62)
        )

        let flame = SKShapeNode(path: flamePath)
        flame.fillColor = SKColor(red: 1.0, green: 0.46, blue: 0.02, alpha: 1)
        flame.strokeColor = SKColor(red: 1.0, green: 0.78, blue: 0.08, alpha: 1)
        flame.lineWidth = 2
        flame.zPosition = -1
        addChild(flame)

        physicsBody = SKPhysicsBody(circleOfRadius: radius * 0.82)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.player

        let pulse = SKAction.sequence([
            .scale(to: 1.08, duration: 0.18),
            .scale(to: 0.94, duration: 0.18)
        ])
        run(.repeatForever(pulse), withKey: "pulseFireball")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
