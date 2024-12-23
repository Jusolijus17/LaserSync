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
        VStack(alignment: .leading, spacing: 0) {
            Text("Set Mode")
                .font(.title2)
                .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(LaserMode.allCases) { mode in
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
                Text("Set Color")
                    .font(.title2)
                    .padding(.bottom)
                
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
                .disabled(cue.laserBPMSyncModes.contains(.color))
                .opacity(cue.laserBPMSyncModes.contains(.color) ? 0.5 : 1.0)
                
                Toggle(isOn: makeBPMSyncBinding(for: .color)) {
                    Text("BPM Sync")
                }
                .padding(.bottom)
                
                Text("Set Pattern")
                    .font(.title2)
                    .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
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
                
                Toggle(isOn: makeBPMSyncBinding(for: .pattern)) {
                    Text("BPM Sync")
                }
                .padding(.bottom)
            }
            .disabled(cue.laserMode != .manual)
            .opacity(cue.laserMode != .manual ? 0.5 : 1.0)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
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
        if cue.laserIncludedPatterns.contains(pattern) && cue.laserIncludedPatterns.count > 1 {
            cue.laserIncludedPatterns.remove(pattern)
        } else {
            cue.laserIncludedPatterns.insert(pattern)
        }
    }
    
    private func makeBPMSyncBinding(for mode: BPMSyncMode) -> Binding<Bool> {
        Binding<Bool>(
            get: { cue.laserBPMSyncModes.contains(mode) },
            set: { newValue in
                if newValue {
                    cue.laserBPMSyncModes.append(mode)
                } else {
                    cue.laserBPMSyncModes.removeAll { $0 == mode }
                }
            }
        )
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
