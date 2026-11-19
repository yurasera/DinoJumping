import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var gameScene = DinoGameScene(size: CGSize(width: 900, height: 500))
    @State private var showStartButton = true

    var body: some View {
        ZStack {
            SpriteView(scene: gameScene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showStartButton {
                Button {
                    gameScene.startGame()
                    showStartButton = false
                } label: {
                    Text("MULAI")
                        .font(.headline.weight(.bold))
                        .frame(width: 140, height: 52)
                        .foregroundStyle(Color(red: 0.10, green: 0.06, blue: 0.22))
                        .background(Color(red: 1.0, green: 0.82, blue: 0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Mulai game")
            }

            Button {
                gameScene.jump()
            } label: {
                Text("LOMPAT")
                    .font(.caption.weight(.bold))
                    .frame(width: 78, height: 78)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.85, green: 0.25, blue: 0.30).opacity(0.9))
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.7), lineWidth: 2)
                    }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
            .accessibilityLabel("Lompat")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .background(Color(red: 0.10, green: 0.06, blue: 0.22))
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
