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
}
