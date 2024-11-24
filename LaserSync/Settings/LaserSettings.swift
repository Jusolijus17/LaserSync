//
//  AdvancedSettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

struct LaserSettings: View {
    @EnvironmentObject var laserConfig: LaserConfig

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Adjustments").font(.headline)) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Vertical Adjust")
                        HStack {
                            Slider(value: $laserConfig.verticalAdjust, in: 31...95, step: 1)
                            Button(action: laserConfig.resetVerticalAdjust) {
                                Text("Reset")
                                    .frame(width: 50, height: 40)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .font(.caption)
                            }
                        }
                    }
                }

                Section(header: animationsHeader) {
                    VStack(alignment: .leading, spacing: 15) {
                        Toggle("Horizontal Animation", isOn: $laserConfig.horizontalAnimationEnabled)

                        HStack {
                            Slider(value: $laserConfig.horizontalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!laserConfig.horizontalAnimationEnabled)
                            Text("\(Int(laserConfig.horizontalAnimationSpeed))%")
                                .frame(width: 50)
                        }
                        
                        Divider()

                        Toggle("Vertical Animation", isOn: $laserConfig.verticalAnimationEnabled)

                        HStack {
                            Slider(value: $laserConfig.verticalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!laserConfig.verticalAnimationEnabled)
                            Text("\(Int(laserConfig.verticalAnimationSpeed))%")
                                .frame(width: 50)
                        }
                    }
                }
            }
        }
        .navigationTitle("Laser")
    }

    private var animationsHeader: some View {
        HStack {
            Text("Animations").font(.headline)
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(laserConfig.horizontalAnimationEnabled || laserConfig.verticalAnimationEnabled ? .yellow : .gray)
        }
    }
}

#Preview {
    LaserSettings()
        .environmentObject(LaserConfig())
}
