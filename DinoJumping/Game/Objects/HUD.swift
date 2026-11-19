import SpriteKit

extension DinoGameScene {
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

    func updateScoreLabels() {
        scoreLabel.text = String(format: "%05d", score)
        bestLabel.text = "BEST  " + String(format: "%05d", bestScore)
    }
}
