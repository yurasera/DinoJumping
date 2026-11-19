import SpriteKit

extension DinoGameScene {
    // MARK: - Background

    func createBackground() {
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        sky.fillColor = backgroundColorValue
        sky.strokeColor = .clear
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.zPosition = -10
        addChild(sky)

        addStars()
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
        ground.position = CGPoint(x: size.width / 2, y: groundHeight / 2)
        ground.zPosition = -8
        addChild(ground)

        let groundLine = SKShapeNode(rectOf: CGSize(width: size.width, height: 4))
        groundLine.fillColor = SKColor(red: 0.54, green: 0.46, blue: 0.97, alpha: 1)
        groundLine.strokeColor = .clear
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
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 22, y: size.height - 42)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)

        bestLabel.fontSize = 14
        bestLabel.fontColor = .white.withAlphaComponent(0.75)
        bestLabel.horizontalAlignmentMode = .right
        bestLabel.position = CGPoint(x: size.width - 22, y: size.height - 39)
        bestLabel.zPosition = 10
        addChild(bestLabel)

        updateScoreLabels()
    }

    // MARK: - Player

    func createPlayer() {
        player.name = "player"
        player.position = CGPoint(x: 125, y: groundY + 36)
        player.zPosition = 5

        let body = SKShapeNode(rectOf: CGSize(width: 42, height: 48), cornerRadius: 10)
        body.fillColor = dinoColor
        body.strokeColor = .clear
        body.position = CGPoint(x: 0, y: 4)
        player.addChild(body)

        let head = SKShapeNode(rectOf: CGSize(width: 34, height: 31), cornerRadius: 9)
        head.fillColor = dinoColor
        head.strokeColor = .clear
        head.position = CGPoint(x: 18, y: 23)
        player.addChild(head)

        let eye = SKShapeNode(circleOfRadius: 3)
        eye.fillColor = groundColor
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 27, y: 29)
        player.addChild(eye)

        let tail = SKShapeNode(rectOf: CGSize(width: 15, height: 8), cornerRadius: 3)
        tail.fillColor = dinoColor
        tail.strokeColor = .clear
        tail.position = CGPoint(x: -27, y: 10)
        tail.zRotation = -0.35
        player.addChild(tail)

        addPlayerFoot(at: CGPoint(x: -11, y: -22))
        addPlayerFoot(at: CGPoint(x: 14, y: -22))

        player.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: 38, height: 72),
            center: CGPoint(x: 5, y: 0)
        )
        player.physicsBody?.isDynamic = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 0
        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.ground
        player.physicsBody?.contactTestBitMask = Category.obstacle

        addChild(player)
    }

    func addPlayerFoot(at position: CGPoint) {
        let foot = SKShapeNode(rectOf: CGSize(width: 12, height: 7), cornerRadius: 2)
        foot.fillColor = dinoColor
        foot.strokeColor = .clear
        foot.position = position
        player.addChild(foot)
    }
}
