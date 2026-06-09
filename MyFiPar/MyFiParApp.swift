//
//  MyFiParApp.swift
//  MyFiPar
//
//  Created by Miller A on 5/21/26.
//

import SwiftUI
import SwiftData

@main
struct MyFiParApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Goal.self])
    }
}
