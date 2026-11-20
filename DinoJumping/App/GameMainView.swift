import SwiftUI
import SpriteKit

struct GameMainView: View {
    @State private var gameScene = DinoGameScene(
        size: CGSize(width: 900, height: 500)
    )
    @State private var gameStarted = false

    var body: some View {
        ZStack {
            GameViewTheme.background

            SpriteView(scene: gameScene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Permainan Dino Jumping")

            if gameStarted {
                JumpButton {
                    gameScene.jump()
                }
            } else {
                StartOverlay {
                    gameScene.startGame()
                    gameStarted = true
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct StartOverlay: View {
    let startGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("DINO JUMPING")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Hindari obstacle dengan melompat.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))

                Button("MULAI", action: startGame)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
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

private enum GameViewTheme {
    static let background = Color(
        red: 0.10,
        green: 0.06,
        blue: 0.22
    )
}

#Preview {
    GameMainView()
}
