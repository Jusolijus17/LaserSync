//
//  ContentView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sharedStates = SharedStates()
    
    var body: some View {
        TabView(selection: $sharedStates.activeTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            ColorSelectionView()
                .tabItem {
                    Label("Color", systemImage: "paintbrush")
                }
                .tag(1)
            
            CuePadView()
                .tabItem {
                    Label("CuePad", systemImage: "square.grid.3x3.fill")
                }
                .tag(2)
            
            ModeControlView()
                .tabItem {
                    Label("Mode", systemImage: "slider.horizontal.3")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .environmentObject(sharedStates)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaserConfig())
    }
}


