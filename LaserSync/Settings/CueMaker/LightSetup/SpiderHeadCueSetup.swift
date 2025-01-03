//
//  SpiderHeadCueSetup.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-01.
//

import SwiftUI

struct SpiderHeadCueSetup: View {
    @Binding var cue: Cue
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
                    
                    // MARK: - Scene
                    SettingToggle(settings: $cue.spiderHeadSettings, setting: .scene, label: "Set Scene")
                    
                    SceneSelector(selectedScene: $cue.spiderHead.scene)
                        .padding(.bottom)
                        .disabledStyle(!cue.spiderHeadSettings.contains(.scene))
                    
                    // MARK: - Color
                    SettingToggle(settings: $cue.spiderHeadSettings, setting: .color, label: "Set Color")
                    
                    Group {
                        SpiderHeadLedSelector(onSelectionChange: { leds in
                            let anyLedIsOn = leds.contains { $0.isOn }
                            cue.spiderHead.ledSelection = anyLedIsOn ? leds : nil
                        })
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                        
                        ColorSelector(colors: SpiderHeadColor.allCases, selectedColor: $cue.spiderHead.color, showMulticolor: true)
                            .padding(.bottom)
                            .disabledStyle(cue.spiderHead.ledSelection != nil)
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
                    SettingToggle(settings: $cue.spiderHeadSettings, setting: .chase, label: "Set Chase Speed")
                    
                    CustomSliderView(sliderValue: $cue.spiderHead.lightChaseSpeed, title: "Chase")
                        .padding(.bottom)
                        .disabledStyle(!cue.spiderHeadSettings.contains(.chase))
                    
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
