//
//  CueSettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-20.
//

import SwiftUI

struct CueSettingsView: View {
    @EnvironmentObject private var sharedStates: SharedStates

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
        }
        .padding(.top)
        .navigationTitle("Cue settings")
    }
}

#Preview {
    NavigationView {
        CueSettingsView()
            .environmentObject(SharedStates())
    }
}
