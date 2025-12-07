//
//  DieView.swift
//  Dice Sack
//
//  Created by Mike Munhall on 7/26/25.
//

import SwiftUI

struct DieView: View {

    let die: Die
    let turnActive: Bool
    let onTap: () -> Void

    private let pipPositions: [Int: [(x: CGFloat, y: CGFloat)]] = [
        1: [(0, 0)],
        2: [(-10, -10), (10, 10)],
        3: [(-10, -10), (0, 0), (10, 10)],
        4: [(-10, -10), (10, -10), (-10, 10), (10, 10)],
        5: [(-10, -10), (10, -10), (0, 0), (-10, 10), (10, 10)],
        6: [(-10, -10), (10, -10), (-10, 0), (10, 0), (-10, 10), (10, 10)]
    ]

    private var dieShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
    }

    var body: some View {
        ZStack {
            ForEach(Array(pipPositions[die.value, default: [(0, 0)]].enumerated()), id: \.offset) { _, position in
                Circle()
                    .frame(width: 9, height: 9)
                    .foregroundStyle(.black)
                    .offset(x: position.x, y: position.y)
            }
        }
        .animation(.easeOut, value: die.value)
        .frame(width: 50, height: 50)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .background(dieShape.fill(turnActive && die.locked ? .gray : .white))
        .overlay(dieShape.stroke(.black, lineWidth: 2))
        .compositingGroup()
        .shadow(radius: 5, x: 5, y: 5)
    }
    
    init(_ die: Die, turnActive: Bool = true, onTap: @escaping () -> Void = {}) {
        self.die = die
        self.turnActive = turnActive
        self.onTap = onTap
    }
}

#Preview {
    DieView(Die(sides: 6, value: 6, locked: false))
}
