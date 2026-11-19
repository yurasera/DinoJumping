import SpriteKit

extension DinoGameScene {
    // MARK: - Start and jump

    func jump() {
        jumpPlayer()
    }

    func startGame() {
        state = .playing
        score = 0
        elapsedTime = 0
        obstacleTimer = 0
        lastUpdateTime = 0
        gameSpeed = initialSpeed

        removeObstacles()
        player.removeAction(forKey: "jump")
        overlay.removeFromParent()
        player.position = CGPoint(x: 125, y: groundY + 35)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = .zero
        player.physicsBody?.isResting = false
        startPlayerRunning()

         updateScoreLabels() // HUD sedang dimatikan.
    }

    func endGame() {
        guard state == .playing else { return }

        state = .gameOver
        player.removeAction(forKey: "jump")
        stopPlayerRunning()
        player.physicsBody?.isDynamic = false
        player.physicsBody?.velocity = .zero

        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "dinoBestScore")
        }

         updateScoreLabels() // HUD sedang dimatikan.

        if showOverlay {
            showOverlay(
                title: "GAME OVER",
                message: "Skor kamu  " + String(format: "%05d", score)
            )
        }
    }

    // MARK: - Score

    func updateScore() {
        score = Int(elapsedTime * 10)
        gameSpeed = min(650, initialSpeed + CGFloat(score) * 0.7)

         updateScoreLabels() // HUD sedang dimatikan.
    }
}
