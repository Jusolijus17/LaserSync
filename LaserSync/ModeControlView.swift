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
            
            LightImage(light: .all, selectable: true, selection: $selectedLights)
            
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
            
            // Strobe mode
            Button(action: {
                hapticFeedback()
                toggleStrobeMode()
            }) {
                Text("Strobe")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(isStrobeActive() ? Color.yellow : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom)
        }
    }
    
    func change(_ mode: LightMode) {
        if selectedLights.contains(.laser) {
            laserConfig.laser.mode = mode
            laserConfig.setModeFor(.laser, mode: mode)
        }
        if selectedLights.contains(.movingHead) {
            if mode == .blackout {
                laserConfig.turnOffMovingHead()
            } else {
                laserConfig.movingHead.mode = mode
                laserConfig.setModeFor(.movingHead, mode: mode)
            }
            
        }
        if selectedLights.contains(.spiderHead) {
            laserConfig.spiderHead.mode = mode
            laserConfig.setModeFor(.spiderHead, mode: mode)
        }
    }
    
    func toggleStrobeMode() {
        let shouldActivateStrobe = selectedLights.contains { !laserConfig.includedLightsStrobe.contains($0) }
        for light in selectedLights {
            if shouldActivateStrobe {
                laserConfig.includedLightsStrobe.insert(light)
            } else {
                laserConfig.includedLightsStrobe.remove(light)
            }
        }
        laserConfig.setStrobeMode()
    }
    
    private func isModeEnabled(mode: LightMode) -> Bool {
        guard !selectedLights.isEmpty else { return false }
        let selectedLightsModes = selectedLights.map { light in
            laserConfig.mode(for: light)
        }
        return selectedLightsModes.allSatisfy { $0 == mode }
    }
    
    private func isStrobeActive() -> Bool {
        return selectedLights.isSubset(of: laserConfig.includedLightsStrobe) && !selectedLights.isEmpty
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

