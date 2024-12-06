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
    @EnvironmentObject var roomModel: RoomModel
    
    var body: some View {
        Form {
            Section(header: Text("Control").font(.headline)) {
                NavigationLink(destination: GyroControlView().environmentObject(motionManager)) {
                    Text("Gyro control")
                }
                NavigationLink(destination: RoomSetupView().environmentObject(roomModel)) {
                    Text("3D mapper (experimental)")
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
            .environmentObject(RoomModel())
    }
}


