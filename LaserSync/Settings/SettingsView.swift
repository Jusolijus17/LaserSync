//
//  SettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-16.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var motionManager = MotionManager()
    @EnvironmentObject private var sharedStates: SharedStates
    
    var body: some View {
        NavigationStack {
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
                    ) {
                        settingsRow(title: "Moving Head") {
                            Image("moving_head_icon")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    Button {
                        sharedStates.showCueMaker = true
                    } label: {
                        settingsRow(title: "Cue Maker") {
                            LaunchpadButton(color: .red)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .navigationDestination(isPresented: $sharedStates.showCueMaker, destination: {CueMakerView()})
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

#Preview {
    SettingsView()
        .environmentObject(LaserConfig())
        .environmentObject(SharedStates())
}
