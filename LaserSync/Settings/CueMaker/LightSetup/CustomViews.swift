//
//  ColorSelectorView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-01.
//

import SwiftUI

struct ModeSelector: View {
    @Binding var selectedMode: LightMode
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
            ForEach(LightMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                }) {
                    Text(mode.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(selectedMode == mode ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
    }
}

struct ColorSelector<T: LightColors>: View {
    let colors: [T] // Les couleurs disponibles
    @Binding var selectedColor: T // La couleur actuellement sélectionnée
    let showMulticolor: Bool // Indique si la couleur multicolor doit être affichée

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(colors.filter { (showMulticolor || $0.id != "multicolor") && $0.id != "auto" }) { color in
                    if color.id == "multicolor" {
                        RoundedRectangle(cornerRadius: 10)
                            .multicolor()
                            .frame(width: 50, height: 50)
                            .overlay {
                                if selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                        .font(.title)
                                }
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.colorValue)
                            .frame(width: 50, height: 50)
                            .overlay {
                                if selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(color.colorValue == Color.white ? Color.black : Color.white)
                                        .font(.title)
                                }
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }
        }
    }
}

struct ColorSelector_Preview: View {
    @State private var selectedColor: LaserColor = .red
    var body: some View {
        ColorSelector<LaserColor>(colors: LaserColor.allCases, selectedColor: $selectedColor, showMulticolor: true)
    }
}

struct SceneSelector: View {
    @Binding var selectedScene: LightScene
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
            ForEach(LightScene.allCases.reversed()) { scene in
                Button(action: {
                    selectedScene = scene
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
    }
    
    private func getBackgroundColor(_ scene: LightScene) -> Color {
        if selectedScene != scene {
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
}

struct NextButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Next")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

#Preview {
    VStack(spacing: 25) {
        ModeSelector(selectedMode: .constant(.manual))
        ColorSelector_Preview()
        SceneSelector(selectedScene: .constant(.slow))
        NextButton(action: {})
    }
}
