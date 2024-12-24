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
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                        ForEach(LightMode.allCases) { mode in
                            Button(action: {
                                cue.laserMode = mode
                            }) {
                                Text(mode.rawValue.capitalized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(cue.laserMode == mode ? Color.green : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Group {
                        SettingToggle(settings: $cue.laserSettings, setting: .color, label: "Set Color")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(LaserColor.allCases) { laserColor in
                                    if laserColor != .multicolor {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(laserColor.color)
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                if cue.laserColor == laserColor {
                                                    Image(systemName: "checkmark")
                                                        .fontWeight(.semibold)
                                                        .font(.title)
                                                }
                                            }
                                            .onTapGesture {
                                                cue.laserColor = laserColor
                                            }
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .multicolor()
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                if cue.laserColor == laserColor {
                                                    Image(systemName: "checkmark")
                                                        .fontWeight(.semibold)
                                                        .font(.title)
                                                }
                                            }
                                            .onTapGesture {
                                                cue.laserColor = laserColor
                                            }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .disabledStyle(cue.laserBPMSyncModes.contains(.color) || !cue.laserSettings.contains(.color))
                        
                        Button {
                            toggleBpmSyncFor(.color)
                        } label: {
                            Label("BPM Sync", systemImage: "circlebadge.2.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.laserBPMSyncModes.contains(.color) ? Color.yellow : Color.gray)
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
                                    if cue.laserBPMSyncModes.contains(.pattern) {
                                        togglePatternInclusion(laserPattern)
                                    } else {
                                        cue.laserPattern = laserPattern
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
                        
                        Button {
                            toggleBpmSyncFor(.pattern)
                        } label: {
                            Label("BPM Sync", systemImage: "circlebadge.2.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.laserBPMSyncModes.contains(.pattern) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.laserSettings.contains(.pattern))
                        
                    }
                    .disabledStyle(cue.laserMode != .manual)
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
    
    private func toggleBpmSyncFor(_ mode: BPMSyncMode) {
        if !cue.laserBPMSyncModes.contains(mode) {
            cue.laserBPMSyncModes.insert(mode)
        } else {
            cue.laserBPMSyncModes.remove(mode)
        }
    }
    
    func getBackgroundColor(_ pattern: LaserPattern) -> Color {
        if cue.laserBPMSyncModes.contains(.pattern) && cue.laserIncludedPatterns.contains(pattern) {
            return .green
        } else if cue.laserPattern == pattern {
            return .green
        } else {
            return .gray
        }
    }
    
    func togglePatternInclusion(_ pattern: LaserPattern) {
        if cue.laserIncludedPatterns.contains(pattern) && cue.laserIncludedPatterns.count > 2 {
            cue.laserIncludedPatterns.remove(pattern)
        } else {
            cue.laserIncludedPatterns.insert(pattern)
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
