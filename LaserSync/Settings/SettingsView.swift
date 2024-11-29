//
//  SettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-16.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var motionManager = MotionManager()
    @StateObject private var roomModel = RoomModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Section principale avec deux grandes rangées (Laser et Moving Head)
                VStack(spacing: 20) {
                    NavigationLink(destination: LaserSettings()) {
                        settingsRow(title: "Laser") {
                            Image("laser_icon")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    NavigationLink(destination:
                                    MovingHeadSettings()
                        .environmentObject(motionManager)
                        .environmentObject(roomModel)
                    ) {
                        settingsRow(title: "Moving Head") {
                            Image("moving_head_icon")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    NavigationLink(destination: CueMakerView()) {
                        settingsRow(title: "Cue Maker") {
                            LaunchpadButton(color: .red)
                                .frame(width: 40, height: 40)
                        }
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
    private func settingsRow<Content: View>(title: String, iconView: @escaping () -> Content) -> some View {
        HStack {
            // Vue personnalisée à gauche
            iconView()
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

struct LaunchpadButton: View {
    var color: Color // La couleur du bouton

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ombre périphérique (halo lumineux)
                RoundedRectangle(cornerRadius: geometry.size.width / 6) // Calcul dynamique du rayon
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0)]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .blur(radius: geometry.size.width / 10)
                
                // Bouton principal
                RoundedRectangle(cornerRadius: geometry.size.width / 6) // Même arrondi
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.5)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .shadow(color: color.opacity(0.5), radius: geometry.size.width / 10, x: 0, y: 4)
            }
        }
        .aspectRatio(1, contentMode: .fit) // Assure que le bouton reste carré
    }
}

#Preview {
    SettingsView()
        .environmentObject(LaserConfig())
}
