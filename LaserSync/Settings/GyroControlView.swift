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

    @State private var isDetecting: Bool = false // État de la détection

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 10) {
                // Utilisation des valeurs directement depuis MotionManager
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
            .padding()
            
            Spacer()
            
            Button {
                resetPosition()
            } label: {
                Text("Reset position")
            }
            
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
            .padding()
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
    }

    private func visualisationCircle(in size: CGSize) -> some View {
        let width = size.width
        let height = size.height

        let xPosition = width / 2 + CGFloat(motionManager.pan / motionManager.panLimit * (width / 2 - 10))
        let yPosition = height / 2 - CGFloat(motionManager.tilt / motionManager.tiltLimit * (height / 2 - 10))

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
