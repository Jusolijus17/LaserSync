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
                        Toggle("Horizontal Animation", isOn: $laserConfig.laser.horizontalAnimationEnabled)
                            .onChange(of: laserConfig.laser.horizontalAnimationEnabled) {
                                laserConfig.setHorizontalAnimation()
                            }

                        HStack {
                            Slider(value: $laserConfig.laser.horizontalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!laserConfig.laser.horizontalAnimationEnabled)
                            Text("\(Int(laserConfig.laser.horizontalAnimationSpeed))%")
                                .frame(width: 50)
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
                            Text("\(Int(laserConfig.laser.verticalAnimationSpeed))%")
                                .frame(width: 50)
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
