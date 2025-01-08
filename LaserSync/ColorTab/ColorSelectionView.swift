//
//  ColorSelectionView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-20.
//

import SwiftUI

struct ColorSelectionView: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var activeLights: Set<Light> = []
    @State private var selectedColors: [Light: Color] = [:]

    var body: some View {
        VStack {
            LightImage(light: .all, selectable: true, selection: $activeLights)
            
            if activeLights.count == 1 && activeLights.contains(.spiderHead) {
                SpiderHeadLedSelector(leds: $laserConfig.spiderHead.ledSelection, onSelectionChange: {
                    laserConfig.setSHLedSelection(leds: laserConfig.spiderHead.ledSelection)
                })
                .padding()
                .frame(maxHeight: .infinity)
            } else {
                Spacer()
            }
            
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
                } else if activeLights.contains(.spiderHead) {
                    MulticolorButton(isSelected: laserConfig.spiderHead.color.colorValue == .clear) {
                        laserConfig.changeColor(lights: [.spiderHead: .clear])
                    }
                    .padding([.horizontal, .top], 20)
                } else if activeLights.contains(.strobe) {
                    MulticolorButton(isSelected: laserConfig.rfStrobe.color.colorValue == .clear) {
                        laserConfig.changeColor(lights: [.strobe: .clear])
                    }
                    .padding([.horizontal, .top], 20)
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
            case .spiderHead:
                return Set(spiderHeadColor())
            case .strobe:
                return Set(strobeColor())
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
    
    private func spiderHeadColor() -> [Color] {
        return SpiderHeadColor.allCases
            .filter { $0.colorValue != .clear }
            .map { $0.colorValue }
    }
    
    private func strobeColor() -> [Color] {
        return StrobeColor.allCases
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
    
    init(light: Light,
         width: CGFloat = 75,
         height: CGFloat = 75,
         selectable: Bool = false,
         selection: Binding<Set<Light>> = .constant([])) {
        self.light = light
        self.width = width
        self.height = height
        self.selectable = selectable
        self._selection = selection
    }
    
    var body: some View {
        LazyHGrid(
            rows: Array(repeating: GridItem(.flexible(minimum: 25, maximum: height)), count: 2)
        ) {
            ForEach(lightsToDisplay, id: \.self) { subLight in
                Image(imageName(for: subLight))
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(minWidth: 25, idealWidth: width, maxWidth: width, minHeight: 25, idealHeight: height, maxHeight: height, alignment: .center)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selection.contains(subLight)
                                  ? Color.gray.opacity(0.7)
                                  : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.7), lineWidth: 3)
                            )
                    }
                    .onTapGesture {
                        if selectable {
                            hapticFeedback()
                            toggleSelectionFor(subLight)
                        }
                    }
            }
        }
        .frame(maxHeight: height * 2)
        .padding()
    }
    
    private var lightsToDisplay: [Light] {
        light == .all ? [.laser, .movingHead, .spiderHead, .strobe] : [light]
    }
    
    private func imageName(for light: Light) -> String {
        switch light {
        case .laser:
            return "laser_icon"
        case .movingHead:
            return "moving_head_icon"
        case .spiderHead:
            return "spider_head_icon"
        case .strobe:
            return "rf_strobe_icon"
        default:
            return ""
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
            MulticolorButton(
                isSelected: laserConfig.laser.color.colorValue == .clear
            ) {
                laserConfig.changeColor(lights: [.laser: .clear])
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

struct MulticolorButton: View {
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            RoundedRectangle(cornerRadius: 10)
                .multicolor()
                .frame(height: 50)
                .overlay {
                    Text("Multicolor")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white, lineWidth: 3)
                    }
                }
        }
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
