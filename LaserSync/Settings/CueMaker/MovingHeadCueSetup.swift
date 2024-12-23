//
//  MovingHeadCueSetup.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-17.
//

import SwiftUI

struct MovingHeadCueSetup: View {
    @Binding var cue: Cue
    @State private var positionPresets: [GyroPreset] = GyroPreset.loadPresets()
    var onNext: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Set Mode")
                        .font(.title2)
                        .padding(.bottom)
                    
                    // Mode
                    HStack {
                        ForEach(MovingHeadMode.allCases.reversed()) { mode in
                            Button(action: {
                                cue.movingHeadMode = mode
                            }) {
                                Text(mode.rawValue.capitalized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(cue.movingHeadMode == mode ? Color.green : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Group {
                        // Scene
                        Group {
                            Text("Set Scene")
                                .font(.title2)
                                .padding(.bottom)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                                ForEach(MovingHeadScene.allCases.reversed()) { scene in
                                    Button(action: {
                                        cue.positionPreset = nil
                                        cue.movingHeadScene = scene
                                    }) {
                                        Text(scene.rawValue.capitalized)
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .padding(20)
                                            .frame(height: 50)
                                            .frame(maxWidth: .infinity)
                                            .background(getBackgroundColor(scene))
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .disabled(cue.positionPreset != nil)
                        .opacity(cue.positionPreset != nil ? 0.5 : 1.0)
                        
                        Group {
                            // Position
                            Text("Set Position")
                                .font(.title2)
                                .padding(.bottom)
                            
                            Menu {
                                Button {
                                    cue.positionPreset = nil
                                } label: {
                                    Text("Off")
                                }
                                
                                // Options pour chaque preset
                                ForEach(positionPresets) { preset in
                                    Button {
                                        cue.movingHeadScene = .off
                                        cue.positionPreset = preset
                                    } label: {
                                        Text(preset.name)
                                    }
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color(UIColor.secondarySystemBackground))
                                    .frame(height: 50)
                                    .overlay {
                                        HStack {
                                            Text(cue.positionPreset?.name ?? "Off")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                        }
                                        .padding()
                                    }
                            }
                            .padding(.bottom)
                        }
                        .disabled(cue.movingHeadScene != .off)
                        .opacity(cue.movingHeadScene != .off ? 0.5 : 1.0)
                        
                        // Color
                        Text("Set Color")
                            .font(.title2)
                            .padding(.bottom)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(MovingHeadColor.allCases) { movingHeadColor in
                                    if movingHeadColor != .auto {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(movingHeadColor.color)
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                if cue.movingHeadColor == movingHeadColor {
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(movingHeadColor == .white ? .black : .white)
                                                        .fontWeight(.semibold)
                                                        .font(.title)
                                                }
                                            }
                                            .onTapGesture {
                                                cue.movingHeadColor = movingHeadColor
                                            }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .disabled(cue.movingHeadColorFrequency != 0)
                        .opacity(cue.movingHeadColorFrequency != 0 ? 0.5 : 1.0)
                        
                        CustomSliderView(sliderValue: $cue.movingHeadColorFrequency, title: "Speed")
                            .padding(.bottom)
                        
                        // Strobe
                        Text("Set Strobe")
                            .font(.title2)
                            .padding(.bottom)
                        
                        CustomSliderView(sliderValue: $cue.movingHeadStrobeFrequency, title: "Intensity")
                            .padding(.bottom)
                        
                        // Light Intensity
                        Text("Set Brightness")
                            .font(.title2)
                            .padding(.bottom)
                        
                        CustomSliderView(sliderValue: $cue.movingHeadBrightness, title: "Brightness")
                            .padding(.bottom)
                    }
                    .disabled(cue.movingHeadMode != .manual)
                    .opacity(cue.movingHeadMode != .manual ? 0.5 : 1.0)
                }
                .padding()
                .padding(.bottom, 50)
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
    
    func getBackgroundColor(_ scene: MovingHeadScene) -> Color {
        if cue.movingHeadScene != scene {
            return .gray
        }
        switch scene {
        case .slow:
            return .green
        case .medium:
            return .yellow
        case .fast:
            return .red
        case .off:
            return .blue
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

struct MovingHeadCueSetupPreview: View {
    @State private var cue = Cue.preview()
    var body: some View {
        MovingHeadCueSetup(cue: $cue, onNext: {})
    }
}

#Preview {
    NavigationView {
        MovingHeadCueSetupPreview()
            .navigationTitle("Moving Head")
            .navigationBarTitleDisplayMode(.inline)
    }
}
