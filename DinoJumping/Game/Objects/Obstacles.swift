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
        let spawnInterval = max(2.5, 3.5 - elapsedTime * 0.005)

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

        let isUFO = Int.random(in: 0...4) == 0

        if isUFO {
            createUFO()
        } else {
            createPalmTree()
        }
    }

    func createPalmTree() {
        let height = CGFloat(Int.random(in: 60...82))
        let obstacle = SKNode()
        obstacle.name = "obstacle"
        obstacle.position = CGPoint(
            x: size.width + 40,
            y: groundY + height / 2
        )

        let trunkColor = SKColor(red: 0.55, green: 0.30, blue: 0.12, alpha: 1)
        let leafColor = SKColor(red: 0.18, green: 0.70, blue: 0.30, alpha: 1)

        let trunk = SKShapeNode(
            rectOf: CGSize(width: 12, height: height),
            cornerRadius: 5
        )
        trunk.fillColor = trunkColor
        trunk.strokeColor = .clear
        trunk.zRotation = -0.08
        obstacle.addChild(trunk)

        let crown = SKShapeNode(ellipseOf: CGSize(width: 42, height: 18))
        crown.fillColor = leafColor
        crown.strokeColor = .clear
        crown.position = CGPoint(x: 0, y: height / 2)
        obstacle.addChild(crown)

        for angle in [-0.8, -0.4, 0.0, 0.4, 0.8] {
            let leaf = SKShapeNode(
                rectOf: CGSize(width: 28, height: 6),
                cornerRadius: 3
            )
            leaf.fillColor = leafColor
            leaf.strokeColor = .clear
            leaf.position = CGPoint(x: 0, y: height / 2)
            leaf.zRotation = angle
            obstacle.addChild(leaf)
        }

        addObstaclePhysics(
            to: obstacle,
            size: CGSize(width: 30, height: height * 0.9)
        )
    }

    func createUFO() {
        let obstacle = SKNode()
        obstacle.name = "obstacle"
        obstacle.position = CGPoint(x: size.width + 50, y: groundY + 70)

        let bodyColor = SKColor(red: 0.65, green: 0.70, blue: 0.78, alpha: 1)
        let lightColor = SKColor(red: 0.30, green: 0.90, blue: 1.0, alpha: 1)

        let body = SKShapeNode(ellipseOf: CGSize(width: 52, height: 20))
        body.fillColor = bodyColor
        body.strokeColor = .clear
        obstacle.addChild(body)

        let dome = SKShapeNode(ellipseOf: CGSize(width: 24, height: 18))
        dome.fillColor = lightColor
        dome.strokeColor = .clear
        dome.position = CGPoint(x: 0, y: 8)
        obstacle.addChild(dome)

        for x in [-18, 0, 18] {
            let light = SKShapeNode(circleOfRadius: 3)
            light.fillColor = accentColor
            light.strokeColor = .clear
            light.position = CGPoint(x: x, y: -7)
            obstacle.addChild(light)
        }

        addObstaclePhysics(
            to: obstacle,
            size: CGSize(width: 52, height: 24)
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
