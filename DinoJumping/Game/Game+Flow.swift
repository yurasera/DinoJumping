import SpriteKit

extension DinoGameScene {
    // MARK: - Start and jump

    func jump() {
        if state == .ready || state == .gameOver {
            startGame()
            return
        }

        guard state == .playing,
              let body = player.physicsBody,
              abs(body.velocity.dy) < 40 else {
            return
        }

        body.applyImpulse(CGVector(dx: 0, dy: jumpPower))
    }

    func startGame() {
        state = .playing
        score = 0
        elapsedTime = 0
        obstacleTimer = 0
        lastUpdateTime = 0
        gameSpeed = initialSpeed

        removeObstacles()
        overlay.removeFromParent()
        player.position = CGPoint(x: 125, y: groundY + 36)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero
        player.physicsBody?.isResting = false
        updateScoreLabels()
    }

    func endGame() {
        guard state == .playing else { return }

        state = .gameOver
        player.physicsBody?.isDynamic = false
        player.physicsBody?.velocity = .zero

        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "dinoBestScore")
        }

        updateScoreLabels()
        showOverlay(
            title: "GAME OVER",
            message: "Skor kamu  " + String(format: "%05d", score)
        )
    }

    // MARK: - Overlay

    func showOverlay(title: String, message: String) {
        overlay.removeFromParent()
        overlay.removeAllChildren()
        overlay.zPosition = 20

        let panel = SKShapeNode(
            rectOf: CGSize(width: 360, height: 150),
            cornerRadius: 18
        )
        panel.fillColor = SKColor(red: 0.16, green: 0.10, blue: 0.33, alpha: 0.97)
        panel.strokeColor = accentColor.withAlphaComponent(0.35)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.53)
        overlay.addChild(panel)

        addOverlayLabel(
            title,
            fontSize: 30,
            color: accentColor,
            y: size.height * 0.59
        )
        addOverlayLabel(
            message,
            fontSize: 15,
            color: .white,
            y: size.height * 0.51
        )

        addChild(overlay)
    }

    func addOverlayLabel(
        _ text: String,
        fontSize: CGFloat,
        color: SKColor,
        y: CGFloat
    ) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: y)
        overlay.addChild(label)
    }

    // MARK: - Score

    func updateScore() {
        score = Int(elapsedTime * 10)
        gameSpeed = min(650, initialSpeed + CGFloat(score) * 0.7)
        updateScoreLabels()
    }

    func updateScoreLabels() {
        scoreLabel.text = String(format: "%05d", score)
        bestLabel.text = "BEST  " + String(format: "%05d", bestScore)
    }
}
