import SpriteKit

extension DinoGameScene {
    // MARK: - Overlay

    func showOverlay(title: String, message: String) {
        // Overlay sedang dimatikan karena showOverlay = false.
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
