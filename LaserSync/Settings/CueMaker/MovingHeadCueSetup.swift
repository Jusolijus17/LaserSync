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
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                        ForEach(LightMode.allCases) { mode in
                            Button(action: {
                                cue.movingHead.mode = mode
                            }) {
                                Text(mode.rawValue.capitalized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(cue.movingHead.mode == mode ? Color.green : Color.gray)
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
                            SettingToggle(settings: $cue.movingHeadSettings, setting: .scene, label: "Set Scene")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                                ForEach(MovingHeadScene.allCases.reversed()) { scene in
                                    Button(action: {
                                        cue.movingHead.positionPreset = nil
                                        cue.movingHead.scene = scene
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
                            .disabledStyle(!cue.movingHeadSettings.contains(.scene))
                        }
                        .disabledStyle(cue.movingHead.positionPreset != nil)
                        
                        Group {
                            // Position
                            SettingToggle(settings: $cue.movingHeadSettings, setting: .position, label: "Set Position")
                            
                            Menu {
                                Button {
                                    cue.movingHead.positionPreset = nil
                                } label: {
                                    Text("Off")
                                }
                                
                                // Options pour chaque preset
                                ForEach(positionPresets) { preset in
                                    Button {
                                        cue.movingHead.scene = .off
                                        cue.movingHead.positionPreset = preset
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
                                            Text(cue.movingHead.positionPreset?.name ?? "Off")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                        }
                                        .padding()
                                    }
                            }
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.position))
                        }
                        .disabledStyle(cue.movingHead.scene != .off)
                        
                        // Color
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .color, label: "Set Color")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(MovingHeadColor.allCases) { movingHeadColor in
                                    if movingHeadColor != .auto {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(movingHeadColor.colorValue)
                                            .frame(width: 50, height: 50)
                                            .overlay {
                                                if cue.movingHead.color == movingHeadColor {
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(movingHeadColor == .white ? .black : .white)
                                                        .fontWeight(.semibold)
                                                        .font(.title)
                                                }
                                            }
                                            .onTapGesture {
                                                cue.movingHead.color = movingHeadColor
                                            }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .disabledStyle(cue.movingHead.colorSpeed != 0 || !cue.movingHeadSettings.contains(.color))
                        
                        CustomSliderView(sliderValue: $cue.movingHead.colorSpeed, title: "Speed")
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.color))
                        
                        // Strobe
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .strobeSpeed, label: "Set Strobe")
                        
                        CustomSliderView(sliderValue: $cue.movingHead.strobeSpeed, title: "Intensity")
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.strobeSpeed))
                        
                        // Brightness
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .brightness, label: "Set Brightness")
                        
                        CustomSliderView(sliderValue: $cue.movingHead.brightness, title: "Brightness")
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.brightness))
                            .disabledStyle(cue.movingHead.breathe)
                        
                        Button {
                            cue.movingHead.breathe.toggle()
                        } label: {
                            Label("Breathe", systemImage: "wave.3.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.movingHead.breathe ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.movingHeadSettings.contains(.brightness))
                    }
                    .disabledStyle(cue.movingHead.mode != .manual)
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
    
    func getBackgroundColor(_ scene: MovingHeadScene) -> Color {
        if cue.movingHead.scene != scene {
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
        if cue.laser.includedPatterns.contains(pattern) && cue.laser.includedPatterns.count > 1 {
            cue.laser.includedPatterns.remove(pattern)
        } else {
            cue.laser.includedPatterns.insert(pattern)
        }
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
