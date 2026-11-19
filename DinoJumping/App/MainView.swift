import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var gameScene = DinoGameScene(size: CGSize(width: 900, height: 500))

    var body: some View {
        VStack(spacing: 12) {
            SpriteView(scene: gameScene)
                .aspectRatio(1.8, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                gameScene.jump()
            } label: {
                Text("MULAI / LOMPAT")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(Color(red: 0.10, green: 0.06, blue: 0.22))
                    .background(Color(red: 1.0, green: 0.82, blue: 0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .accessibilityLabel("Lompat")
        }
        .padding(.vertical, 12)
        .background(Color(red: 0.10, green: 0.06, blue: 0.22))
    }
}

#Preview {
    ContentView()
}
