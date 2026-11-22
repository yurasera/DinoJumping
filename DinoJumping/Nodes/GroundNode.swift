import SpriteKit

final class GroundNode: SKShapeNode {
    init(width: CGFloat, height: CGFloat, terrainTexture: SKTexture) {
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
        // This shape exists only for its physics body. Its fill used to cover
        // the Terrain sprites that are added below.
        fillColor = .clear
        strokeColor = .clear

        addTerrainTiles(width: width, height: height, texture: terrainTexture)

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

    private func addTerrainTiles(width: CGFloat, height: CGFloat, texture: SKTexture) {
        let tileWidth: CGFloat = 32
        let tileHeight: CGFloat = 32
        let tileCount = Int(ceil(width / tileWidth))

        for index in 0..<tileCount {
            let tile = SKSpriteNode(
                texture: texture,
                color: .clear,
                size: CGSize(width: tileWidth, height: tileHeight)
            )
            tile.position = CGPoint(
                x: -width / 2 + CGFloat(index) * tileWidth + tileWidth / 2,
                y: height / 2 - tileHeight / 2
            )
            tile.zPosition = 1
            addChild(tile)
        }
    }
}
