import SpriteKit

final class DinoGameScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
    }
}
