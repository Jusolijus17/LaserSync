//
//  MovingHeadHomePage.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-28.
//

import SwiftUI

struct MovingHeadHomePage: View {
    @EnvironmentObject private var homeController: HomeController
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var isAnimatingBreathe = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Moving Head")
                .foregroundStyle(.white)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.blue)
                }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                
                // MARK: - Color
                Button(action: {
                    hapticFeedback()
                    homeController.changeMHColor()
                }) {
                    Rectangle()
                        .fill(laserConfig.movingHead.color.colorValue)
                        .frame(height: 150)
                        .background {
                            if laserConfig.movingHead.color.colorValue == .clear {
                                RoundedRectangle(cornerRadius: 10)
                                    .multicolor()
                            }
                        }
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.movingHead.color.rawValue.capitalized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(laserConfig.movingHead.color == .white ? .black : .white)
                                VStack {
                                    Spacer()
                                    Text("Color")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .padding()
                            }
                        })
                        .cornerRadius(10)
                }
                  
                // MARK: - Breathe
                SquareButton(title: "Breathe", action: {
                    print("Touch")
                    toggleMhBreathe()
                    laserConfig.setBreatheMode()
                }, backgroundColor: (isAnimatingBreathe ? Color.yellow : Color.gray), content: {
                    Image(systemName: "wave.3.up")
                        .font(.largeTitle)
                })
                .animation(Animation.linear(duration: 0.7).repeat(while: isAnimatingBreathe))
                .onChange(of: laserConfig.includedLightsBreathe) { _, newValue in
                    self.isAnimatingBreathe = newValue.contains(.movingHead)
                }
                
                // MARK: - Mode
                SquareButton(title: "Gobo", action: {
                    laserConfig.toggleMhGobo()
                }, backgroundColor: {
                    if laserConfig.movingHead.gobo == 0 {
                        return Color.gray
                    } else {
                        return Color.yellow
                    }
                }()) {
                    Text("\(laserConfig.movingHead.gobo)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.movingHead.gobo = 0
                    laserConfig.setMhGobo()
                }
                
                // MARK: - Scene
                SquareButton(title: "Scene", action: {
                    laserConfig.toggleMHScene()
                }, backgroundColor: {
                    if laserConfig.movingHead.scene == .slow {
                        return .blue
                    } else if laserConfig.movingHead.scene == .medium {
                        return .orange
                    } else if laserConfig.movingHead.scene == .fast {
                        return .red
                    }
                    return .gray
                }()) {
                    Text(laserConfig.movingHead.scene.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.toggleMHScene(.off)
                }
            }
            
            // MARK: - Brightness
            CustomSliderView(sliderValue: $laserConfig.movingHead.brightness, title: "Brightness", onValueChange: { newValue in
                if newValue > 0 {
                    laserConfig.movingHead.mode = .manual
                } else {
                    laserConfig.movingHead.mode = .blackout
                    laserConfig.includedLightsBreathe.remove(.movingHead)
                }
                laserConfig.setBrightnessFor(.movingHead, brightness: laserConfig.movingHead.brightness)
            })
            
            // MARK: - Strobe Speed
            CustomSliderView(sliderValue: $laserConfig.movingHead.strobeSpeed, title: "Strobe", onValueChange: { _ in
                laserConfig.setStrobeSpeedFor(.movingHead, strobeSpeed: laserConfig.movingHead.strobeSpeed)
            })
        }
        .padding(.horizontal, 20)
    }
    
    private func toggleMhBreathe() {
        if laserConfig.includedLightsBreathe.contains(.movingHead) {
            laserConfig.includedLightsBreathe.remove(.movingHead)
        } else {
            laserConfig.includedLightsBreathe.insert(.movingHead)
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    MovingHeadHomePage()
        .environmentObject(LaserConfig())
        .environmentObject(HomeController())
}
