//
//  ColorSelectionView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-20.
//

import SwiftUI

struct ColorSelectionView: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var activeLights: Set<Light> = [.laser, .movingHead]
    @State private var selectedColors: [Light: Color] = [:]

    var body: some View {
        VStack {
            LightImage(light: .both, selectable: true, selection: $activeLights)
            
            Spacer()
            
            VStack {
                ColorGridView(
                    colors: getColors(),
                    activeLights: $activeLights,
                    selectedColors: $selectedColors,
                    onChangeColor: { updatedColors in
                        hapticFeedback()
                        print(updatedColors)
                        laserConfig.changeColor(lights: updatedColors)
                    }
                )
                .disabledStyle(activeLights.isEmpty)
            }
            
            if activeLights.count == 1 {
                if activeLights.contains(.laser) {
                    LaserColorOptions()
                        .padding(.top)
                } else if activeLights.contains(.movingHead) {
                    CustomSliderView(sliderValue: $laserConfig.movingHead.colorSpeed, title: "Color speed", onValueChange: { _ in
                        laserConfig.setMHColorSpeed()
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
        }
        .padding(.bottom)
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func getColors() -> [Color] {
        // Si aucune lumière n'est active, retournez une liste vide ou une valeur par défaut
        guard !activeLights.isEmpty else { return laserColors() }

        // Récupérez les palettes de couleurs pour chaque lumière active
        let colorPalettes = activeLights.map { light in
            switch light {
            case .laser:
                return Set(laserColors()) // Transformé en Set pour les opérations d'interception
            case .movingHead:
                return Set(movingHeadColor())
            case .both:
                return Set(laserColors() + movingHeadColor())
            default: return []
            }
        }

        // Fusionner ou intercepter selon la logique voulue
        // Exemple : retourner les couleurs communes à toutes les lumières sélectionnées
        let intersectedColors = colorPalettes.reduce(colorPalettes.first ?? []) { $0.intersection($1) }
        return Array(intersectedColors).sorted(by: { $0.description < $1.description }) // Optionnel : trier les couleurs
    }

    private func laserColors() -> [Color] {
        return LaserColor.allCases
            .filter { $0.colorValue != .clear }
            .map { $0.colorValue }
    }

    private func movingHeadColor() -> [Color] {
        return MovingHeadColor.allCases
            .filter { $0.colorValue != .clear }
            .map { $0.colorValue }
    }
}

struct ColorGridView: View {
    var colors: [Color]
    @Binding var activeLights: Set<Light> // Les lumières actives
    @Binding var selectedColors: [Light: Color] // Associe une lumière à une couleur sélectionnée
    var onChangeColor: ([Light: Color]) -> Void // Retourne quelle lumière et couleur ont été modifiées

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
            ForEach(colors, id: \.self) { color in
                Button {
                    var updatedColors: [Light: Color] = [:]
                    activeLights.forEach { light in
                        updatedColors[light] = color
                        selectedColors[light] = color
                    }
                    onChangeColor(updatedColors)
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    borderColor(for: color), // Couleur de la bordure
                                    lineWidth: 3
                                )
                        )
                        .frame(height: 100)
                        .overlay {
                            Text(color.name?.capitalized ?? "Unknown")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(color == .white ? .black : .white)
                        }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // Fonction qui détermine la couleur de la bordure pour un carré
    private func borderColor(for color: Color) -> Color {
        guard !activeLights.isEmpty else { return .clear }
        // Si toutes les lumières actives ont cette couleur sélectionnée
        if activeLights.allSatisfy({ selectedColors[$0] == color }) {
            return color == .white ? .red : .white
        }
        // Si certaines lumières seulement ont cette couleur
        else if activeLights.contains(where: { selectedColors[$0] == color }) {
            return .gray
        }
        return .clear // Pas sélectionnée
    }
}

struct LightImage: View {
    var light: Light
    var width: CGFloat
    var height: CGFloat
    var selectable: Bool = false
    @Binding var selection: Set<Light>
    
    init(light: Light, width: CGFloat = 100, height: CGFloat = 100, selectable: Bool = false, selection: Binding<Set<Light>> = .constant([])) {
        self.light = light
        self.width = width
        self.height = height
        self.selectable = selectable
        self._selection = selection
    }

    var body: some View {
        HStack {
            Group {
                if light == .both {
                    Image("laser_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selection.contains(.laser) ? Color.gray.opacity(0.7) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.7), lineWidth: 3)
                                )
                        }
                        .onTapGesture {
                            if selectable {
                                hapticFeedback()
                                toggleSelectionFor(.laser)
                            }
                        }
                }
                Image(getLightImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selection.contains(.movingHead) ? Color.gray.opacity(0.7) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.7), lineWidth: 3)
                            )
                    }
                    .onTapGesture {
                        if selectable {
                            hapticFeedback()
                            toggleSelectionFor(.movingHead)
                        }
                    }
            }
        }
        .padding(.bottom)
    }

    private func getLightImage() -> String {
        switch light {
        case .both: return "moving_head_icon"
        case .laser: return "laser_icon"
        case .movingHead: return "moving_head_icon"
        default: return ""
        }
    }

    private func toggleSelectionFor(_ light: Light) {
        if selection.contains(light) {
            selection.remove(light)
        } else {
            selection.insert(light)
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct LaserColorOptions: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    
    var body: some View {
        VStack {
            Button(action: {
                hapticFeedback()
                laserConfig.changeColor(lights: [.laser: .clear])
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .multicolor()
                    .frame(height: 50)
                    .overlay(content: {
                        Text(LaserColor.multicolor.rawValue.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        if laserConfig.laser.color.colorValue == .clear {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 3)
                        }
                    })
            }
            
            Button(action: {
                hapticFeedback()
                laserConfig.toggleBpmSync(mode: .color)
            }) {
                Text("BPM Sync")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(laserConfig.laser.bpmSyncModes.contains(.color) ? Color.yellow : Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    ColorSelectionView()
        .environmentObject(LaserConfig())
}
