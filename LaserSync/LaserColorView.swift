//
//  LaserColorView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI
import UIKit

struct LaserColorView: View {
    @EnvironmentObject var laserConfig: LaserConfig

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 1) {
                Button {
                    hapticFeedback()
                    laserConfig.toggleIncludedLightsForColor(light: .laser)
                } label: {
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 15)
                        .fill(laserConfig.lightControlColor.contains(.laser) ? .green : .gray)
                        .frame(height: 75)
                        .overlay(content: {
                            Text("Laser")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        })
                        .padding([.vertical, .leading], 5)
                }
                Button {
                    hapticFeedback()
                    laserConfig.toggleIncludedLightsForColor(light: .movingHead)
                } label: {
                    RoundedCornerShape(corners: [.topRight, .bottomRight], radius: 15)
                        .fill(laserConfig.lightControlColor.contains(.movingHead) ? .green : .gray)
                        .frame(height: 75)
                        .overlay(content: {
                            Text("Moving Head")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        })
                        .padding([.vertical, .trailing], 5)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.clear)
                    .stroke(.gray, lineWidth: 3)
            }
            .padding(.horizontal, 20)
            
            Spacer()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(1..<getColorCount(), id: \.self) { index in
                    Button(action: {
                        hapticFeedback()
                        changeColor(specificColorIndex: index)
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(getColors()[index].color)
                            .stroke(getStrokeColor(index: index), lineWidth: 3)
                            .frame(height: 100)
                            .overlay(content: {
                                Text(getColors()[index].name.capitalized)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(getColors()[index].color == .white ? .black : .white)
                            })
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            if laserConfig.getChangeColorTarget() == .laser {
                Button(action: {
                    hapticFeedback()
                    changeColor(specificColorIndex: 0)
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .multicolor()
                        .frame(height: 50)
                        .overlay(content: {
                            Text(laserConfig.laserColors[0].name.capitalized)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        })
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    hapticFeedback()
                    laserConfig.toggleBpmSync(type: "color")
                }) {
                    Text("BPM Sync")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(laserConfig.activeSyncTypes.contains("color") ? Color.yellow : Color.gray)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 20)
                Spacer()
            } else if laserConfig.getChangeColorTarget() == .movingHead {
                CustomSliderView(sliderValue: $laserConfig.mHColorSpeed, title: "Color speed")
                    .onChange(of: laserConfig.mHColorSpeed) { _, newValue in
                        laserConfig.setMHColorSpeed()
                        if newValue == 0 || newValue == 100 {
                            hapticFeedback()
                        }
                    }
                    .padding(.horizontal, 20)
                Spacer()
            }
        }
    }

    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func changeColor(specificColorIndex: Int? = nil) {
        if laserConfig.getChangeColorTarget() == .laser {
            if let index = specificColorIndex {
                laserConfig.currentLaserColorIndex = index
            } else {
                laserConfig.currentLaserColorIndex = (laserConfig.currentLaserColorIndex + 1) % laserConfig.laserColors.count
            }
            laserConfig.setColor()
        } else if laserConfig.getChangeColorTarget() == .movingHead {
            if let index = specificColorIndex {
                laserConfig.currentMHColorIndex = index
            } else {
                laserConfig.currentMHColorIndex = (laserConfig.currentMHColorIndex + 1) % laserConfig.mHColors.count
            }
            laserConfig.setColor()
        } else if laserConfig.getChangeColorTarget() == .both {
            if let index = specificColorIndex {
                laserConfig.currentMHColorIndex = index
                laserConfig.currentLaserColorIndex = index
            } else {
                laserConfig.currentMHColorIndex = (laserConfig.currentMHColorIndex + 1) % laserConfig.mHColors.count
                laserConfig.currentLaserColorIndex = (laserConfig.currentLaserColorIndex + 1) % laserConfig.laserColors.count
            }
            laserConfig.setColor()
        }
    }
    
    func getStrokeColor(index: Int) -> Color {
        if laserConfig.getChangeColorTarget() == .laser {
            return laserConfig.currentLaserColorIndex == index ? .white : .clear
        } else if laserConfig.getChangeColorTarget() == .movingHead {
            return laserConfig.currentMHColorIndex == index ? .white : .clear
        } else if laserConfig.getChangeColorTarget() == .both {
            return laserConfig.currentLaserColorIndex == index ? .white : .clear
        }
        return .clear
    }
    
    func getColorCount() -> Int {
        if laserConfig.getChangeColorTarget() == .movingHead {
            return laserConfig.mHColors.count
        }
        return laserConfig.laserColors.count
    }
    
    func getColors() -> [(name: String, color: Color)] {
        if laserConfig.getChangeColorTarget() == .movingHead {
            return laserConfig.mHColors
        }
        return laserConfig.laserColors
    }
}

struct HalfRoundedButton: View {
    var body: some View {
        Button(action: {
            // Action à réaliser lors du clic
            print("Button clicked!")
        }) {
            Text("Custom Button")
                .padding()
                .frame(width: 200, height: 50)
                .background(
                    RoundedCornerShape(corners: [.topLeft, .bottomLeft], radius: 20)
                        .fill(Color.blue)
                )
                .foregroundColor(.white)
        }
    }
}

// Créer une forme personnalisée avec coins arrondis spécifiques
struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct LaserColorView_Previews: PreviewProvider {
    static var previews: some View {
        LaserColorView()
            .environmentObject(LaserConfig())
    }
}
