//
//  CueMakerView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-26.
//

import SwiftUI

struct CueMakerView: View {
    @State private var currentStep: Step = .selectLights
    @State private var includeLaser: Bool = false
    @State private var includeMovingHead: Bool = false
    @State private var laserColor: String = "Red"
    @State private var laserMode: String = ""
    @State private var laserPattern: String = ""
    @State private var movingHeadColor: String = "Blue"
    @State private var strobeFrequency: Double = 1.0
    
    @State private var cue = Cue()
    
    var body: some View {
        VStack {
            switch currentStep {
            case .selectLights:
                SelectLightsView(
                    cue: $cue,
                    onNext: {
                        cue.includeLaser ? currentStep = .laserSettings : (cue.includeMovingHead ? (currentStep = .movingHeadSettings) : (currentStep = .selectLights))
                    }
                )
            case .laserSettings:
                LaserCueSetup(
                    cue: $cue,
                    onNext: { currentStep = includeMovingHead ? .movingHeadSettings : .summary }
                )
                .navigationBarTitleDisplayMode(.inline)
            case .movingHeadSettings:
                MovingHeadCueSetup(
                    cue: $cue,
                    onNext: { currentStep = .summary }
                )
                .navigationBarTitleDisplayMode(.inline)
            case .summary:
                SummaryView(cue: $cue,
                    onConfirm: { currentStep = .selectLights }
                )
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationTitle("Cue Maker")
    }
}

// Étape 1 : Sélection des lumières
struct SelectLightsView: View {
    @Binding var cue: Cue
    var onNext: () -> Void
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Select lights")
                .bold()
                .font(.title)
            
            HStack(spacing: 20) {
                LightSelectionButton(
                    title: "Laser",
                    isSelected: $cue.includeLaser,
                    imageName: "laser_icon"
                )
                LightSelectionButton(
                    title: "Moving Head",
                    isSelected: $cue.includeMovingHead,
                    imageName: "moving_head_icon"
                )
            }
            
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
            .padding()
        }
    }
}

// Bouton personnalisé pour sélectionner une lumière
struct LightSelectionButton: View {
    let title: String
    @Binding var isSelected: Bool
    let imageName: String
    
    var body: some View {
        VStack {
            Button(action: { isSelected.toggle() }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 150, height: 150)
                    .overlay {
                        VStack(spacing: 0) {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding()
                            
                            Divider()
                            
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isSelected ? .green : .gray.opacity(0.7))
                                .padding(10)
                        }
                    }
            }
        }
    }
}

// Étape 2 : Paramètres du laser
struct LaserCueSetup: View {
    @Binding var cue: Cue
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Set Laser Mode")
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
                Text("Set Laser Color")
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
                
                Text("Set Laser Pattern")
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
    
    private func makeBPMSyncBinding(for mode: BPMSyncModes) -> Binding<Bool> {
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

// Étape 3 : Paramètres du moving head
struct MovingHeadCueSetup: View {
    @Binding var cue: Cue
    var onNext: () -> Void
    
    var body: some View {
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
                Text("Set Scene")
                    .font(.title2)
                    .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                    ForEach(MovingHeadScene.allCases.reversed()) { scene in
                        Button(action: {
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
                
                Text("Set Strobe")
                    .font(.title2)
                    .padding(.bottom)
                
                CustomSliderView(sliderValue: $cue.movingHeadStrobeFrequency, title: "Intensity")
            }
            .disabled(cue.movingHeadMode != .manual)
            .opacity(cue.movingHeadMode != .manual ? 0.5 : 1.0)
            
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
    
    private func makeBPMSyncBinding(for mode: BPMSyncModes) -> Binding<Bool> {
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

struct SummaryView: View {
    @Binding var cue: Cue
    
    var onConfirm: () -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Section Laser
                    if cue.includeLaser {
                        SummaryLightSection(
                            iconName: "laser_icon", // Nom de l'icône pour le laser
                            lightName: "Laser",
                            details: getLaserDetails()
                        )
                    }
                    
                    // Section Moving Head
                    if cue.includeMovingHead {
                        SummaryLightSection(
                            iconName: "moving_head_icon", // Nom de l'icône pour le moving head
                            lightName: "Moving Head",
                            details: [
                                ("Color", cue.movingHeadColor.rawValue.capitalized),
                                //("Strobe Frequency", "\(strobeFrequency, specifier: "%.1f") Hz")
                            ]
                        )
                    }
                }
                .padding()
            }
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            
            Spacer()
            
            // Bouton de confirmation
            Button(action: onConfirm) {
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
    }
    
    func getLaserDetails() -> [(String, String)] {
        var details: [(String, String)] = []
        
        // Mode
        if cue.laserMode != .manual {
            return [("Mode", cue.laserMode.rawValue.capitalized)]
        } else {
            details.append(("Mode", cue.laserMode.rawValue.capitalized))
        }
        
        // Couleur
        let color = cue.laserBPMSyncModes.contains(.color) ? "Sync" : cue.laserColor.rawValue.capitalized
        details.append(("Color", color))
        
        // Motif
        let pattern = cue.laserBPMSyncModes.contains(.pattern) ? "Sync" : cue.laserPattern.rawValue.capitalized
        details.append(("Pattern", pattern))
        
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
            
            Divider() // Ligne de séparation
            
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

enum Step {
    case selectLights
    case laserSettings
    case movingHeadSettings
    case summary
}

// Modèle de données pour une cue
struct Cue: Identifiable {
    let id = UUID()
    
    // Laser
    var includeLaser: Bool = false
    var laserColor: LaserColor = .red
    var laserBPMSyncModes: [BPMSyncModes] = []
    var laserMode: LaserMode = .blackout
    var laserPattern: LaserPattern = .straight
    var laserIncludedPatterns: Set<LaserPattern> = Set(LaserPattern.allCases)
    
    // Moving Head
    var includeMovingHead: Bool = false
    var movingHeadMode: MovingHeadMode = .blackout
    var movingHeadColor: MovingHeadColor = .red
    var movingHeadColorFrequency: Double = 0
    var movingHeadStrobeFrequency: Double = 0
    var movingHeadScene: MovingHeadScene = .off
}

struct CustomCueMakerPreview: View {
    @State private var cue = Cue()
    var body: some View {
        MovingHeadCueSetup(cue: $cue) {
            return
        }
    }
}

#Preview {
    NavigationView {
        CustomCueMakerPreview()
    }
    .navigationTitle("Cue Maker")
}
