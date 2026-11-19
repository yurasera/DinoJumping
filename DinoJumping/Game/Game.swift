import Foundation
import SpriteKit

final class DinoGameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Game settings

    enum State {
        case ready
        case playing
        case gameOver
    }

    enum Category {
        static let player: UInt32 = 1
        static let obstacle: UInt32 = 2
        static let ground: UInt32 = 4
    }

    let groundHeight: CGFloat = 100
    let gravity: CGFloat = -1_850
    let jumpPower: CGFloat = 720
    let initialSpeed: CGFloat = 310

    let backgroundColorValue = SKColor(red: 0.15, green: 0.09, blue: 0.35, alpha: 1)
    let groundColor = SKColor(red: 0.09, green: 0.05, blue: 0.22, alpha: 1)
    let accentColor = SKColor(red: 1.0, green: 0.82, blue: 0.25, alpha: 1)
    let dinoColor = SKColor(red: 0.29, green: 0.87, blue: 0.50, alpha: 1)
    let obstacleColor = SKColor(red: 1.0, green: 0.42, blue: 0.36, alpha: 1)

    // MARK: - Scene objects

    let player = SKNode()
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let bestLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let overlay = SKNode()

    // MARK: - Game state

    var state: State = .ready
    var score = 0
    var bestScore = UserDefaults.standard.integer(forKey: "dinoBestScore")
    var elapsedTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var obstacleTimer: TimeInterval = 0
    var gameSpeed: CGFloat = 310

    var groundY: CGFloat {
        groundHeight
    }

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        scaleMode = .aspectFit
        backgroundColor = backgroundColorValue
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.contactDelegate = self

        createBackground()
        createHUD()
        createPlayer()
        showOverlay(
            title: "DINO DASH",
            message: "Gunakan tombol di bawah untuk mulai dan melompat."
        )
    }

    override func update(_ currentTime: TimeInterval) {
        guard state == .playing else { return }

        let deltaTime = getDeltaTime(currentTime)
        elapsedTime += deltaTime
        obstacleTimer += deltaTime

        updateScore()
        moveObstacles(deltaTime)
        createObstacleWhenNeeded()
    }

    // MARK: - Input and physics

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jump()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if categories == Category.player | Category.obstacle {
            endGame()
        }
    }
}
