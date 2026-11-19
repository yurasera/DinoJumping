import SpriteKit

extension DinoGameScene {
    // MARK: - Game loop helpers

    func getDeltaTime(_ currentTime: TimeInterval) -> TimeInterval {
        let deltaTime = lastUpdateTime == 0
            ? 0
            : min(currentTime - lastUpdateTime, 1.0 / 20.0)

        lastUpdateTime = currentTime
        return deltaTime
    }

    func createObstacleWhenNeeded() {
        let spawnInterval = max(0.72, 1.45 - elapsedTime * 0.008)

        guard obstacleTimer > spawnInterval else { return }

        obstacleTimer = 0
        createObstacle()
    }

    func moveObstacles(_ deltaTime: TimeInterval) {
        enumerateChildNodes(withName: "obstacle") { [weak self] obstacle, _ in
            guard let self else { return }

            obstacle.position.x -= self.gameSpeed * CGFloat(deltaTime)

            if obstacle.position.x < -100 {
                obstacle.removeFromParent()
            }
        }
    }

    // MARK: - Create obstacles

    func createObstacle() {
        guard showObstacles else { return }

        let isBird = Int.random(in: 0...4) == 0

        if isBird {
            createBird()
        } else {
            createCactus()
        }
    }

    func createCactus() {
        let height = CGFloat(Int.random(in: 42...70))
        let obstacle = SKNode()
        obstacle.name = "obstacle"
        obstacle.position = CGPoint(
            x: size.width + 40,
            y: groundY + height / 2
        )

        let trunk = SKShapeNode(
            rectOf: CGSize(width: 16, height: height),
            cornerRadius: 6
        )
        trunk.fillColor = dinoColor
        trunk.strokeColor = .clear
        obstacle.addChild(trunk)

        let arm = SKShapeNode(
            rectOf: CGSize(width: 10, height: height * 0.32),
            cornerRadius: 4
        )
        arm.fillColor = dinoColor
        arm.strokeColor = .clear
        arm.position = CGPoint(x: 14, y: height * 0.15)
        obstacle.addChild(arm)

        addObstaclePhysics(
            to: obstacle,
            size: CGSize(width: 30, height: height * 0.85)
        )
    }

    func createBird() {
        let obstacle = SKNode()
        obstacle.name = "obstacle"
        obstacle.position = CGPoint(x: size.width + 50, y: groundY + 70)

        let bird = SKShapeNode(ellipseOf: CGSize(width: 40, height: 20))
        bird.fillColor = obstacleColor
        bird.strokeColor = .clear
        obstacle.addChild(bird)

        let wing = SKShapeNode(rectOf: CGSize(width: 24, height: 7), cornerRadius: 3)
        wing.fillColor = obstacleColor
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -12, y: 10)
        wing.zRotation = -0.5
        obstacle.addChild(wing)

        addObstaclePhysics(
            to: obstacle,
            size: CGSize(width: 42, height: 22)
        )
    }

    func addObstaclePhysics(to obstacle: SKNode, size: CGSize) {
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = Category.obstacle
        obstacle.physicsBody?.collisionBitMask = 0
        obstacle.physicsBody?.contactTestBitMask = Category.player
        addChild(obstacle)
    }

    func removeObstacles() {
        enumerateChildNodes(withName: "obstacle") { obstacle, _ in
            obstacle.removeFromParent()
        }
    }
}
