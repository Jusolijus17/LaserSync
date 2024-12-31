//
//  SpiderLightPage.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-28.
//

import SwiftUI

struct SpiderHeadHomePage: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @EnvironmentObject private var homeController: HomeController
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Spider Head")
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
                    homeController.changeSHColor()
                }) {
                    Rectangle()
                        .fill(laserConfig.spiderHead.color.colorValue)
                        .frame(height: 150)
                        .background {
                            if laserConfig.spiderHead.color.colorValue == .clear {
                                RoundedRectangle(cornerRadius: 10)
                                    .multicolor()
                            }
                        }
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.spiderHead.color.rawValue.capitalized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(laserConfig.spiderHead.color == .white ? .black : .white)
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
//                SquareButton(title: "Breathe", action: {
//                    print("Touch")
//                    laserConfig.toggleMhBreathe()
//                }, backgroundColor: (isAnimatingBreathe ? Color.yellow : Color.gray), content: {
//                    Image(systemName: "wave.3.up")
//                        .font(.largeTitle)
//                })
//                .animation(Animation.linear(duration: 0.7).repeat(while: isAnimatingBreathe))
//                .onChange(of: laserConfig.spiderHead.breathe) { _, newValue in
//                    print(newValue)
//                    self.isAnimatingBreathe = newValue
//                }
                
                // Mode
                SquareButton(title: "Mode", action: {
                    laserConfig.toggleSHMode()
                }, backgroundColor: {
                    if laserConfig.spiderHead.mode == .blackout {
                        return Color.gray
                    } else if laserConfig.spiderHead.mode == .sound {
                        return Color.green
                    } else {
                        return Color.yellow
                    }
                }()) {
                    Text(laserConfig.spiderHead.mode.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.spiderHead.mode = .blackout
                    laserConfig.setModeFor(.spiderHead, mode: .blackout)
                }
                
                // Scene
                SquareButton(title: "Scene", action: {
                    laserConfig.toggleSHScene()
                }, backgroundColor: {
                    if laserConfig.spiderHead.scene == .slow {
                        return .blue
                    } else if laserConfig.spiderHead.scene == .medium {
                        return .orange
                    } else if laserConfig.spiderHead.scene == .fast {
                        return .red
                    }
                    return .gray
                }()) {
                    Text(laserConfig.spiderHead.scene.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.toggleSHScene(.off)
                }
            }
            
            CustomSliderView(sliderValue: $laserConfig.spiderHead.brightness, title: "Brightness", onValueChange: { newValue in
                if newValue > 0 {
                    laserConfig.spiderHead.mode = .manual
                } else {
                    laserConfig.spiderHead.mode = .blackout
                }
                laserConfig.setBrightnessFor(.spiderHead, brightness: laserConfig.spiderHead.brightness)
            })
            
            CustomSliderView(sliderValue: $laserConfig.spiderHead.strobeSpeed, title: "Strobe", onValueChange: { _ in
                laserConfig.setStrobeSpeedFor(.spiderHead, strobeSpeed: laserConfig.spiderHead.strobeSpeed)
            })
        }
        .padding(.horizontal, 20)
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct SpiderHomePage_Previews: View {
    @StateObject private var homeController = HomeController()
    @StateObject private var laserConfig = LaserConfig()
    
    var body: some View {
        SpiderHeadHomePage()
            .environmentObject(homeController)
            .environmentObject(laserConfig)
            .onAppear {
                homeController.setLaserConfig(laserConfig)
            }
    }
}

#Preview {
    SpiderHomePage_Previews()
}
