//
//  PrecisionControlView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-18.
//

import SwiftUI

struct PrecisionControlView: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var circularAngle: Angle = .degrees(0)
    @State private var verticalOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 50) {
            JoystickView(angle: $circularAngle)
            VerticalJoystickView(angle: $verticalOffset, width: 50, height: 300)
        }
        VStack {
            Text("Pan: \(Int(circularAngle.degrees))")
            Text("Titlt: \(Int(verticalOffset))")
        }
        .onChange(of: circularAngle) { _, newValue in
            laserConfig.sendGyroData(pan: Double(newValue.degrees), tilt: Double(verticalOffset))
        }
        .onChange(of: verticalOffset) { _, newValue in
            laserConfig.sendGyroData(pan: Double(circularAngle.degrees), tilt: Double(newValue))
        }
    }
}

struct JoystickView: View {
    @Binding var angle: Angle // Liaison pour transmettre l'angle
    @State private var location: CGPoint = .zero
    @State private var innerCircleLocation: CGPoint = .zero
    @GestureState private var fingerLocation: CGPoint? = nil

    private let bigCircleRadius: CGFloat = 100
    private let innerCircleRadius: CGFloat = 25 // Rayon du petit cercle (moitié de 50)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: bigCircleRadius * 2, height: bigCircleRadius * 2)
                    .position(location)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: innerCircleRadius * 2, height: innerCircleRadius * 2)
                    .position(innerCircleLocation)
                    .gesture(fingerDrag)
            }
            .onAppear {
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                location = center
                // Positionner initialement le cercle sur la circonférence (en haut)
                innerCircleLocation = CGPoint(x: location.x, y: location.y - bigCircleRadius + innerCircleRadius)
            }
            .onTapGesture(count: 2) {
                innerCircleLocation = CGPoint(x: location.x, y: location.y - bigCircleRadius + innerCircleRadius)
                convertAngle(-.pi/2)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
        .frame(width: bigCircleRadius * 2, height: bigCircleRadius * 2)
    }

    var fingerDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                let dx = value.location.x - location.x
                let dy = value.location.y - location.y
                let angleValue = atan2(dy, dx) // Angle en radians

                // Calculer la position sur la circonférence (rayon constant)
                let newX = location.x + cos(angleValue) * (bigCircleRadius - innerCircleRadius)
                let newY = location.y + sin(angleValue) * (bigCircleRadius - innerCircleRadius)
                innerCircleLocation = CGPoint(x: newX, y: newY)

                // Convertir l’angle en degrés
                convertAngle(angleValue)
            }
    }
    
    func convertAngle(_ angleValue: CGFloat) {
        print(angleValue)
        var degrees = angleValue * 180 / .pi
        degrees = (degrees + 90).truncatingRemainder(dividingBy: 360) // Ajustement pour 0° en haut
        if degrees > 180 {
            degrees -= 360
        }
        angle = Angle(degrees: degrees)
    }
}

struct VerticalJoystickView: View {
    @Binding var angle: CGFloat // Angle transmis à la vue parente
    let width: CGFloat
    let height: CGFloat

    @State private var offset: CGFloat = 0 // Offset interne

    var body: some View {
        let halfHeight = height / 2
        let clamp = halfHeight - (width / 2)
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: height)

            Circle()
                .fill(Color.red)
                .frame(width: width * 0.8, height: width * 0.8)
                .offset(y: offset)
        }
        .onAppear {
            // Placer le rond en haut du joystick au départ
            let halfHeight = height / 2
            offset = -halfHeight + (width / 2) // Position en haut
            angle = 180 // Angle initial en haut
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = value.location.y - halfHeight
                    offset = max(min(newOffset, clamp), -clamp) // Limiter l'offset dans les bornes
                    angle = convertOffsetToDegrees(newOffset: offset, clamp: clamp)
                }
        )
        .onTapGesture(count: 2, perform: {
            offset = 0
            angle = convertOffsetToDegrees(newOffset: offset, clamp: clamp)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        })
        .frame(width: width, height: height)
    }

    private func convertOffsetToDegrees(newOffset: CGFloat, clamp: CGFloat) -> CGFloat {
        // Normaliser entre 0 (en bas) et 1 (en haut)
        let normalizedValue = (clamp - newOffset) / (2 * clamp)
        return normalizedValue * 180 // Conversion en degrés (0 à 180)
    }
}

#Preview {
    PrecisionControlView()
        .environmentObject(LaserConfig())
}
