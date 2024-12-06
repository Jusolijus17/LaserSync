//
//  CueMakerView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-26.
//

import SwiftUI

struct CueMakerView: View {
    @State private var currentStep: Step = .selectLights
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
                    onNext: { cue.includeMovingHead ? (currentStep = .movingHeadSettings) : (currentStep = .summary) }
                )
                .navigationTitle("Laser settings")
                .navigationBarTitleDisplayMode(.inline)
            case .movingHeadSettings:
                MovingHeadCueSetup(
                    cue: $cue,
                    onNext: { currentStep = .summary }
                )
                .navigationTitle("Moving Head settings")
                .navigationBarTitleDisplayMode(.inline)
            case .summary:
                SummaryView(cue: $cue, onConfirm: {
                    saveCue()
                    currentStep = .selectLights
                }, onEditSection: { section in
                    navigateToStep(for: section)
                }
                )
                .navigationTitle("Summary")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationTitle("Cue Maker")
    }
    
    private func navigateToStep(for section: String) {
        switch section {
        case "Laser":
            if cue.includeLaser {
                currentStep = .laserSettings
            }
        case "Moving Head":
            if cue.includeMovingHead {
                currentStep = .movingHeadSettings
            }
        default:
            break
        }
    }
    
    private func saveCue() {
        let encoder = JSONEncoder()
        
        var savedCues: [Cue] = loadCues()
        
        savedCues.append(cue)
        
        do {
            let data = try encoder.encode(savedCues)
            UserDefaults.standard.set(data, forKey: "savedCues")
            cue = Cue()
            print("Cue saved successfully!")
        } catch {
            print("Failed to save cue: \(error)")
        }
    }
    
    private func loadCues() -> [Cue] {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: "savedCues") {
            do {
                let cues = try decoder.decode([Cue].self, from: data)
                return cues
            } catch {
                print("Failed to load cues: \(error)")
            }
        }
        return []
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

// Étape 3 : Paramètres du moving head
struct MovingHeadCueSetup: View {
    @Binding var cue: Cue
    @State private var positionPresets: [GyroPreset] = GyroPreset.loadPresets()
    var onNext: () -> Void
    
    var body: some View {
        ZStack {
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
            }
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
        .padding([.bottom, .horizontal])
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

struct SummaryView: View {
    @Binding var cue: Cue
    @State private var showingAlert = false
    
    var onConfirm: () -> Void
    var onEditSection: (String) -> Void
    
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
                        .onTapGesture {
                            onEditSection("Laser")
                        }
                    }
                    
                    // Section Moving Head
                    if cue.includeMovingHead {
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
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Cue color")
                    .font(.title2)
                    .padding(.horizontal)
                let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .gray]
                ColorSelectorView(selectedColor: $cue.color, colors: colors)
            }
            
            // Bouton de confirmation
            Button(action: {showingAlert.toggle()}) {
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
    
    private func getLaserDetails() -> [(String, String)] {
        var details: [(String, String)] = []
        
        // Mode
        details.append(("Mode", cue.laserMode.rawValue.capitalized))
        
        // Blackout
        if cue.laserMode == .blackout {
            return details
        }
        
        // Auto & Sound
        if cue.laserMode != .manual {
            details.append(("Color", "Auto"))
            details.append(("Pattern", "Auto"))
            return details
        }
        
        // Color
        let color = cue.laserBPMSyncModes.contains(.color) ? "Sync" : cue.laserColor.rawValue.capitalized
        details.append(("Color", color))
        
        // Pattern
        let pattern = cue.laserBPMSyncModes.contains(.pattern) ? "Sync" : cue.laserPattern.rawValue.capitalized
        details.append(("Pattern", pattern))
        
        return details
    }
    
    private func getMovingHeadDetails() -> [(String, String)] {
        var details: [(String, String)] = []
        
        // Mode
        details.append(("Mode", cue.movingHeadMode.rawValue.capitalized))
        
        // Blackout
        if cue.movingHeadMode == .blackout {
            return details
        }
        
        if cue.movingHeadMode != .manual {
            details.append(("Scene", "Off"))
            details.append(("Position", "Off"))
            details.append(("Color", "Auto"))
            details.append(("Color Speed", "Auto"))
            details.append(("Strobe", "Auto"))
            details.append(("Brightness", "Auto"))
            return details
        }
        
        // Scene
        let scene = cue.movingHeadScene.rawValue.capitalized
        details.append(("Scene", scene))
        
        // Position
        let position = "\(cue.positionPreset?.name ?? "Off")"
        details.append(("Position", position))
        
        // Color
        let color = cue.movingHeadColorFrequency != 0 ? "Auto" : cue.movingHeadColor.rawValue.capitalized
        details.append(("Color", color))
        
        // Color Speed
        let colorFrequency = cue.movingHeadColorFrequency == 0 ? "Off" : "\(Int(cue.movingHeadColorFrequency))%"
        details.append(("Color Speed", colorFrequency))
        
        // Strobe
        let strobe = cue.movingHeadStrobeFrequency == 0 ? "Off" : "\(Int(cue.movingHeadStrobeFrequency))%"
        details.append(("Strobe", strobe))
        
        // Brightness
        let brightness = cue.movingHeadBrightness == 0 ? "Off" : "\(Int(cue.movingHeadBrightness))%"
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

struct ColorSelectorView: View {
    @Binding var selectedColor: Color // Couleur sélectionnée
    let colors: [Color] // Liste des couleurs disponibles

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

                        // Ajout d'un checkmark si la couleur est sélectionnée
                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    .onTapGesture {
                        selectedColor = color // Met à jour la couleur sélectionnée
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

enum Step {
    case selectLights
    case laserSettings
    case movingHeadSettings
    case summary
}

// Modèle de données pour une cue
struct Cue: Identifiable, Codable {
    var id = UUID()
    var color: Color = .red
    var name: String = ""

    // Laser
    var includeLaser: Bool = false
    var laserColor: LaserColor = .red
    var laserBPMSyncModes: [BPMSyncMode] = []
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
    var movingHeadBrightness: Double = 50
    var positionPreset: GyroPreset? = nil
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
        CueMakerView()
    }
    .navigationTitle("Cue Maker")
}
