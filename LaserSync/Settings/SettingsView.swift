//
//  SettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-16.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        NavigationView {
            VStack {
                // Section principale avec deux grandes rangées (Laser et Moving Head)
                VStack(spacing: 20) {
                    NavigationLink(destination: LaserSettings()) {
                        settingsRow(title: "Laser", imageName: "laser_icon")
                    }
                    
                    NavigationLink(destination: MovingHeadSettings().environmentObject(motionManager)) {
                        settingsRow(title: "Moving Head", imageName: "moving_head_icon")
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                
                Spacer()
                
                NavigationLink(destination: ServerSettings()) {
                    Text("Server settings")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom)
            }
            .navigationTitle("Settings")
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }

    // Vue pour une rangée de réglages avec une image
    private func settingsRow(title: String, imageName: String) -> some View {
        HStack {
            // Image PNG à gauche
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Divider()
                .frame(height: 50)
                .padding(.trailing, 5)

            // Texte du titre
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
            
            Image(systemName: "chevron.forward")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    SettingsView()
        .environmentObject(LaserConfig())
}
