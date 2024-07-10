//
//  ContentView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            LaserColorView()
                .tabItem {
                    Label("Color", systemImage: "paintbrush")
                }
            
            PatternControlView()
                .tabItem {
                    Label("Pattern", systemImage: "rectangle.3.offgrid")
                }
            
            ModeControlView()
                .tabItem {
                    Label("Mode", systemImage: "slider.horizontal.3")
                }
            
            AdvancedSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
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


