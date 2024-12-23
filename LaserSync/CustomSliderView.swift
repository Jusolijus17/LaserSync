//
//  CustomSliderView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-26.
//

import SwiftUI
import UIKit

struct CustomSliderView: View {
    @Binding var sliderValue: Double
    @State var title: String
    var onValueChange: ((Double) -> Void)?

    @State private var dragOffset: CGFloat = 0
    @State private var hasTriggeredHapticAtLimit: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let sliderWidth = (sliderValue / 100) * size.width

            ZStack(alignment: .leading) {
                // Inactive background
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.6))
                    .frame(height: 50) // Fix the height of the slider

                // Active part of the slider
                Rectangle()
                    .fill(Color.white)
                    .frame(width: sliderWidth, height: 50)

                // Title in the center
                Text(title)
                    .padding(.leading)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black.opacity(0.5))

                // Value displayed on the right
                HStack {
                    Spacer()
                    Text(sliderValue == 0 ? "Off" : "\(Int(sliderValue))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }

                // Ruler-like lines at the bottom of the slider
                rulerLines(size: size)
                    .offset(y: 23) // Position below the slider
            }
            .clipShape(RoundedRectangle(cornerRadius: 15)) // Ensure corners match
            .contentShape(Rectangle()) // Make the entire area tappable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let locationX = value.location.x

                        if value.startLocation.x == locationX {
                            dragOffset = sliderWidth - locationX
                        }

                        let newValue = min(max(0, (locationX + dragOffset) / size.width * 100), 100)
                        sliderValue = newValue
                        onValueChange?(newValue)

                        if sliderValue == 0 || sliderValue == 100 {
                            if !hasTriggeredHapticAtLimit {
                                hapticFeedback()
                                hasTriggeredHapticAtLimit = true
                            }
                        } else {
                            hasTriggeredHapticAtLimit = false
                        }
                    }
                    .onEnded { _ in
                        dragOffset = 0
                        hasTriggeredHapticAtLimit = false
                    }
            )
        }
        .frame(height: 50) // Adjust total height to fit slider and ruler
    }

    // Fonction pour dessiner les lignes de "ruban à mesurer"
    private func rulerLines(size: CGSize) -> some View {
        let totalDivisions = 20
        let spacing = size.width / CGFloat(totalDivisions)

        return HStack(spacing: spacing) {
            ForEach(0...totalDivisions, id: \.self) { index in
                Rectangle()
                    .fill(Color.gray) // Longer line for the middle
                    .frame(width: 2, height: index == totalDivisions / 2 ? 20 : 10) // Longer for middle
            }
        }
        .frame(width: size.width) // Ensure it fits within the slider width
    }

    // Fonction pour déclencher un retour haptique
    func hapticFeedback() {
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
