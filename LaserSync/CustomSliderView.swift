//
//  CustomSliderView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-26.
//

import SwiftUI
import UIKit

enum CustomSliderOrientation {
    case horizontal
    case vertical
}

struct CustomSliderView: View {
    @Binding var sliderValue: Double
    @State var title: String
    var orientation: CustomSliderOrientation = .horizontal
    var onValueChange: ((Double) -> Void)?

    @State private var dragOffset: CGFloat = 0
    @State private var hasTriggeredHapticAtLimit: Bool = false
    @State private var lastValue: Int = 0

    var body: some View {
        GeometryReader { geometry in
            switch orientation {
            case .horizontal:
                horizontalSlider(geometry: geometry)
            case .vertical:
                verticalSlider(geometry: geometry)
            }
        }
        // Hauteur ou largeur minimale (adapté si vertical)
        .frame(
            height: orientation == .horizontal ? 50 : nil
        )
    }

    // MARK: - SLIDER HORIZONTAL
    @ViewBuilder
    private func horizontalSlider(geometry: GeometryProxy) -> some View {
        let size = geometry.size
        
        // Largeur de la zone active en fonction de sliderValue (0...100)
        let sliderWidth = (sliderValue / 100) * size.width

        ZStack(alignment: .leading) {
            // Fond inactif
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.6))
                .frame(height: 50)

            // Partie active
            Rectangle()
                .fill(Color.white)
                .frame(width: sliderWidth, height: 50)

            // Titre au centre (plutôt aligné à gauche ici)
            Text(title)
                .padding(.leading)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.black.opacity(0.5))

            // Valeur affichée à droite
            HStack {
                Spacer()
                Text(sliderValue == 0 ? "Off" : "\(Int(sliderValue))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
            }

            // Règle (petites barres) sous la partie active
            rulerLinesHorizontal(size: size)
                .offset(y: 23) // Placé sous le slider
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .contentShape(Rectangle()) // toute la zone est cliquable
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let locationX = value.location.x
                    if value.startLocation.x == locationX {
                        dragOffset = sliderWidth - locationX
                    }

                    let newValue = min(max(0, (locationX + dragOffset) / size.width * 100), 100)
                    sliderValue = newValue
                    if Int(newValue) != lastValue {
                        onValueChange?(newValue)
                    }
                    lastValue = Int(newValue)

                    handleHapticIfNeeded()
                }
                .onEnded { _ in
                    dragOffset = 0
                    hasTriggeredHapticAtLimit = false
                }
        )
    }

    // MARK: - SLIDER VERTICAL
    @ViewBuilder
    private func verticalSlider(geometry: GeometryProxy) -> some View {
        let size = geometry.size
        
        // Hauteur de la zone active en fonction de sliderValue (0...100)
        let sliderHeight = (sliderValue / 100) * size.height

        // ZStack en bas => on aligne en bottom (leading = bas dans le repère vertical)
        ZStack(alignment: .bottom) {
            // Fond inactif
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.6))

            // Partie active
            Rectangle()
                .fill(Color.white)
                .frame(height: sliderHeight)
            
            // Règle vertical (petites barres à gauche ou à droite)
            rulerLinesVertical(size: size)
                .offset(x: 0, y: 0) // Ajuste si besoin
            
            // Valeur affichée en bas
            VStack {
                Text(sliderValue == 0 ? "Off" : "\(Int(sliderValue))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(sliderValue > 95 ? .black : .white)
                    .padding(.top, 10)
                Spacer()
            }

            // Titre (on l'affiche en haut ou au milieu selon préférences)
            VStack {
                Spacer()
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black.opacity(0.5))
                    .padding(.bottom, 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let locationY = value.location.y
                    
                    // Au premier touch, on calcule un offset
                    if value.startLocation.y == locationY {
                        dragOffset = sliderHeight - (size.height - locationY)
                    }

                    // On veut 0 en bas, 100 en haut
                    // Donc on calcule :
                    //   distance du bas = size.height - locationY
                    //   => /size.height * 100 => [0..100]
                    let newValue = min(
                        max(
                            0, (size.height - locationY + dragOffset) / size.height * 100
                        ),
                        100
                    )
                    sliderValue = newValue
                    if Int(newValue) != lastValue {
                        onValueChange?(newValue)
                    }
                    lastValue = Int(newValue)

                    handleHapticIfNeeded()
                }
                .onEnded { _ in
                    dragOffset = 0
                    hasTriggeredHapticAtLimit = false
                }
        )
    }

    // MARK: - RÈGLE HORIZONTALE
    private func rulerLinesHorizontal(size: CGSize) -> some View {
        let totalDivisions = 20
        let spacing = size.width / CGFloat(totalDivisions)

        return HStack(spacing: spacing) {
            ForEach(0...totalDivisions, id: \.self) { index in
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: index == totalDivisions / 2 ? 20 : 10)
            }
        }
        .frame(width: size.width)
    }

    // MARK: - RÈGLE VERTICALE
    private func rulerLinesVertical(size: CGSize) -> some View {
        let totalDivisions = 20
        let spacing = size.height / CGFloat(totalDivisions)

        return VStack(spacing: spacing) {
            ForEach(0...totalDivisions, id: \.self) { index in
                Rectangle()
                    .fill(Color.gray)
                    // On fait une barre plus longue pour la division du milieu
                    .frame(width: index == totalDivisions / 2 ? 20 : 10, height: 2)
            }
        }
        .frame(height: size.height)
    }

    // MARK: - HAPTIC FEEDBACK
    private func handleHapticIfNeeded() {
        if sliderValue == 0 || sliderValue == 100 {
            if !hasTriggeredHapticAtLimit {
                hapticFeedback()
                hasTriggeredHapticAtLimit = true
            }
        } else {
            hasTriggeredHapticAtLimit = false
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct CustomSlider_InteractivePreview: View {
    @State private var sliderValue: Double = 50

    var body: some View {
        CustomSliderView(sliderValue: $sliderValue, title: "Test", onValueChange: { _ in
            
        })
    }
}

struct CustomSlider_Preview: PreviewProvider {
    static var previews: some View {
        CustomSlider_InteractivePreview()
    }
}


//struct BetterCustomSlider_Preview: PreviewProvider {
//    static var previews: some View {
//        @State var volume: CGFloat = 30
//        BetterCustomSlider(value: $volume, in: 0...100) {
//            
//        }
//        .padding(15)
//    }
//}
