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
    
    var onConfirm: () -> Void = {}
    var onEditSection: (String) -> Void = { _ in }
    
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
                                onEditSection("Laser")
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
                                onEditSection("Moving Head")
                            }
                        }
                    }
                    .padding()
                }
                
                if !onlySummary {
                    Spacer()
                    
                    VStack(alignment: .leading) {
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
                        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .white]
                        ColorSelectorView(selectedColor: $cue.color, colors: colors)
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

struct ColorSelectorView: View {
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
