//
//  CueSettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-20.
//

import SwiftUI

struct CueSettingsView: View {
    @EnvironmentObject private var sharedStates: SharedStates
    @EnvironmentObject private var laserConfig: LaserConfig

    var body: some View {
        Form {
            NavigationLink(destination: EditCueView()) {
                Text("Edit cues")
            }
            
            Toggle("Show cue labels", isOn: Binding<Bool>(
                get: { sharedStates.showCueLabels },
                set: { newValue in
                    sharedStates.setShowCueLabels(newValue)
                }
            ))
            Toggle("Breathe Mode: \(laserConfig.breatheMode == .fast ? "Fast" : "Slow")", isOn: Binding(
                get: { laserConfig.breatheMode == .fast },
                set: {
                    laserConfig.breatheMode = $0 ? .fast : .slow
                    laserConfig.setSlowBreathe(mode: laserConfig.breatheMode)
                }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .padding(.top)
        .navigationTitle("Cue settings")
    }
}

#Preview {
    NavigationView {
        CueSettingsView()
            .environmentObject(SharedStates())
            .environmentObject(LaserConfig())
    }
}
