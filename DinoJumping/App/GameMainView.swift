import SwiftUI
import SpriteKit

struct GameMainView: View {
    @State private var gameScene = DinoGameScene(
        size: CGSize(width: 900, height: 500)
    )

    var body: some View {
        ZStack {
            GameViewTheme.background

            SpriteView(scene: gameScene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Permainan Dino Jumping")
        }
        .ignoresSafeArea()
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
