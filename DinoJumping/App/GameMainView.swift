import SwiftUI

struct GameMainView: View {

    var body: some View {
        GameViewTheme.background
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
