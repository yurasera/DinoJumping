import SpriteKit

extension DinoGameScene {
    // MARK: - Player

    func createPlayer() {
        player.name = "player"
        player.isHidden = !showPlayer
        player.position = CGPoint(x: 125, y: groundY + 35)
        player.zPosition = 5

        dinoSprite.texture = dinoTexture(frame: 0)
        dinoSprite.size = CGSize(width: 70, height: 70)
        dinoSprite.texture?.filteringMode = .nearest
        dinoSprite.position = CGPoint(x: 0, y: 0)
        player.addChild(dinoSprite)

        player.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: 38, height: 70),
            center: CGPoint(x: 5, y: 0)
        )

        // Sebelum tombol MULAI ditekan, player belum ikut physics.
        player.physicsBody?.isDynamic = false
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 0
        player.physicsBody?.usesPreciseCollisionDetection = true

        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.ground
        player.physicsBody?.contactTestBitMask = Category.obstacle

        addChild(player)
    }

    func jumpPlayer() {
        guard state == .playing,
              let body = player.physicsBody,
              player.action(forKey: "jump") == nil else {
            return
        }

        // Physics dihentikan sementara agar gerakan jump terlihat jelas.
        body.isDynamic = false

        let moveUp = SKAction.moveBy(
            x: 0,
            y: 160,
            duration: 0.2
        )
        let moveDown = SKAction.moveBy(
            x: 0,
            y: -160,
            duration: 0.2
        )
        let finishJump = SKAction.run { [weak self] in
            guard let self else { return }

            // Player kembali tepat di atas tanah setelah mendarat.
            self.player.position.y = self.groundY + 35
            body.velocity = .zero
            body.isDynamic = true
            body.affectedByGravity = true
        }
        let jump = SKAction.sequence([moveUp, moveDown, finishJump])

        player.run(jump, withKey: "jump")
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

    // MARK: - Player animation

    func startIdleAnimation() {
        // Idle berupa satu frame diam, tanpa gerakan naik-turun.
        dinoSprite.removeAllActions()
        dinoSprite.texture = dinoTexture(frame: 0)
    }

    func startPlayerRunning() {
        dinoSprite.removeAction(forKey: "idle")

        // Delapan frame ini hanya berjalan setelah startGame().
        let frames = (0..<8).map { dinoTexture(frame: $0) }
        let running = SKAction.repeatForever(
            SKAction.animate(with: frames, timePerFrame: playerRunDuration)
        )

        dinoSprite.run(running, withKey: "running")
    }

    func stopPlayerRunning() {
        dinoSprite.removeAction(forKey: "running")
        dinoSprite.texture = dinoTexture(frame: 0)
        startIdleAnimation()
    }
}
