//
//  ColorSelectionView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-20.
//

import SwiftUI

struct ColorSelectionView: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var selectedTab: Int = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                LightImage(light: .laser)
                ColorGridView(
                    colors: laserColors(),
                    masterColor: $laserConfig.bothColor,
                    localSelectedColor: $laserConfig.laserColor,
                    onChangeColor: { color in changeColor(color, forTab: 0) }
                )
                LaserColorOptions()
                    .padding(.vertical)
            }
            .tag(0)

            VStack {
                LightImage(light: .both)
                ColorGridView(
                    colors: laserColors(),
                    masterColor: $laserConfig.bothColor,
                    localSelectedColor: $laserConfig.bothColor,
                    onChangeColor: { color in changeColor(color, forTab: 1) }
                )
            }
            .tag(1)

            VStack {
                LightImage(light: .movingHead, width: 50, height: 50)
                ColorGridView(
                    colors: movingHeadColor(),
                    masterColor: $laserConfig.bothColor,
                    localSelectedColor: $laserConfig.mHColor,
                    onChangeColor: { color in changeColor(color, forTab: 2) }
                )
                CustomSliderView(sliderValue: $laserConfig.mHColorSpeed, title: "Color speed", onValueChange: { _ in
                    laserConfig.setMHColorSpeed()
                })
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom)
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }

    private func changeColor(_ color: Color, forTab tab: Int) {
        switch tab {
        case 0: // Onglet Laser
            laserConfig.changeColor(light: .laser, color: color)
        case 1: // Onglet Commun
            laserConfig.changeColor(light: .both, color: color)
        case 2: // Onglet Moving Head
            laserConfig.changeColor(light: .movingHead, color: color)
        default:
            break
        }
        hapticFeedback()
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func laserColors() -> [Color] {
        return LaserColor.allCases
            .filter { $0.color != .clear }
            .map { $0.color }
    }

    private func movingHeadColor() -> [Color] {
        return MovingHeadColor.allCases
            .filter { $0.color != .clear }
            .map { $0.color }
    }
}

struct ColorGridView: View {
    var colors: [Color]
    @Binding var masterColor: Color
    @Binding var localSelectedColor: Color
    var onChangeColor: (Color) -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
            ForEach(colors, id: \.self) { color in
                Button {
                    localSelectedColor = color
                    onChangeColor(color)
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    localSelectedColor == color ? .white :
                                    (masterColor == color ? .gray : .clear),
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
}

struct LightImage: View {
    var light: Light
    var width: CGFloat
    var height: CGFloat
    var selectable: Bool = false
    
    @State private var selectedLights: Set<Light> = [] // État des lumières sélectionnées
    private var onSelectionChange: ((Set<Light>) -> Void)?
    
    init(light: Light, width: CGFloat = 100, height: CGFloat = 100, selectable: Bool = false) {
        self.light = light
        self.width = width
        self.height = height
        self.selectable = selectable
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
                                .fill(selectedLights.contains(.laser) ? Color.gray.opacity(0.7) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.7), lineWidth: 3)
                                )
                        }
                        .onTapGesture {
                            if selectable {
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
                            .fill(selectedLights.contains(.movingHead) ? Color.gray.opacity(0.7) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.7), lineWidth: 3)
                            )
                    }
                    .onTapGesture {
                        if selectable {
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
        if selectedLights.contains(light) {
            selectedLights.remove(light)
        } else {
            selectedLights.insert(light)
        }
        onSelectionChange?(selectedLights)
    }
}

extension LightImage {
    func onSelectionChange(_ onChange: @escaping (Set<Light>) -> Void) -> some View {
        var copy = self
        copy.onSelectionChange = onChange
        return copy
    }
}

struct LaserColorOptions: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    
    var body: some View {
        VStack {
            Button(action: {
                hapticFeedback()
                laserConfig.changeColor(light: .laser, color: .clear)
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .multicolor()
                    .frame(height: 50)
                    .overlay(content: {
                        Text(LaserColor.multicolor.rawValue.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        if laserConfig.laserColor == .clear {
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
                    .background(laserConfig.laserBPMSyncModes.contains(.color) ? Color.yellow : Color.gray)
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
