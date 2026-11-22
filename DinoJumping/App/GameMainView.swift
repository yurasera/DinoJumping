import SwiftUI
import SpriteKit

struct GameMainView: View {
    @State private var gameScene = DinoGameScene(
        size: CGSize(width: 900, height: 500)
    )
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var highScore = UserDefaults.standard.integer(forKey: "DinoJumping.highScore")

    var body: some View {
        ZStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                GameViewTheme.background(for: context.date)
            }

            SpriteView(scene: gameScene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Permainan Dino Jumping")

            ScoreBoard(score: score, highScore: highScore)

            if gameState == .playing {
                JumpButton {
                    gameScene.jump()
                }
            } else {
                GameOverlay(
                    gameState: gameState,
                    score: score,
                    highScore: highScore,
                    startGame: {
                        gameScene.startGame()
                    },
                    restartGame: {
                        gameScene.restartGame()
                    }
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            gameScene.onGameStateChange = { newState in
                gameState = newState
            }
            gameScene.onScoreChange = { newScore, newHighScore in
                score = newScore
                highScore = newHighScore
            }
            gameScene.publishScore()
        }
    }
}

private struct ScoreBoard: View {
    let score: Int
    let highScore: Int

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                scoreLabel(title: "SKOR: ", value: score)
                scoreLabel(title: "TERTINGGI: ", value: highScore)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()
        }
        .allowsHitTesting(false)
    }

    private func scoreLabel(title: String, value: Int) -> some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.8))
            Text("\(value)")
                .font(.caption2.monospacedDigit().weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct JumpButton: View {
    let jump: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button(action: jump) {
                    Label("LOMPAT", systemImage: "arrow.up")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    GameMainView()
}
