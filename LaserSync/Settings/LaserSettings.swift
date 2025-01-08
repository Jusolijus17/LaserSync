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
                            Slider(value: $laserConfig.laser.verticalAdjust, in: 31...95, step: 1)
                                .onChange(of: laserConfig.laser.verticalAdjust) {
                                    laserConfig.setVerticalAdjust()
                                }
                            Text("\(Int(laserConfig.laser.verticalAdjust - 63))%")
                                .frame(width: 50)
                        }
                        Button(action: laserConfig.resetVerticalAdjust) {
                            Text("Reset")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                Section(header: animationsHeader) {
                    VStack(alignment: .leading, spacing: 15) {
                        Toggle("Horizontal Animation", isOn: $laserConfig.laser.horizontalAnimationEnabled)
                            .onChange(of: laserConfig.laser.horizontalAnimationEnabled) {
                                laserConfig.setHorizontalAnimation()
                            }

                        HStack {
                            Slider(value: $laserConfig.laser.horizontalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!laserConfig.laser.horizontalAnimationEnabled)
                            Text("\(Int(laserConfig.laser.horizontalAnimationSpeed - 127))%")
                                .frame(width: 40)
                        }
                        .onChange(of: laserConfig.laser.horizontalAnimationSpeed) {
                            laserConfig.setHorizontalAnimation()
                        }
                        
                        Divider()

                        Toggle("Vertical Animation", isOn: $laserConfig.laser.verticalAnimationEnabled)
                            .onChange(of: laserConfig.laser.verticalAnimationEnabled) {
                                laserConfig.setVerticalAnimation()
                            }

                        HStack {
                            Slider(value: $laserConfig.laser.verticalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!laserConfig.laser.verticalAnimationEnabled)
                            Text("\(Int(laserConfig.laser.verticalAnimationSpeed - 127))%")
                                .frame(width: 40)
                        }
                        .onChange(of: laserConfig.laser.verticalAnimationSpeed) {
                            laserConfig.setVerticalAnimation()
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
                .foregroundStyle(laserConfig.laser.horizontalAnimationEnabled || laserConfig.laser.verticalAnimationEnabled ? .yellow : .gray)
        }
    }
}

#Preview {
    LaserSettings()
        .environmentObject(LaserConfig())
}
