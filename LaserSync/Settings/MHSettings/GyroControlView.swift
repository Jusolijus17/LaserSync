//
//  GyroControlView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-23.
//

import SwiftUI
import CoreMotion

struct GyroControlView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @EnvironmentObject var motionManager: MotionManager
    
    @State private var presets: [GyroPreset] = GyroPreset.loadPresets()
    @State private var showingAlert: Bool = false
    @State private var newPresetName = ""
    @State private var isDetecting: Bool = false // État de la détection

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 10) {
                // Affichage des valeurs de pan et tilt
                Text("Pan (Yaw): \(motionManager.pan, specifier: "%.2f")°")
                Text("Tilt (Pitch): \(motionManager.tilt, specifier: "%.2f")°")
            }

            GeometryReader { geometry in
                ZStack {
                    gridWithAxes(in: geometry.size)
                    visualisationCircle(in: geometry.size)
                }
            }
            .frame(height: 200)
            .padding([.top, .horizontal])

            // Switch pour inverser les commandes
            Toggle(isOn: $motionManager.isInverted) {
                Text("Invert controls").font(.headline)
            }
            .padding()
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Spacer()

            // Bouton pour réinitialiser la position
            Button {
                resetPosition()
            } label: {
                Text("Reset position")
            }
            
            Button(action: {
                showingAlert = true
            }) {
                Text("Save Preset")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(!isDetecting)
            .opacity(!isDetecting ? 0.5 : 1.0)

            // Bouton pour démarrer ou arrêter la détection
            Button(action: {
                if isDetecting {
                    stopMotionUpdates()
                } else {
                    startMotionUpdates()
                }
                isDetecting.toggle()
            }) {
                Text(isDetecting ? "Arrêter la détection" : "Démarrer la détection")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isDetecting ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Gyro control")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Arrêter les mises à jour si la vue disparaît
            if isDetecting {
                stopMotionUpdates()
                isDetecting = false
            }
        }
        .alert("New Preset", isPresented: $showingAlert) {
            TextField("Preset Name", text: $newPresetName)
            Button("Save", action: savePreset)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a name for the new preset.")
        }
    }
    
    private func savePreset() {
        guard !newPresetName.isEmpty else { return }
        
        let newPreset = GyroPreset(
            id: UUID(),
            name: newPresetName,
            pan: motionManager.pan,
            tilt: motionManager.tilt
        )
        presets.append(newPreset)
        GyroPreset.savePresets(presets) // Sauvegarde dans UserDefaults
        newPresetName = "" // Réinitialiser le champ
    }

    private func visualisationCircle(in size: CGSize) -> some View {
        let width = size.width
        let height = size.height

        // Calculer les positions X et Y pour afficher le cercle
        let halfWidth = width / 2
        let halfHeight = height / 2

        let currentPan = motionManager.pan
        let currentTilt = motionManager.tilt

        let adjustedPan = currentPan / 180.0 // Normaliser pan dans [-1, 1]
        let adjustedTilt = currentTilt / 90.0 // Normaliser tilt dans [-1, 1]

        let xOffset = CGFloat(adjustedPan * (halfWidth - 10))
        let yOffset = CGFloat(adjustedTilt * (halfHeight - 10))

        let xPosition = halfWidth + xOffset
        let yPosition = halfHeight - yOffset

        return Circle()
            .frame(width: 20, height: 20)
            .position(x: xPosition, y: yPosition)
            .animation(.easeInOut, value: motionManager.pan)
    }

    private func gridWithAxes(in size: CGSize) -> some View {
        let columns = 8
        let rows = 4

        return Path { path in
            let cellWidth = size.width / CGFloat(columns)
            let cellHeight = size.height / CGFloat(rows)

            for i in 0...columns {
                let x = CGFloat(i) * cellWidth
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }

            for i in 0...rows {
                let y = CGFloat(i) * cellHeight
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
    }

    private func startMotionUpdates() {
        motionManager.startMotionUpdates()
        motionManager.onMotionDataUpdate = { pan, tilt in
            laserConfig.sendGyroData(pan: pan, tilt: tilt)
        }
    }

    private func stopMotionUpdates() {
        motionManager.stopMotionUpdates()
    }
    
    private func resetPosition() {
        laserConfig.sendGyroData(pan: 0, tilt: 0)
    }
}

#Preview {
    GyroControlView()
        .environmentObject(MotionManager())
}
