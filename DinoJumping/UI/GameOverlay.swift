//
//  GameOverlay.swift
//  DinoJumping
//
//  Created by Yuhaya Lissera on 21/11/26.
//

import SpriteKit

final class GameOverlay: SKNode {

    func showStart() {
        removeAllChildren()

        let title = SKLabelNode(text: "DINO JUMPING")
        title.fontSize = 36
        title.fontName = "Arial-Bold"
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 35)

        let start = SKLabelNode(text: "MULAI")
        start.name = "startButton"
        start.fontSize = 24
        start.fontName = "Arial-Bold"
        start.fontColor = .yellow
        start.position = CGPoint(x: 0, y: -25)

        addChild(title)
        addChild(start)
    }

    func showGameOver() {
        removeAllChildren()

        let title = SKLabelNode(text: "GAME OVER")
        title.fontSize = 42
        title.fontName = "Arial-Bold"
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 35)

        let restart = SKLabelNode(text: "RESTART")
        restart.name = "restartButton"
        restart.fontSize = 24
        restart.fontName = "Arial-Bold"
        restart.fontColor = .yellow
        restart.position = CGPoint(x: 0, y: -25)

        addChild(title)
        addChild(restart)
    }

    func hide() {
        removeAllChildren()
    }
}
