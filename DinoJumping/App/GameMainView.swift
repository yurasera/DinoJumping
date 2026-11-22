import SwiftUI
import SpriteKit

struct GameMainView: View {
    @State private var gameScene = DinoGameScene(
        size: CGSize(width: 900, height: 500)
    )
    @State private var gameState: GameState = .ready

    var body: some View {
        ZStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                GameViewTheme.background(for: context.date)
            }

            SpriteView(scene: gameScene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Permainan Dino Jumping")

            if gameState == .playing {
                JumpButton {
                    gameScene.jump()
                }
            } else {
                GameOverlay(
                    gameState: gameState,
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
        }
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
