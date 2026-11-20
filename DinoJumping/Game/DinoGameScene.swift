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
        addPlayer()
    }

    private func addPlayer() {
        guard player.parent == nil else { return }

        player.position = CGPoint(x: size.width * 0.18, y: size.height * 0.22)
        addChild(player)
    }
}
