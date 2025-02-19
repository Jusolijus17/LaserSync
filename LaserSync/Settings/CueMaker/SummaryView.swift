//
//  SummaryView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-17.
//

import SwiftUI

struct SummaryView: View {
    @Binding var cue: Cue
    var onlySummary = false
    @State private var showingAlert = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var bpmMultiplier: Double = 1
    let multipliers: [Double] = [1/8, 1/4, 1/2, 1, 2, 4, 8, 16]
    
    var onConfirm: () -> Void = {}
    var onEditSection: (CueMakerStep) -> Void = { _ in }
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Section Laser
                        if cue.affectedLights.contains(.laser) {
                            SummaryLightSection(
                                iconName: "laser_icon", // Nom de l'icône pour le laser
                                lightName: "Laser",
                                details: getLaserDetails()
                            )
                            .onTapGesture {
                                onEditSection(.laserSettings)
                            }
                        }
                        
                        // Section Moving Head
                        if cue.affectedLights.contains(.movingHead) {
                            SummaryLightSection(
                                iconName: "moving_head_icon", // Nom de l'icône pour le moving head
                                lightName: "Moving Head",
                                details: getMovingHeadDetails()
                            )
                            .onTapGesture {
                                onEditSection(.movingHeadSettings)
                            }
                        }
                        
                        // Section Spider Head
                        if cue.affectedLights.contains(.spiderHead) {
                            SummaryLightSection(iconName: "spider_head_icon", lightName: "Spider Head", details: getSpiderHeadDetails())
                                .onTapGesture {
                                    onEditSection(.spiderHeadSettings)
                                }
                        }
                    }
                    .padding()
                }
                
                if !onlySummary {
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Toggle(isOn: $cue.changeBpmMultiplier) {
                            Text("BPM Multiplier")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        
                        BpmMultiplierSelector(bpmMultiplier: $bpmMultiplier)
                            .padding([.horizontal, .bottom])
                            .disabledStyle(!cue.changeBpmMultiplier)
                        
                        Toggle(isOn: $cue.changeBreatheMode) {
                            Text("Breathe Mode")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        
                        Picker("Mode", selection: $cue.breatheMode) {
                            ForEach(BreatheMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue.capitalized)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .disabledStyle(!cue.changeBreatheMode)
                        
                        Text("Cue type")
                            .font(.title2)
                            .padding(.horizontal)
                        Picker("Type", selection: $cue.type) {
                            ForEach(CueType.allCases) { type in
                                Text(type.rawValue.capitalized)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        Text("Cue color")
                            .font(.title2)
                            .padding(.horizontal)
                        let colors: [Color] = [.green, .yellow, .red, .blue, .orange, .purple, .pink, .white]
                        CueColorSelector(selectedColor: $cue.color, colors: colors)
                    }
                }
                
                // Bouton de confirmation
                Button {
                    confirm()
                } label: {
                    Text("Confirm")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .alert("New Cue", isPresented: $showingAlert) {
                TextField("Cue Name", text: $cue.name)
                    .autocorrectionDisabled()
                Button("Save", action: {
                    if cue.name != "" {
                        onConfirm()
                    }
                })
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for the new cue.")
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func confirm() {
        if onlySummary {
            dismiss()
        } else {
            showingAlert.toggle()
        }
    }
    
    private func getLaserDetails() -> [(String, String)] {
        var details: [(String, String)] = []
        
        // Mode
        details.append(("Mode", cue.laser.mode.rawValue.capitalized))
        
        // Blackout
        if cue.laser.mode == .blackout {
            return details
        }
        
        // Auto & Sound
        if cue.laser.mode != .manual {
            details.append(("Color", "Auto"))
            details.append(("Pattern", "Auto"))
            return details
        }
        
        // Color
        let color = cue.laser.bpmSyncModes.contains(.color) ? "Sync" : cue.laser.color.rawValue.capitalized
        details.append(("Color", color))
        
        // Pattern
        let pattern = cue.laser.bpmSyncModes.contains(.pattern) ? "Sync" : cue.laser.pattern.rawValue.capitalized
        details.append(("Pattern", pattern))
        
        return details
    }
    
    private func getMovingHeadDetails() -> [(String, String)] {
        var details: [(String, String)] = []
        
        // Mode
        details.append(("Mode", cue.movingHead.mode.rawValue.capitalized))
        
        // Blackout
        if cue.movingHead.mode == .blackout {
            return details
        }
        
        if cue.movingHead.mode != .manual {
            details.append(("Scene", "Off"))
            details.append(("Position", "Off"))
            details.append(("Color", "Auto"))
            details.append(("Color Speed", "Auto"))
            details.append(("Strobe", "Auto"))
            details.append(("Brightness", "Auto"))
            return details
        }
        
        // Scene
        let scene = cue.movingHead.scene.rawValue.capitalized
        details.append(("Scene", scene))
        
        // Position
        let position = "\(cue.movingHead.positionPreset?.name ?? "Off")"
        details.append(("Position", position))
        
        // Color
        let color = cue.movingHead.colorSpeed != 0 ? "Auto" : cue.movingHead.color.rawValue.capitalized
        details.append(("Color", color))
        
        // Color Speed
        let colorFrequency = cue.movingHead.colorSpeed == 0 ? "Off" : "\(Int(cue.movingHead.colorSpeed))%"
        details.append(("Color Speed", colorFrequency))
        
        // Strobe
        let strobe = cue.movingHead.strobeSpeed == 0 ? "Off" : "\(Int(cue.movingHead.strobeSpeed))%"
        details.append(("Strobe", strobe))
        
        // Brightness
        let brightness = cue.movingHead.brightness == 0 ? "Off" : "\(Int(cue.movingHead.brightness))%"
        details.append(("Brightness", brightness))
        
        return details
    }
    
    func getSpiderHeadDetails() -> [(String, String)] {
        var details: [(String, String)] = []
        
        // Mode
        details.append(("Mode", cue.spiderHead.mode.rawValue.capitalized))
        
        // Blackout
        if cue.spiderHead.mode == .blackout {
            return details
        }
        
        if cue.spiderHead.mode != .manual {
            details.append(("Scene", "Off"))
            details.append(("Color", "Auto"))
            details.append(("Strobe", "Auto"))
            details.append(("Brightness", "Auto"))
            return details
        }
        
        // Scene
        let scene = cue.spiderHead.scene.rawValue.capitalized
        details.append(("Scene", scene))
        
        // Position
//        let position = "\(cue.movingHead.positionPreset?.name ?? "Off")"
//        details.append(("Position", position))
        
        // Color
        let color = cue.spiderHead.color.rawValue.capitalized
        details.append(("Color", color))
        
        // Strobe
        let strobe = cue.spiderHead.strobeSpeed == 0 ? "Off" : "\(Int(cue.spiderHead.strobeSpeed))%"
        details.append(("Strobe", strobe))
        
        // Brightness
        let brightness = cue.spiderHead.brightness == 0 ? "Off" : "\(Int(cue.spiderHead.brightness))%"
        details.append(("Brightness", brightness))
        
        return details
    }
}

// Section individuelle pour chaque lumière
struct SummaryLightSection: View {
    let iconName: String // Nom de l'icône à afficher
    let lightName: String // Nom de la lumière (ex : Laser, Moving Head)
    let details: [(String, String)] // Détails sous forme de paires (nom, valeur)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(iconName) // Icône de la lumière
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(lightName) // Nom de la lumière
                        .font(.title2)
                        .bold()
                }
                Spacer()
            }
            
            Divider()
            
            ForEach(details, id: \.0) { detail in
                HStack {
                    Text(detail.0 + ":")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(detail.1)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct CueColorSelector: View {
    @Binding var selectedColor: Color
    let colors: [Color]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(colors, id: \.self) { color in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color)
                            .frame(width: 50, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                            )
                            .shadow(radius: 3)

                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .foregroundColor(color == .white ? .black : .white)
                                .bold()
                        }
                    }
                    .onTapGesture {
                        selectedColor = color
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct BpmMultiplierSelector: View {
    @Binding var bpmMultiplier: Double
    
    // Liste des multiplicateurs possibles
    let multipliers: [Double] = [1.0/8.0, 1.0/4.0, 1.0/2.0, 1.0, 2.0, 4.0, 8.0, 16.0]
    
    var body: some View {
        Stepper {
            // Action pour le bouton "+"
            if let currentIndex = multipliers.firstIndex(of: bpmMultiplier),
               currentIndex < multipliers.count - 1 {
                bpmMultiplier = multipliers[currentIndex + 1]
            }
        } onDecrement: {
            // Action pour le bouton "-"
            if let currentIndex = multipliers.firstIndex(of: bpmMultiplier),
               currentIndex > 0 {
                bpmMultiplier = multipliers[currentIndex - 1]
            }
        } label: {
            // Custom label
            Text(formattedMultiplier(bpmMultiplier)) // Utilise une fonction pour formater
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(bpmMultiplier != 1 ? .yellow : .white)
                .padding(.leading)
        }
    }
    
    // Fonction pour formater les valeurs
    func formattedMultiplier(_ value: Double) -> String {
        if value < 1 {
            // Convertir les fractions en "8÷"
            let denominator = Int(1.0 / value)
            return "\(denominator)÷"
        } else {
            // Convertir les multiplicateurs en "4x"
            return "\(Int(value))x"
        }
    }
}

struct SummaryViewPreview: View {
    @State var cue = Cue.preview()
    var body: some View {
        SummaryView(cue: $cue, onConfirm: {}, onEditSection: {_ in})
    }
}

#Preview {
    NavigationView {
        SummaryViewPreview()
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
    }
}
