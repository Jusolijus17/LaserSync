//
//  SpiderHeadLedSelector.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-30.
//

import SwiftUI

struct SpiderHeadLedSelector: View {
    // Tableau local des 8 LEDs
    // 2 x (RGBW)
    @State private var leds: [LEDCell] = [
        LEDCell(id: 0, color: .red, side: "right",   isOn: false),
        LEDCell(id: 1, color: .green, side: "right", isOn: false),
        LEDCell(id: 2, color: .blue, side: "right",  isOn: false),
        LEDCell(id: 3, color: .white, side: "right", isOn: false),
        
        LEDCell(id: 4, color: .red, side: "left",   isOn: false),
        LEDCell(id: 5, color: .green, side: "left", isOn: false),
        LEDCell(id: 6, color: .blue, side: "left",  isOn: false),
        LEDCell(id: 7, color: .white, side: "left", isOn: false)
    ]
    var onSelectionChange: ([LEDCell]) -> Void = { _ in }
    
    var body: some View {
        // Pour séparer en 2 rangées de 4
        // (ou 4 rangées de 2, comme tu veux)
        LazyHGrid(rows: Array(repeating: GridItem(.flexible()), count: 4)) {
            ForEach($leds) { $led in
                ZStack {
                    // Arrière-plan avec la couleur ou du gris
                    RoundedRectangle(cornerRadius: 8)
                        .fill(led.isOn ? led.color : Color(.systemGray5))
                        .stroke(led.isOn ? led.color : led.color.opacity(0.5), lineWidth: 3)
                    
                    // Affichage d'un texte si tu veux
                    // (ex. "ON" / "OFF"), ou rien
                    if led.isOn {
                        Text("ON")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(led.color == .white ? .black : .white)
                    }
                }
                .aspectRatio(1, contentMode: .fit) // pour rendre le carré
                .onTapGesture {
                    led.isOn.toggle()
                    onSelectionChange(leds)
                    hapticFeedback()
                }
            }
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct LEDCell: Identifiable, Codable {
    let id: Int
    let color: Color
    let side: String
    var isOn: Bool
}

#Preview {
    SpiderHeadLedSelector()
}
