//
//  SpiderHeadCueSetup.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-01.
//

import SwiftUI

struct SpiderHeadCueSetup: View {
    @Binding var cue: Cue
    @State private var positionPresets: [ShPositionPreset] = ShPositionPreset.loadPresets()
    var onNext: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Set Mode")
                        .font(.title2)
                        .padding(.bottom)
                    
                    // MARK: - Mode
                    ModeSelector(selectedMode: $cue.spiderHead.mode)
                        .padding(.bottom)
                    
                    Group {
                        // MARK: - Scene
                        Group {
                            SettingToggle(settings: $cue.spiderHeadSettings, setting: .scene, label: "Set Scene")
                            
                            SceneSelector(selectedScene: $cue.spiderHead.scene)
                                .onChange(of: cue.spiderHead.scene, { _, newValue in
                                    if newValue != .off {
                                        cue.spiderHead.position = nil
                                    }
                                })
                                .padding(.bottom)
                                .disabledStyle(!cue.spiderHeadSettings.contains(.scene))
                        }
                        .disabledStyle(cue.spiderHead.position != nil)
                        
                        // MARK: - Position
                        Group {
                            SettingToggle(settings: $cue.spiderHeadSettings, setting: .position, label: "Set Position")
                            
                            Menu {
                                Button {
                                    cue.spiderHead.position = nil
                                } label: {
                                    Text("Off")
                                }
                                
                                // Options pour chaque preset
                                ForEach(positionPresets) { preset in
                                    Button {
                                        cue.spiderHead.scene = .off
                                        cue.spiderHead.position = preset
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
                                            Text(cue.spiderHead.position?.name ?? "Off")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                        }
                                        .padding()
                                    }
                            }
                            .padding(.bottom)
                            .disabledStyle(!cue.spiderHeadSettings.contains(.position))
                        }
                        .disabledStyle(cue.spiderHeadSettings.contains(.scene))
                        
                        // MARK: - Color
                        SettingToggle(settings: $cue.spiderHeadSettings, setting: .color, label: "Set Color")
                        
                        Group {
                            SpiderHeadLedSelector(leds: $cue.spiderHead.ledSelection)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom)
                            
                            ColorSelector(colors: SpiderHeadColor.allCases, selectedColor: $cue.spiderHead.color, showMulticolor: true)
                                .padding(.bottom)
                                .disabledStyle(cue.spiderHead.ledSelection.contains { $0.isOn })
                        }
                        .disabledStyle(!cue.spiderHeadSettings.contains(.color))
                        
                        // MARK: - Brightness
                        SettingToggle(settings: $cue.spiderHeadSettings, setting: .brightness, label: "Set Brightness")
                        
                        CustomSliderView(sliderValue: $cue.spiderHead.brightness, title: "Brightness")
                            .padding(.bottom)
                            .disabledStyle(!cue.spiderHeadSettings.contains(.brightness))
                        
                        // MARK: - Breathe
                        Button {
                            toggleBreatheMode()
                        } label: {
                            Label("Breathe", systemImage: "wave.3.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cue.includedLightsBreathe.contains(.spiderHead) ? Color.yellow : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        .disabledStyle(!cue.spiderHeadSettings.contains(.brightness) || cue.spiderHeadSettings.contains(.strobe))
                        
                        // MARK: - Strobe
                        SettingToggle(settings: $cue.spiderHeadSettings, setting: .strobeSpeed, label: "Set Strobe Speed")
                        
                        CustomSliderView(sliderValue: $cue.spiderHead.strobeSpeed, title: "Frequency")
                            .padding(.bottom)
                            .disabledStyle(!cue.spiderHeadSettings.contains(.strobeSpeed))
                        
                        // MARK: - Chase speed
                        SettingToggle(settings: $cue.spiderHeadSettings, setting: .chaseSpeed, label: "Set Chase Speed")
                            .onChange(of: cue.spiderHeadSettings) { _, newValue in
                                if newValue.contains(.color) {
                                    cue.spiderHead.lightChaseSpeed = 0
                                }
                            }
                        
                        CustomSliderView(sliderValue: $cue.spiderHead.lightChaseSpeed, title: "Chase")
                            .padding(.bottom)
                            .disabledStyle(!cue.spiderHeadSettings.contains(.chaseSpeed))
                        
                    }
                    .disabledStyle(cue.spiderHead.mode != .manual)
                    
                }
                .padding()
                .padding(.bottom, 65)
            }
            
            // MARK: - Next
            NextButton(action: onNext)
                .padding()
                .background()
        }
    }
    
    private func toggleBreatheMode() {
        if cue.includedLightsBreathe.contains(.spiderHead) {
            cue.includedLightsBreathe.remove(.spiderHead)
        } else {
            cue.includedLightsBreathe.insert(.spiderHead)
        }
    }
}

struct SpiderHeadCueSetupPreview: View {
    @State private var cue = Cue.preview()
    var body: some View {
        SpiderHeadCueSetup(cue: $cue, onNext: {})
    }
}

#Preview {
    NavigationView {
        SpiderHeadCueSetupPreview()
            .navigationTitle("Spider Head")
            .navigationBarTitleDisplayMode(.inline)
    }
}
