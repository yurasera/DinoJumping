import SpriteKit

final class ObstacleNode: SKShapeNode {
    override init() {
        super.init()

        path = CGPath(
            roundedRect: CGRect(x: -19, y: -38, width: 38, height: 76),
            cornerWidth: 8,
            cornerHeight: 8,
            transform: nil
        )
        name = "obstacle"
        fillColor = SKColor(red: 0.95, green: 0.39, blue: 0.48, alpha: 1)
        strokeColor = SKColor(red: 1.0, green: 0.72, blue: 0.78, alpha: 1)
        lineWidth = 3
        zPosition = 1
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
