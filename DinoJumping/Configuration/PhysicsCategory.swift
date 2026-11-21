//
//  PhysicsCategory.swift
//  DinoJumping
//
//  Created by Yuhaya Lissera on 21/11/26.
//

enum PhysicsCategory {
    static let player: UInt32 = 1 << 0
    static let ground: UInt32 = 1 << 1
    static let obstacle: UInt32 = 1 << 2
}
