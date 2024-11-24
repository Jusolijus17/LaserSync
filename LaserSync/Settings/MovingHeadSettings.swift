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
                NavigationLink(destination: GyroControlView()
                    .environmentObject(motionManager)) {
                    Text("Gyro control")
                }
                NavigationLink(destination: Text("Test")) {
                    Text("3D mapper (experimental)")
                }
            }
        }
        .navigationTitle("Moving Head")
    }
}

#Preview {
    MovingHeadSettings()
}


