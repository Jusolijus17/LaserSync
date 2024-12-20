////
////  keep.swift
////  LaserSync
////
////  Created by Justin Lefrançois on 2024-12-19.
////
//
//struct PrecisionControlView: View {
//    @State private var panAngle: Angle = .degrees(0)    // entre -180 et 180
//        @State private var tiltAngle: Double = 0            // entre -90 et 90
//
//        var body: some View {
//            VStack(spacing: 50) {
//                CircularJoystickView(panAngle: $panAngle, diameter: 100, onPanTiltChange: { pan, tilt in
//                    print("Pan:", pan, "Tilt:", tilt)
//                    // Appelez votre fonction ici, par exemple :
//                    // laserConfig.sendGyroData(pan: pan, tilt: tilt)
//                })
//                
//                VerticalJoystickView(tiltAngle: $tiltAngle, width: 40, height: 200, onPanTiltChange: { pan, tilt in
//                    print("Pan:", pan, "Tilt:", tilt)
//                    // laserConfig.sendGyroData(pan: pan, tilt: tilt)
//                })
//                
//                VStack {
//                    Text("Pan: \(Int(panAngle.degrees))°")
//                    Text("Tilt: \(Int(tiltAngle))°")
//                }
//            }
//            .padding()
//        }
//}
//
//struct CircularJoystickView: View {
//    @Binding var panAngle: Angle
//    let diameter: CGFloat
//    
//    var onPanTiltChange: (Double, Double) -> Void
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: diameter, height: diameter)
//            
//            // Rayon sur lequel se déplace le bouton
//            let radius = diameter / 2 - (diameter / 4)
//            
//            Circle()
//                .fill(Color.blue)
//                .frame(width: diameter/4, height: diameter/4)
//                .offset(
//                    x: radius * CGFloat(cos(panAngle.radians)),
//                    y: radius * CGFloat(sin(panAngle.radians))
//                )
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            let center = CGPoint(x: 0, y: 0)
//                            let dx = value.location.x - center.x
//                            let dy = value.location.y - center.y
//                            var angle = atan2(dy, dx)
//                            
//                            // On ajoute 90° (π/2 rad) pour que le haut soit 0°
//                            angle += .pi/2
//                            
//                            // Normaliser l'angle pour qu'il soit entre -180° et 180°
//                            var degrees = angle * 180 / .pi
//                            while degrees > 180 {
//                                degrees -= 360
//                            }
//                            while degrees <= -180 {
//                                degrees += 360
//                            }
//                            
//                            panAngle = .degrees(degrees)
//                            
//                            // Appeler le callback avec le pan et un tilt = 0 car on ne le gère pas ici
//                            onPanTiltChange(degrees, 0) // Le tilt n'est pas géré dans cette vue
//                        }
//                )
//        }
//        .frame(width: diameter, height: diameter)
//    }
//}
//
//struct VerticalJoystickView: View {
//    @Binding var tiltAngle: Double
//    let width: CGFloat
//    let height: CGFloat
//    
//    var onPanTiltChange: (Double, Double) -> Void
//    
//    @State private var verticalDragPosition: CGFloat = 0
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: width, height: height)
//            
//            Circle()
//                .fill(Color.red)
//                .frame(width: width, height: width)
//                .offset(y: verticalDragPosition)
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            let halfHeight = height / 2 - (width / 2)
//                            let newOffset = value.translation.height
//                            verticalDragPosition = max(min(newOffset, halfHeight), -halfHeight)
//                            
//                            // Convertir la position verticale en un angle entre -90° et 90°
//                            let ratio = verticalDragPosition / halfHeight
//                            tiltAngle = Double(ratio * 90)
//                            
//                            // Appeler le callback avec pan=0 dans cette vue et le tilt mis à jour
//                            onPanTiltChange(0, tiltAngle)
//                        }
//                )
//        }
//        .frame(width: width, height: height)
//    }
//}
