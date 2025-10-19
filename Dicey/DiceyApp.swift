//
//  DiceyApp.swift
//  Dicey
//
//  Created by Mike Munhall on 7/26/25.
//

import SwiftUI
import SwiftData

@main
struct DiceyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DiceGroup.self)
    }
}
