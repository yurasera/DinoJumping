//
//  GameOverlay.swift
//  DinoJumping
//
//  Created by Yuhaya Lissera on 21/11/26.
//
import SwiftUI

struct GameOverlay: View {

    let gameState: GameState
    let startGame: () -> Void
    let restartGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                switch gameState {
                case .ready:
                    Text("DINO JUMPING")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Hindari obstacle dengan melompat.")

                    Button("MULAI", action: startGame)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                case .gameOver:
                    Text("GAME OVER")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Button("RESTART", action: restartGame)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                case .playing:
                    EmptyView()
                }
            }
            .foregroundStyle(.white)
        }
    }
}
