//
//  Die.swift
//  Dicey
//
//  Created by Mike Munhall on 7/28/25.
//

import Foundation
import SwiftData

@Model
class Die {
    var id: UUID = UUID()
    private(set) var sides: Int
    private(set) var value: Int
    private(set) var locked: Bool
    
    init(sides: Int) {
        self.sides = sides
        self.value = 1
        self.locked = false
        roll()
    }
    
    init(sides: Int, value: Int, locked: Bool) {
        self.sides = sides
        self.value = value
        self.locked = locked
    }
    
    func roll() {
        guard !locked else { return }
        self.value = Int.random(in: 1...self.sides)
    }
    
    func lock() {
        self.locked = true
    }
    
    func toggleLock() {
        self.locked.toggle()
    }
    
    #if DEBUG
    static let example: Die = .init(sides: 6)
    #endif
}

@Model
class DiceGroup {
    @Relationship(deleteRule: .cascade)
    
    var dice: [Die]
    var date: Date
    
    init(_ dice: [Die]) {
        self.dice = dice
        self.date = .now
    }
    
    func rollAll() {
        for die in dice {
            die.roll()
        }
    }
    
    #if DEBUG
    static let example: DiceGroup = .init([.init(sides: 6), .init(sides: 6), .init(sides: 6), .init(sides: 6), .init(sides: 6), .init(sides: 6)])
    #endif
}
