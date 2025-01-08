//
//  SpiderHeadSettings.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-03.
//

import SwiftUI

struct SpiderHeadSettings: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @EnvironmentObject var motionManager: MotionManager
    
    var body: some View {
        Form {
            Section(header: Text("Control").font(.headline)) {
                NavigationLink(destination: ShPrecisionControlView()) {
                    Text("Precision control")
                }
            }
            Section(header: Text("Settings").font(.headline)) {
                NavigationLink(destination: ShPresetManagerView()) {
                    Text("Preset manager")
                }
            }
        }
        .navigationTitle("Spider Head")
    }
}

#Preview {
    NavigationView {
        SpiderHeadSettings()
            .environmentObject(LaserConfig())
            .environmentObject(MotionManager())
    }
}
