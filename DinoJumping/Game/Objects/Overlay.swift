import SpriteKit

extension DinoGameScene {
    // MARK: - Overlay

    func showOverlay(title: String, message: String) {
        guard showOverlay else { return }

        overlay.removeFromParent()
        overlay.removeAllChildren()
        overlay.zPosition = 20

        let panel = SKShapeNode(
            rectOf: CGSize(width: 460, height: 240),
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

        // Tombol hanya muncul saat game over.
        if title == "GAME OVER" {
            let restartButton = SKShapeNode(
                rectOf: CGSize(width: 180, height: 44),
                cornerRadius: 12
            )
            restartButton.name = "restartButton"
            restartButton.fillColor = accentColor
            restartButton.strokeColor = .clear
            restartButton.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
            overlay.addChild(restartButton)

            let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            restartLabel.name = "restartButton"
            restartLabel.text = "RESTART"
            restartLabel.fontSize = 17
            restartLabel.fontColor = SKColor(
                red: 0.10,
                green: 0.06,
                blue: 0.22,
                alpha: 1
            )
            restartLabel.verticalAlignmentMode = .center
            restartLabel.position = .zero
            restartButton.addChild(restartLabel)
        }

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
}
