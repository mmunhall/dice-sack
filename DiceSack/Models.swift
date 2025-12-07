//
//  Die.swift
//  Dice Sack
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
    
    @Transient
    var isAnimating: Bool = false
    
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
    
    func animateRoll(completion: @escaping () -> Void) {
        guard !locked else {
            completion()
            return
        }
        
        // Generate random start delay (0-0.25s) and duration (0.5-1.0s)
        let startDelay = Double.random(in: 0.0...0.25)
        let duration = Double.random(in: 0.5...1.0)
        
        // Set isAnimating to true at start
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) { [weak self] in
            guard let self = self else {
                completion()
                return
            }
            
            self.isAnimating = true
            
            // Cycle through random pip values during animation
            let animationSteps = 10
            let stepDuration = duration / Double(animationSteps)
            
            var currentStep = 0
            
            func animateStep() {
                if currentStep < animationSteps {
                    self.value = Int.random(in: 1...self.sides)
                    currentStep += 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                        animateStep()
                    }
                } else {
                    // Final roll to set the actual result
                    self.roll()
                    self.isAnimating = false
                    completion()
                }
            }
            
            animateStep()
        }
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
