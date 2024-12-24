//
//  ModeControlView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

struct ModeControlView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @State private var selectedLights: Set<Light> = []
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            LightImage(light: .both, selectable: true)
                .onSelectionChange { lights in
                    hapticFeedback()
                    self.selectedLights = lights
                }
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(LightMode.allCases) { mode in
                    Button(action: {
                        hapticFeedback()
                        change(mode)
                    }) {
                        Text(mode.rawValue.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(isModeEnabled(mode: mode) ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                hapticFeedback()
                laserConfig.toggleStrobeModeFor(.laser)
                laserConfig.toggleStrobeModeFor(.movingHead)
            }) {
                Text("Strobe")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(!laserConfig.includedLightsStrobe.isEmpty ? Color.yellow : Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom)
        }
    }
    
    func change(_ mode: LightMode) {
        if selectedLights.contains(.laser) {
            laserConfig.laserMode = mode
            laserConfig.setModeFor(.laser)
        }
        if selectedLights.contains(.movingHead) {
            laserConfig.mHMode = mode
            laserConfig.setModeFor(.movingHead)
        }
    }
    
    private func isModeEnabled(mode: LightMode) -> Bool {
        if selectedLights.contains(.movingHead) && selectedLights.contains(.laser) {
            if laserConfig.laserMode == laserConfig.mHMode {
                return laserConfig.laserMode == mode
            } else {
                return false
            }
        } else if selectedLights.contains(.laser) {
            return laserConfig.laserMode == mode
        } else if selectedLights.contains(.movingHead) {
            return laserConfig.mHMode == mode
        }
        return false
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct ModeControlView_Previews: PreviewProvider {
    static var previews: some View {
        ModeControlView()
            .environmentObject(LaserConfig())
    }
}

