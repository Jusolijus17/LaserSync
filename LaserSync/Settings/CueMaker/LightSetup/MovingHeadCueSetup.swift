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
                    
                    // MARK: - Mode
                    ModeSelector(selectedMode: $cue.movingHead.mode)
                        .padding(.bottom)
                    
                    Group {
                        // MARK: - Scene
                        Group {
                            SettingToggle(settings: $cue.movingHeadSettings, setting: .scene, label: "Set Scene")
                            
                            SceneSelector(selectedScene: $cue.movingHead.scene)
                                .onChange(of: cue.movingHead.scene, { _, newValue in
                                    if newValue != .off {
                                        cue.movingHead.positionPreset = nil
                                    }
                                })
                                .padding(.bottom)
                                .disabledStyle(!cue.movingHeadSettings.contains(.scene))
                        }
                        .disabledStyle(cue.movingHead.positionPreset != nil)
                        
                        // MARK: - Position
                        Group {
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
                        .disabledStyle(cue.movingHeadSettings.contains(.scene))
                        
                        // MARK: - Color
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .color, label: "Set Color")
                        
                        ColorSelector(colors: MovingHeadColor.allCases, selectedColor: $cue.movingHead.color, showMulticolor: false)
                            .padding(.bottom)
                            .disabledStyle(cue.movingHead.colorSpeed != 0 || !cue.movingHeadSettings.contains(.color))
                        
                        CustomSliderView(sliderValue: $cue.movingHead.colorSpeed, title: "Speed")
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.color))
                        
                        // MARK: - Gobo
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .gobo, label: "Set Gobo")
                        
                        Picker("Valeur", selection: $cue.movingHead.gobo) {
                            ForEach(0...7, id: \.self) { value in
                                Text("\(value)")
                                    .tag(value)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom)
                        .disabledStyle(!cue.movingHeadSettings.contains(.gobo))
                        
                        // MARK: - Strobe Speed
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .strobeSpeed, label: "Set Strobe Speed")
                        
                        CustomSliderView(sliderValue: $cue.movingHead.strobeSpeed, title: "Intensity")
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.strobeSpeed))
                        
                        // MARK: - Strobe
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .strobe, label: "Set Strobe")
                        
                        Button {
                            toggleStrobeMode()
                        } label: {
                            Label("Strobe", systemImage: "circle.dotted.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.includedLightsStrobe.contains(.movingHead) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.movingHeadSettings.contains(.strobe))
                        .onChange(of: cue.includedLightsStrobe) { _, newValue in
                            if newValue.contains(.movingHead) {
                                cue.includedLightsBreathe.remove(.movingHead)
                            }
                        }
                        
                        // MARK: - Brightness
                        SettingToggle(settings: $cue.movingHeadSettings, setting: .brightness, label: "Set Brightness")
                            .onChange(of: cue.movingHeadSettings) { _, newValue in
                                if newValue.contains(.strobe) {
                                    cue.includedLightsBreathe.remove(.movingHead)
                                }
                            }
                        
                        CustomSliderView(sliderValue: $cue.movingHead.brightness, title: "Brightness")
                            .padding(.bottom)
                            .disabledStyle(!cue.movingHeadSettings.contains(.brightness))
                            .disabledStyle(cue.includedLightsBreathe.contains(.movingHead))
                        
                        // MARK: - Breathe
                        Button {
                            toggleBreatheMode()
                        } label: {
                            Label("Breathe", systemImage: "wave.3.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.includedLightsBreathe.contains(.movingHead) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.movingHeadSettings.contains(.brightness) || (cue.movingHeadSettings.contains(.strobe) && cue.includedLightsStrobe.contains(.movingHead)))
                    }
                    .disabledStyle(cue.movingHead.mode != .manual)
                }
                .padding()
                .padding(.bottom, 65)
            }
            
            NextButton(action: onNext)
                .padding()
                .background()
        }
    }
    
    private func toggleBreatheMode() {
        if cue.includedLightsBreathe.contains(.movingHead) {
            cue.includedLightsBreathe.remove(.movingHead)
        } else {
            cue.includedLightsBreathe.insert(.movingHead)
        }
    }
    
    private func toggleStrobeMode() {
        if cue.includedLightsStrobe.contains(.movingHead) {
            cue.includedLightsStrobe.remove(.movingHead)
        } else {
            cue.includedLightsStrobe.insert(.movingHead)
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
