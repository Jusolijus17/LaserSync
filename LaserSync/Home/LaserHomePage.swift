//
//  LaserPage.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-28.
//

import SwiftUI

struct LaserHomePage: View {
    @EnvironmentObject private var homeController: HomeController
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var showPatternSelector: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Laser")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.red)
                    }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    // Color
                    Button(action: {
                        hapticFeedback()
                        homeController.changeLaserColor()
                    }) {
                        Rectangle()
                            .fill(laserConfig.laser.color.colorValue)
                            .frame(height: 150)
                            .background {
                                if laserConfig.laser.color.colorValue == .clear {
                                    RoundedRectangle(cornerRadius: 10)
                                        .multicolor()
                                }
                            }
                            .overlay(content: {
                                ZStack {
                                    Text(laserConfig.laser.color.rawValue.capitalized)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
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
                    
                    // Pattern
                    SquareButton(title: "Pattern") {
                        homeController.changePattern()
                    } content: {
                        laserConfig.laser.pattern.shape
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 50)
                    }
                    .onLongPressGesture(minimumDuration: 0.2) {
                        hapticFeedback()
                        showPatternSelector = true
                    }
                    
                    // Color Sync
                    SquareButton(title: "Color Sync", action: {
                        hapticFeedback()
                        laserConfig.toggleBpmSync(mode: .color)
                    }, backgroundColor: {
                        laserConfig.laser.bpmSyncModes.contains(.color) ? Color.yellow : Color.gray
                    }()) {
                        Text(laserConfig.laser.bpmSyncModes.contains(.color) ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    
                    //Pattern Sync
                    SquareButton(title: "Pattern Sync", action: {
                        hapticFeedback()
                        laserConfig.toggleBpmSync(mode: .pattern)
                    }, backgroundColor: {
                        laserConfig.laser.bpmSyncModes.contains(.pattern) ? Color.yellow : Color.gray
                    }()) {
                        Text(laserConfig.laser.bpmSyncModes.contains(.pattern) ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    
                    SquareButton(title: "H-Animation", action: {
                        homeController.toggleHorizontalAnimation()
                    }, backgroundColor: homeController.isHorizontalAnimationBlinking ? Color.yellow : Color.gray) {
                        Text(laserConfig.laser.horizontalAnimationEnabled ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .onAppear {
                        if laserConfig.laser.horizontalAnimationEnabled {
                            homeController.startHorizontalBlinking()
                        } else {
                            homeController.stopHorizontalBlinking()
                        }
                    }
                    .onDisappear {
                        homeController.stopHorizontalBlinking()
                        homeController.stopVerticalBlinking()
                    }
                    
                    SquareButton(title: "V-Animation", action: {
                        homeController.toggleVerticalAnimation()
                    }, backgroundColor: homeController.isVerticalAnimationBlinking ? Color.yellow : Color.gray) {
                        Text(laserConfig.laser.verticalAnimationEnabled ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .onAppear {
                        if laserConfig.laser.verticalAnimationEnabled {
                            homeController.startVerticalBlinking()
                        } else {
                            homeController.stopVerticalBlinking()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .blur(radius: showPatternSelector ? 10 : 0)
            
            // Couche modale
            if showPatternSelector {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showPatternSelector = false
                    }
                
                PatternSelector()
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.secondary)
                    }
                    .padding()
            }
        }
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct LaserHomePage_Previews: View {
    @StateObject private var homeController = HomeController()
    @StateObject private var laserConfig = LaserConfig()
    
    var body: some View {
        LaserHomePage()
            .environmentObject(homeController)
            .environmentObject(laserConfig)
            .onAppear {
                homeController.setLaserConfig(laserConfig)
            }
    }
}

#Preview {
    LaserHomePage_Previews()
}
