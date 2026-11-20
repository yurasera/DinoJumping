import SpriteKit

final class DinoGameScene: SKScene {
    private let player = PlayerNode()
    private let groundHeight: CGFloat = 72

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addGround()
        addPlayer()
    }

    private func addGround() {
        let ground = SKShapeNode(
            rectOf: CGSize(
                width: size.width * 2,
                height: groundHeight
            )
        )
        ground.name = "ground"
        ground.position = CGPoint(
            x: size.width / 2,
            y: groundHeight / 2
        )
        ground.fillColor = SKColor(red: 0.16, green: 0.10, blue: 0.30, alpha: 1)
        ground.strokeColor = SKColor(red: 0.67, green: 0.42, blue: 0.96, alpha: 1)
        ground.lineWidth = 3
        addChild(ground)
    }

    private func addPlayer() {
        guard player.parent == nil else { return }

        player.position = CGPoint(x: size.width * 0.18, y: size.height * 0.22)
        addChild(player)
    }
}
