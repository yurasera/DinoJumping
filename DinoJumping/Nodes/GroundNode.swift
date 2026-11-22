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
        let tileSize: CGFloat = 32
        let tileCount = Int(ceil(width / tileSize))

        for index in 0..<tileCount {
            let tile = SKSpriteNode(
                texture: texture,
                color: .clear,
                size: CGSize(width: tileSize, height: tileSize)
            )
            tile.position = CGPoint(
                x: -width / 2 + tileSize / 2 + CGFloat(index) * tileSize,
                y: height / 2 - tileSize / 2
            )
            tile.zPosition = 1
            addChild(tile)
        }
    }
}
