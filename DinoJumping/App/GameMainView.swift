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

enum GameViewTheme {
    private typealias RGB = (red: CGFloat, green: CGFloat, blue: CGFloat)

    static func background(for date: Date) -> Color {
        let color = skyColor(for: date)
        return Color(red: color.red, green: color.green, blue: color.blue)
    }

    static func spriteKitBackground(for date: Date = .now) -> SKColor {
        let color = skyColor(for: date)
        return SKColor(red: color.red, green: color.green, blue: color.blue, alpha: 1)
    }

    private static func skyColor(for date: Date) -> RGB {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let hour = CGFloat(components.hour ?? 0)
            + CGFloat(components.minute ?? 0) / 60
            + CGFloat(components.second ?? 0) / 3_600

        let night: RGB = (0.10, 0.06, 0.22)
        let morning: RGB = (0.35, 0.69, 0.93)
        let day: RGB = (0.24, 0.65, 0.96)
        let evening: RGB = (0.91, 0.32, 0.31)

        switch hour {
        case 5..<8:
            return blend(from: night, to: morning, progress: (hour - 5) / 3)
        case 8..<16:
            return blend(from: morning, to: day, progress: (hour - 8) / 8)
        case 16..<19:
            return blend(from: day, to: evening, progress: (hour - 16) / 3)
        case 19..<21:
            return blend(from: evening, to: night, progress: (hour - 19) / 2)
        default:
            return night
        }
    }

    private static func blend(from start: RGB, to end: RGB, progress: CGFloat) -> RGB {
        let progress = min(max(progress, 0), 1)
        return (
            start.red + (end.red - start.red) * progress,
            start.green + (end.green - start.green) * progress,
            start.blue + (end.blue - start.blue) * progress
        )
    }
}

#Preview {
    GameMainView()
}
