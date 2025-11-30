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

    var body: some View {
        ZStack {
            switch die.value {
            case 1:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
            case 2:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -8, y: -8)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 8, y: 8)
            case 3:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: -10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: 10)

            case 4:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: -10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: -10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: 10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: 10)

            case 5:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: -10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: -10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: 10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: 10)

            case 6:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: -11)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: -11)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: -10, y: 11)

                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
                    .offset(x: 10, y: 11)

            default:
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.black)
            }
        }
        .frame(width: 50, height: 50)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .background(
            RoundedRectangle(
                cornerRadius: 5,
                style: .continuous
            )
            .stroke(.black, lineWidth: 3)
            .fill(turnActive && die.locked ? .gray : .white)
        )
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
