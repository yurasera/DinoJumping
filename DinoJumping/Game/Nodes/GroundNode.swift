import SpriteKit

final class GroundNode: SKShapeNode {
    private let tileSize: CGFloat = 32
    // Adjacent tiles overlap by one point to prevent hairline seams while scrolling.
    private let tileOverlap: CGFloat = 1
    private var terrainTiles: [SKSpriteNode] = []
    private var terrainWidth: CGFloat = 0
    private let terrainTexture: SKTexture
    private let preGapTexture: SKTexture
    private let postGapTexture: SKTexture
    private var gapTiles: [SKSpriteNode] = []
    private var gapMarkerTiles: [SKSpriteNode] = []

    init(
        width: CGFloat,
        height: CGFloat,
        terrainTexture: SKTexture,
        preGapTexture: SKTexture,
        postGapTexture: SKTexture
    ) {
        self.terrainTexture = terrainTexture
        self.preGapTexture = preGapTexture
        self.postGapTexture = postGapTexture
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

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("GroundNode must be created in code")
    }

    private func addTerrainTiles(width: CGFloat, height: CGFloat, texture: SKTexture) {
        terrainWidth = width
        let tileCount = Int(ceil(width / tileSize))

        for index in 0..<tileCount {
            let tile = SKSpriteNode(
                texture: texture,
                color: .clear,
                size: CGSize(width: tileSize + tileOverlap, height: tileSize)
            )
            tile.position = CGPoint(
                x: tileXPosition(for: index),
                y: height / 2 - tileSize / 2
            )
            tile.name = "ground"
            tile.zPosition = 1
            addGroundPhysics(to: tile)
            addChild(tile)
            terrainTiles.append(tile)
        }
    }

    // Perubahan fix: hanya sprite terrain yang bergerak; physics ground tetap diam.
    func startScrolling(speed: CGFloat) {
        let move = SKAction.moveBy(x: -tileSize, y: 0, duration: tileSize / speed)
        let wrap = SKAction.moveBy(
            x: CGFloat(terrainTiles.count) * tileSize,
            y: 0,
            duration: 0
        )
        let fullLoop = SKAction.sequence([
            .repeat(move, count: terrainTiles.count),
            wrap
        ])

        for (index, tile) in terrainTiles.enumerated() {
            // Setiap tile menunggu giliran keluar dari sisi kiri sebelum wrap.
            // Jika semua tile wrap bersamaan, ground akan tampak menghilang.
            let initialSteps = SKAction.repeat(move, count: index + 1)
            tile.run(
                .sequence([initialSteps, wrap, .repeatForever(fullLoop)]),
                withKey: "scrollTerrain"
            )
        }
    }

    func stopScrolling() {
        terrainTiles.forEach { $0.removeAction(forKey: "scrollTerrain") }
    }

    func resetScrolling() {
        stopScrolling()
        gapTiles.removeAll()
        gapMarkerTiles.removeAll()

        for (index, tile) in terrainTiles.enumerated() {
            tile.position.x = tileXPosition(for: index)
            tile.isHidden = false
            tile.texture = terrainTexture
            addGroundPhysics(to: tile)
        }
    }

    /// Creates one gap just beyond the right edge, so it scrolls into view naturally.
    func createGapAtRightEdge(sceneWidth: CGFloat, count: Int = 4) {
        let rightEdgeInGround = sceneWidth / 2
        let tilesAtRightEdge = terrainTiles
            .filter { $0.position.x >= rightEdgeInGround }
            .sorted { $0.position.x < $1.position.x }

        let gapTiles = tilesAtRightEdge.prefix(count)
        guard let firstGapTile = gapTiles.first else { return }

        let tileBeforeGap = terrainTiles
            .filter { !$0.isHidden && $0.position.x < firstGapTile.position.x }
            .max { $0.position.x < $1.position.x }
        tileBeforeGap?.texture = preGapTexture

        let lastGapX = gapTiles.last?.position.x ?? firstGapTile.position.x
        let tileAfterGap = terrainTiles
            .filter { !$0.isHidden && $0.position.x > lastGapX }
            .min { $0.position.x < $1.position.x }
        tileAfterGap?.texture = postGapTexture

        gapTiles.forEach {
            $0.isHidden = true
            $0.physicsBody = nil
        }

        self.gapTiles = Array(gapTiles)
        gapMarkerTiles = [tileBeforeGap, tileAfterGap].compactMap { $0 }
    }

    /// Restores the tiles after the gap has left the screen, preventing it from
    /// looping back and overlapping a later obstacle.
    func restoreGap() {
        gapTiles.forEach {
            $0.isHidden = false
            $0.texture = terrainTexture
            addGroundPhysics(to: $0)
        }
        gapMarkerTiles.forEach { $0.texture = terrainTexture }
        gapTiles.removeAll()
        gapMarkerTiles.removeAll()
    }

    private func addGroundPhysics(to tile: SKSpriteNode) {
        tile.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: -tileSize / 2 - tileOverlap / 2, y: tileSize / 2),
            to: CGPoint(x: tileSize / 2 + tileOverlap / 2, y: tileSize / 2)
        )
        tile.physicsBody?.isDynamic = false
        tile.physicsBody?.categoryBitMask = PhysicsCategory.ground
        tile.physicsBody?.collisionBitMask = PhysicsCategory.player
        tile.physicsBody?.contactTestBitMask = PhysicsCategory.player
    }

    private func tileXPosition(for index: Int) -> CGFloat {
        -terrainWidth / 2 + CGFloat(index) * tileSize + tileSize / 2
    }
}
