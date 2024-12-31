//
//  LaserCueSetup.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-17.
//

import SwiftUI

struct LaserCueSetup: View {
    @Binding var cue: Cue
    var onNext: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Set Mode")
                        .font(.title2)
                        .padding(.bottom)
                    
                    // Mode
                    ModeSelector(selectedMode: $cue.laser.mode)
                        .padding(.bottom)
                    
                    Group {
                        SettingToggle(settings: $cue.laserSettings, setting: .color, label: "Set Color")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(LaserColor.allCases) { laserColor in
                                    if laserColor != .multicolor {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(laserColor.colorValue)
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                if cue.laser.color == laserColor {
                                                    Image(systemName: "checkmark")
                                                        .fontWeight(.semibold)
                                                        .font(.title)
                                                }
                                            }
                                            .onTapGesture {
                                                cue.laser.color = laserColor
                                            }
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .multicolor()
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                if cue.laser.color == laserColor {
                                                    Image(systemName: "checkmark")
                                                        .fontWeight(.semibold)
                                                        .font(.title)
                                                }
                                            }
                                            .onTapGesture {
                                                cue.laser.color = laserColor
                                            }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .disabledStyle(cue.laser.bpmSyncModes.contains(.color) || !cue.laserSettings.contains(.color))
                        
                        Button {
                            toggleBpmSyncFor(.color)
                        } label: {
                            Label("BPM Sync", systemImage: "circlebadge.2.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.laser.bpmSyncModes.contains(.color) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.laserSettings.contains(.color))
                        
                        // Pattern
                        SettingToggle(settings: $cue.laserSettings, setting: .pattern, label: "Set Pattern")
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                            ForEach(LaserPattern.allCases) { laserPattern in
                                Button(action: {
                                    if cue.laser.bpmSyncModes.contains(.pattern) {
                                        togglePatternInclusion(laserPattern)
                                    } else {
                                        cue.laser.pattern = laserPattern
                                    }
                                }) {
                                    laserPattern.shape
                                        .foregroundStyle(.white)
                                        .padding(20)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .background(getBackgroundColor(laserPattern))
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.laserSettings.contains(.pattern))
                        
                        // Pattern Sync
                        Button {
                            toggleBpmSyncFor(.pattern)
                        } label: {
                            Label("BPM Sync", systemImage: "circlebadge.2.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.laser.bpmSyncModes.contains(.pattern) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.laserSettings.contains(.pattern))
                        
                        // Strobe
                        SettingToggle(settings: $cue.laserSettings, setting: .strobe, label: "Strobe")
                        
                        Button {
                            toggleStrobeMode()
                        } label: {
                            Label("Strobe", systemImage: "circle.dotted.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.includedLightStrobe.contains(.laser) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.laserSettings.contains(.strobe))
                        
                        // Vertical Adjust
                        SettingToggle(settings: $cue.laserSettings, setting: .vAdjust, label: "Vertical Adjust")
                        
                        HStack {
                            Slider(value: $cue.laser.verticalAdjust, in: 31...95, step: 1)
                                .disabled(!cue.laserSettings.contains(.vAdjust))
                            Text("\(Int(cue.laser.verticalAdjust - 63))%")
                                .frame(width: 50)
                        }
                        .padding(.bottom)
                        
                        // H-Animation
                        SettingToggle(settings: $cue.laserSettings, setting: .hAnimation, label: "Horizontal Animation")
                        
                        HStack {
                            Slider(value: $cue.laser.horizontalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!cue.laserSettings.contains(.hAnimation))
                                .onChange(of: cue.laser.horizontalAnimationSpeed) { _, newValue in
                                    if newValue > 127 {
                                        cue.laser.horizontalAnimationEnabled = true
                                    } else {
                                        cue.laser.horizontalAnimationEnabled = false
                                    }
                                }
                            Text("\(Int(cue.laser.horizontalAnimationSpeed) - 127)%")
                                .frame(width: 40)
                        }
                        .padding(.bottom)
                        
                        // V-Animation
                        SettingToggle(settings: $cue.laserSettings, setting: .vAnimation, label: "Vertical Animation")
                        
                        HStack {
                            Slider(value: $cue.laser.verticalAnimationSpeed, in: 127...190, step: 1)
                                .disabled(!cue.laserSettings.contains(.vAnimation))
                                .onChange(of: cue.laser.verticalAnimationSpeed) { _, newValue in
                                    if newValue > 127 {
                                        cue.laser.verticalAnimationEnabled = true
                                    } else {
                                        cue.laser.verticalAnimationEnabled = false
                                    }
                                }
                            Text("\(Int(cue.laser.verticalAnimationSpeed) - 127)%")
                                .frame(width: 40)
                        }
                        .padding(.bottom)
                        
                    }
                    .disabledStyle(cue.laser.mode != .manual)
                }
                .padding()
                .padding(.bottom, 65)
            }
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .background()
        }
    }
    
    private func toggleStrobeMode() {
        if cue.includedLightStrobe.contains(.laser) {
            cue.includedLightStrobe.remove(.laser)
        } else {
            cue.includedLightStrobe.insert(.laser)
        }
    }
    
    private func toggleBpmSyncFor(_ mode: BPMSyncMode) {
        if !cue.laser.bpmSyncModes.contains(mode) {
            cue.laser.bpmSyncModes.insert(mode)
        } else {
            cue.laser.bpmSyncModes.remove(mode)
        }
    }
    
    func getBackgroundColor(_ pattern: LaserPattern) -> Color {
        if cue.laser.bpmSyncModes.contains(.pattern) && cue.laser.includedPatterns.contains(pattern) {
            return .green
        } else if cue.laser.pattern == pattern {
            return .green
        } else {
            return .gray
        }
    }
    
    func togglePatternInclusion(_ pattern: LaserPattern) {
        if cue.laser.includedPatterns.contains(pattern) && cue.laser.includedPatterns.count > 2 {
            cue.laser.includedPatterns.remove(pattern)
        } else {
            cue.laser.includedPatterns.insert(pattern)
        }
    }
}

struct LaserCueSetupPreview: View {
    @State private var cue = Cue.preview()
    var body: some View {
        LaserCueSetup(cue: $cue, onNext: {})
    }
}

#Preview {
    NavigationView {
        LaserCueSetupPreview()
            .navigationTitle("Laser")
            .navigationBarTitleDisplayMode(.inline)
    }
}
