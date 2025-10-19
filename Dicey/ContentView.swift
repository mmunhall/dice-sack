//
//  ContentView.swift
//  Dicey
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
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.green)
                    .ignoresSafeArea()
                
                VStack {
                    LazyVGrid(columns: columns) {
                        ForEach(diceGroup.dice) { die in
                            DieView(die)
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
                    
                    Button() {
                        endTurn()
                    } label: {
                        Text("End Turn")
                            .font(.title3)
                    }
                    .buttonStyle(.bordered)
                    
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
        diceGroup.rollAll()
    }
    
    func newTurn() {
        var dice = [Die]()
        for _ in 1...numDice {
            dice.append(Die(sides: 6))
        }
        diceGroup = DiceGroup(dice)
    }
    
    func endTurn() {
        modelContext.insert(diceGroup)
        // newTurn()
    }
}

#Preview {
    ContentView()
}
