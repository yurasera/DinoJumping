import SpriteKit

extension DinoGameScene {
    // MARK: - Background

    func createBackground() {
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        sky.fillColor = backgroundColorValue
        sky.strokeColor = .clear
        sky.isHidden = !showBackground
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.zPosition = -10
        addChild(sky)

        // Bintang sedang dimatikan karena showStars = false.
        // if showStars {
        //     addStars()
        // }

        // Ground tetap dibuat agar physics player tetap memiliki lantai.
        addGround()
    }

    func addStars() {
        for index in 0..<24 {
            let star = SKShapeNode(circleOfRadius: index.isMultiple(of: 4) ? 2 : 1)
            star.fillColor = accentColor.withAlphaComponent(0.55)
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat((index * 173 + 31) % Int(size.width)),
                y: CGFloat(250 + (index * 61) % 200)
            )
            star.zPosition = -9
            addChild(star)
        }
    }

    func addGround() {
        let ground = SKShapeNode(
            rectOf: CGSize(width: size.width, height: groundHeight)
        )
        ground.fillColor = groundColor
        ground.strokeColor = .clear
        ground.isHidden = !showGround
        ground.position = CGPoint(x: size.width / 2, y: groundHeight / 2)
        ground.zPosition = -8
        addChild(ground)

        let groundLine = SKShapeNode(rectOf: CGSize(width: size.width, height: 4))
        groundLine.fillColor = SKColor(red: 0.54, green: 0.46, blue: 0.97, alpha: 1)
        groundLine.strokeColor = .clear
        groundLine.isHidden = !showGround
        groundLine.position = CGPoint(x: size.width / 2, y: groundY)
        groundLine.zPosition = -7
        addChild(groundLine)

        let groundBody = SKNode()
        groundBody.position = CGPoint(x: size.width / 2, y: groundY - 4)
        groundBody.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width, height: 8)
        )
        groundBody.physicsBody?.isDynamic = false
        groundBody.physicsBody?.categoryBitMask = Category.ground
        groundBody.physicsBody?.collisionBitMask = Category.player
        addChild(groundBody)
    }

    // MARK: - HUD

    func createHUD() {
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = accentColor
        scoreLabel.isHidden = !showHUD
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 22, y: size.height - 42)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)

        bestLabel.fontSize = 14
        bestLabel.fontColor = .white.withAlphaComponent(0.75)
        bestLabel.isHidden = !showHUD
        bestLabel.horizontalAlignmentMode = .right
        bestLabel.position = CGPoint(x: size.width - 22, y: size.height - 39)
        bestLabel.zPosition = 10
        addChild(bestLabel)

        // updateScoreLabels() // HUD sedang dimatikan.
    }

    // MARK: - Player

    func createPlayer() {
        player.name = "player"
        player.isHidden = !showPlayer
        player.position = CGPoint(x: 125, y: groundY + 36)
        player.zPosition = 5

        dinoSprite.texture = dinoTexture(frame: 0)
        dinoSprite.size = CGSize(width: 70, height: 70)
        dinoSprite.texture?.filteringMode = .nearest
        dinoSprite.position = CGPoint(x: 0, y: 4)
        player.addChild(dinoSprite)

        player.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: 38, height: 72),
            center: CGPoint(x: 5, y: 0)
        )
        // Player belum dipengaruhi gravity sebelum tombol mulai ditekan.
        player.physicsBody?.isDynamic = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 0
        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.ground
        player.physicsBody?.contactTestBitMask = Category.obstacle

        addChild(player)
    }

    func dinoTexture(frame: Int) -> SKTexture {
        let spriteSheet = SKTexture(imageNamed: "dino")
        spriteSheet.filteringMode = .nearest

        let frameWidth = 1.0 / 8.0
        let frameRect = CGRect(
            x: CGFloat(frame) * frameWidth,
            y: 0,
            width: frameWidth,
            height: 1
        )

        return SKTexture(rect: frameRect, in: spriteSheet)
    }
}
