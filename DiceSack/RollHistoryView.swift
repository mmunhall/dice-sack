//
//  RollHistoryView.swift
//  Dice Sack
//
//  Created by Mike Munhall on 7/30/25.
//

import SwiftUI
import SwiftData

struct RollHistoryView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DiceGroup.date, order: .reverse) var rolls: [DiceGroup]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
            
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(rolls) { roll in
                        ForEach(roll.dice) { die in
                            DieView(die, turnActive: false)
                        }
                    }
                }
                .padding()
            }
            .background(.green.opacity(0.7))
            .toolbarBackground(.green.opacity(0.7), for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Clear history") {
                        for roll in rolls {
                            modelContext.delete(roll)
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RollHistoryView()
}
