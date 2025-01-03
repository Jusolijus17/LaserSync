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
    @State private var isAnimatingBreathe = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Spider Head")
                .foregroundStyle(.white)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.green)
                }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                
                // MARK: - Color
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
                
                // MARK: - Scene
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
            
            // MARK: - Breathe
            
            Button {
                toggleShBreathe()
                laserConfig.setBreatheMode()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isAnimatingBreathe ? Color.yellow : Color.gray)
                    .frame(height: 50)
                    .overlay {
                        Label("Breathe", systemImage: "wave.3.up")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
            }
            .animation(Animation.linear(duration: 0.7).repeat(while: isAnimatingBreathe))
            .onChange(of: laserConfig.includedLightsBreathe) { _, newValue in
                self.isAnimatingBreathe = newValue.contains(.spiderHead)
            }
            
            // MARK: - Brightness
            CustomSliderView(sliderValue: $laserConfig.spiderHead.brightness, title: "Brightness", onValueChange: { newValue in
                if newValue > 0 {
                    laserConfig.spiderHead.mode = .manual
                } else {
                    laserConfig.spiderHead.mode = .blackout
                }
                laserConfig.setBrightnessFor(.spiderHead, brightness: laserConfig.spiderHead.brightness)
            })
            
            // MARK: - Strobe Speed
            CustomSliderView(sliderValue: $laserConfig.spiderHead.strobeSpeed, title: "Strobe", onValueChange: { _ in
                laserConfig.setStrobeSpeedFor(.spiderHead, strobeSpeed: laserConfig.spiderHead.strobeSpeed)
            })
            
            // MARK: - Light chase
            CustomSliderView(sliderValue: $laserConfig.spiderHead.lightChaseSpeed, title: "Chase") { speed in
                laserConfig.setLightChaseSpeed(speed)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func toggleShBreathe() {
        if laserConfig.includedLightsBreathe.contains(.spiderHead) {
            laserConfig.includedLightsBreathe.remove(.spiderHead)
        } else {
            laserConfig.includedLightsBreathe.insert(.spiderHead)
        }
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
