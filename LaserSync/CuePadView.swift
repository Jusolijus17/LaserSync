//
//  CueView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-05.
//

import SwiftUI

struct CuePadView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @EnvironmentObject var sharedStates: SharedStates
    @State private var cues: [Cue?] = [] // Liste des Cue, incluant des cases vides
    @State private var cuePressed = false
    private let totalSlots = 12 // Nombre total de boutons dans la grille
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(0..<totalSlots, id: \.self) { index in
                    if index < cues.count, let cue = cues[index] {
                        LaunchpadButton(color: cue.color)
                            .overlay {
                                if sharedStates.showCueLabels {
                                    Text("\(cue.name)")
                                        .multilineTextAlignment(.center)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(cue.color == .white ? .black : .white)
                                        .padding(.horizontal, 2)
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0.1) {
                                if cue.type == .temporary {
                                    print("Temp cue start")
                                    hapticFeedback()
                                    cuePressed = true
                                    laserConfig.setCue(cue)
                                }
                            } onPressingChanged: { isPressing in
                                if !isPressing && cue.type == .temporary && cuePressed {
                                    print("Temp cue stop")
                                    cuePressed = false
                                    laserConfig.stopCue()
                                }
                                if isPressing && cue.type == .definitive {
                                    print("Cue")
                                    hapticFeedback()
                                    laserConfig.setCue(cue)
                                }
                            }
                    } else {
                        Button {
                            sharedStates.redirectToCueMaker()
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .foregroundColor(.gray)
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "plus")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            cues = Cue.loadCues()
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct LaunchpadButton: View {
    var color: Color // La couleur du bouton

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ombre périphérique (halo lumineux)
                RoundedRectangle(cornerRadius: geometry.size.width / 6) // Calcul dynamique du rayon
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0)]),
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .blur(radius: geometry.size.width / 10)
                
                // Bouton principal
                RoundedRectangle(cornerRadius: geometry.size.width / 6) // Même arrondi
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.5)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .shadow(color: color.opacity(0.5), radius: geometry.size.width / 10, x: 0, y: 4)
            }
        }
        .aspectRatio(1, contentMode: .fit) // Assure que le bouton reste carré
    }
}

#Preview {
    CuePadView()
        .environmentObject(LaserConfig())
        .environmentObject(SharedStates())
}
