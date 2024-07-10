//
//  LaserSyncApp.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

@main
struct LaserSyncApp: App {
    @StateObject private var laserConfig = LaserConfig()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(laserConfig)
        }
    }
}
