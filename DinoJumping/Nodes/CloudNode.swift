import SpriteKit

final class CloudNode: SKSpriteNode {
    static let aspectRatio: CGFloat = 4 / 9
    private static let foregroundSkyLayer: CGFloat = 1
    private let initialPosition: CGPoint

    init(assetName: String, size: CGSize, position: CGPoint, opacity: CGFloat) {
        initialPosition = position
        super.init(texture: SKTexture(imageNamed: assetName), color: .clear, size: size)

        self.position = position
        alpha = opacity
        // The sun and moon use layer -1, so clouds always drift in front of them.
        zPosition = Self.foregroundSkyLayer
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
