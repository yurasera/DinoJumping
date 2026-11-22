import SpriteKit

final class CloudNode: SKSpriteNode {
    private let initialPosition: CGPoint

    init(assetName: String, size: CGSize, position: CGPoint, opacity: CGFloat) {
        initialPosition = position
        super.init(texture: SKTexture(imageNamed: assetName), color: .clear, size: size)

        self.position = position
        alpha = opacity
        zPosition = -0.5
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func startScrolling(speed: CGFloat, sceneWidth: CGFloat) {
        removeAction(forKey: "scrollCloud")

        let distance = sceneWidth + size.width * 1.5
        let move = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(distance / speed))
        let wrap = SKAction.moveBy(x: distance, y: 0, duration: 0)
        run(.repeatForever(.sequence([move, wrap])), withKey: "scrollCloud")
    }

    func stopScrolling() {
        removeAction(forKey: "scrollCloud")
    }

    func resetScrolling() {
        stopScrolling()
        position = initialPosition
    }
}
