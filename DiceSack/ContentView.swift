//
//  ContentView.swift
//  Dice Sack
//
//  Created by Mike Munhall on 7/26/25.
//
//
import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State private var showingHistory = false
    @State private var numDice: Int = 6
    @State private var diceGroup = DiceGroup([])
    @State private var turnActive = true
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    // Computed property to check if any die is animating
    var isAnyDieAnimating: Bool {
        diceGroup.dice.contains { $0.isAnimating }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.green)
                    .ignoresSafeArea()
                
                VStack {
                    LazyVGrid(columns: columns) {
                        ForEach(diceGroup.dice) { die in
                            DieView(die, turnActive: turnActive, onTap: {
                                die.toggleLock()
                            })
                        }
                    }
                    .padding()


                    Button() {
                        rollAll()
                    } label: {
                        Text("Roll")
                            .font(.largeTitle)
                    }
                    .buttonStyle(.borderedProminent)
                    .opacity(turnActive && !isAnyDieAnimating ? 1 : 0.5)
                    .disabled(!turnActive || isAnyDieAnimating)

                    Button() {
                        if turnActive {
                            endTurn()
                        } else {
                            newTurn()
                        }
                    } label: {
                        Text(turnActive ? "End Turn" : "New Turn")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    .opacity(isAnyDieAnimating ? 0.5 : 1)
                    .disabled(isAnyDieAnimating)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("History", systemImage: "dice.fill") {
                            showingHistory = true
                        }
                    }
                }
                .sheet(isPresented: $showingHistory) {
                    RollHistoryView()
                }
            }
        }
        .onAppear {
            newTurn()
        }
    }
    
    func rollAll() {
        diceGroup.rollAllWithAnimation {
            // Trigger view update to re-enable buttons
            // The view will automatically update when isAnyDieAnimating changes
        }
    }
    
    func newTurn() {
        var dice = [Die]()
        for _ in 1...numDice {
            dice.append(Die(sides: 6))
        }
        diceGroup = DiceGroup(dice)
        turnActive = true
    }
    
    func endTurn() {
        modelContext.insert(diceGroup)
        turnActive = false
    }
}

#Preview {
    ContentView()
}
