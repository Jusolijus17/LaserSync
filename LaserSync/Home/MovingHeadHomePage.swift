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
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.cyan)
                }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                
                // Color
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
                  
                // Breathe
                SquareButton(title: "Breathe", action: {
                    print("Touch")
                    laserConfig.toggleMhBreathe()
                }, backgroundColor: (isAnimatingBreathe ? Color.yellow : Color.gray), content: {
                    Image(systemName: "wave.3.up")
                        .font(.largeTitle)
                })
                .animation(Animation.linear(duration: 0.7).repeat(while: isAnimatingBreathe))
                .onChange(of: laserConfig.movingHead.breathe) { _, newValue in
                    print(newValue)
                    self.isAnimatingBreathe = newValue
                }
                
                // Mode
                SquareButton(title: "Mode", action: {
                    laserConfig.toggleMHMode()
                }, backgroundColor: {
                    if laserConfig.movingHead.mode == .blackout {
                        return Color.gray
                    } else if laserConfig.movingHead.mode == .sound {
                        return Color.green
                    } else {
                        return Color.yellow
                    }
                }()) {
                    Text(laserConfig.movingHead.mode.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.turnOffMovingHead()
                }
                
                // Scene
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
            
            CustomSliderView(sliderValue: $laserConfig.movingHead.brightness, title: "Brightness", onValueChange: { newValue in
                if newValue > 0 {
                    laserConfig.movingHead.mode = .manual
                } else {
                    laserConfig.movingHead.mode = .blackout
                    laserConfig.movingHead.breathe = false
                }
                laserConfig.setMHBrightness()
            })
            
            CustomSliderView(sliderValue: $laserConfig.movingHead.strobeSpeed, title: "Strobe", onValueChange: { _ in
                laserConfig.setMHStrobe()
            })
        }
        .padding(.horizontal, 20)
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
