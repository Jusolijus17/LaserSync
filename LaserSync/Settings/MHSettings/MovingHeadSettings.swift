//
//  MovingHeadSettings.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-16.
//

import SwiftUI

struct MovingHeadSettings: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @EnvironmentObject var motionManager: MotionManager
    
    var body: some View {
        Form {
            Section(header: Text("Control").font(.headline)) {
                NavigationLink(destination: GyroControlView().environmentObject(motionManager)) {
                    Text("Gyro control")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("Precision control")
                }
            }
            Section(header: Text("Settings").font(.headline)) {
                NavigationLink(destination: PresetManagerView()) {
                    Text("Preset manager")
                }
            }
        }
        .navigationTitle("Moving Head")
    }
}

#Preview {
    NavigationView {
        MovingHeadSettings()
            .environmentObject(LaserConfig())
            .environmentObject(MotionManager())
    }
}


