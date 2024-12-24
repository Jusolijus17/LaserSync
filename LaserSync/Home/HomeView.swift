//
//  HomeView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-05.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @StateObject private var homeController = HomeController()
    
    var body: some View {
        VStack {
            
            HStack {
                Text("\(laserConfig.currentBpm) BPM")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .onChange(of: laserConfig.networkErrorCount) {
                        if laserConfig.networkErrorCount >= 3 {
                            homeController.showRetry = true
                            homeController.stopBlinking()
                        }
                    }
                
                Circle()
                    .fill(homeController.getBpmIndicatorColor())
                    .frame(width: 20, height: 20)
                    .opacity(homeController.isBlinking || laserConfig.currentBpm == 0 ? 1.0 : 0.0)
            }
            
            Button(action: {
                laserConfig.restartBpmUpdate()
                homeController.showRetry = false
            }) {
                Label("Retry", systemImage: "arrow.clockwise.circle")
            }
            .opacity(homeController.showRetry ? 1 : 0)

            
            TabView {
                laserControlGrid
                movingHeadControlGrid
                LaunchpadView()
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onChange(of: laserConfig.currentBpm) {
            if laserConfig.currentBpm != 0 {
                homeController.restartBlinking()
            }
        }
        .onAppear {
            homeController.setLaserConfig(laserConfig)
        }
    }
    
    // MARK: -Laser Page
    
    var laserControlGrid: some View {
        VStack(spacing: 20) {
            Text("Laser")
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
                    homeController.changeLaserColor()
                }) {
                    Rectangle()
                        .fill(laserConfig.laserColor)
                        .frame(height: 150)
                        .background {
                            if laserConfig.laserColor == .clear {
                                RoundedRectangle(cornerRadius: 10)
                                    .multicolor()
                            }
                        }
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.laserColor.name?.capitalized ?? "Multicolor")
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
                    AnyView(
                        laserConfig.currentLaserPattern.shape
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 50)
                    )
                }
                
                // Mode
                SquareButton(title: "Mode", action: {
                    homeController.toggleLaserMode()
                }, backgroundColor: {
                    if laserConfig.laserMode == .manual {
                        return Color.yellow
                    } else if laserConfig.laserMode != .blackout {
                        return Color.green
                    }
                    return Color.gray
                }()) {
                    AnyView(
                        Text(laserConfig.laserMode.rawValue.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                
                // BPM Multiplier
                VStack {
                    ZStack {
                        HStack {
                            Button {
                                hapticFeedback()
                                homeController.decrementMultiplier()
                            } label: {
                                Image(systemName: "minus")
                                    .font(.title2)
                                    .frame(height: 25)
                                    .foregroundStyle(.red)
                                    .padding(5)
                                    .background {
                                        Circle()
                                            .foregroundStyle(.white)
                                    }
                            }
                            
                            Text(homeController.multiplierText())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Button {
                                hapticFeedback()
                                homeController.incrementMultiplier()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundStyle(.green)
                                    .padding(5)
                                    .background {
                                        Circle()
                                            .foregroundStyle(.white)
                                    }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            Text("BPM multiplier")
                                .padding()
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(homeController.multiplierColor())
                .cornerRadius(10)
                
                SquareButton(title: "H-Animation", action: {
                    homeController.toggleHorizontalAnimation()
                }, backgroundColor: homeController.isHorizontalAnimationBlinking ? Color.yellow : Color.gray) {
                    AnyView(
                        Text(laserConfig.horizontalAnimationEnabled ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                .onAppear {
                    if laserConfig.horizontalAnimationEnabled {
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
                    AnyView(
                        Text(laserConfig.verticalAnimationEnabled ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                .onAppear {
                    if laserConfig.verticalAnimationEnabled {
                        homeController.startVerticalBlinking()
                    } else {
                        homeController.stopVerticalBlinking()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Moving Head Page
    
    @State private var isAnimatingBreathe = false
    var movingHeadControlGrid: some View {
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
                        .fill(laserConfig.mHColor)
                        .frame(height: 150)
                        .background {
                            if laserConfig.mHColor == .clear {
                                RoundedRectangle(cornerRadius: 10)
                                    .multicolor()
                            }
                        }
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.mHColor.name?.capitalized ?? "Auto")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(laserConfig.mHColor == .white ? .black : .white)
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
                   
                SquareButton(title: "Breathe", action: {
                    print("Touch")
                    laserConfig.toggleMhBreathe()
                }, backgroundColor: (isAnimatingBreathe ? Color.yellow : Color.gray), content: {
                    AnyView(
                        Image(systemName: "wave.3.up")
                            .font(.largeTitle)
                    )
                })
                .animation(Animation.linear(duration: 0.7).repeat(while: isAnimatingBreathe))
                .onChange(of: laserConfig.mHBreathe) { _, newValue in
                    print(newValue)
                    self.isAnimatingBreathe = newValue
                }
                
                // Mode
                SquareButton(title: "Mode", action: {
                    laserConfig.toggleMHMode()
                }, backgroundColor: {
                    if laserConfig.mHMode == .blackout {
                        return Color.gray
                    } else if laserConfig.mHMode == .sound {
                        return Color.green
                    } else {
                        return Color.yellow
                    }
                }()) {
                    AnyView(
                        Text(laserConfig.mHMode.rawValue.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.toggleMHMode(.blackout)
                    laserConfig.toggleMHScene(.off)
                    laserConfig.mHBreathe = false
                    laserConfig.mHBrightness = 0
                }
                
                // Scene
                SquareButton(title: "Scene", action: {
                    laserConfig.toggleMHScene()
                }, backgroundColor: {
                    if laserConfig.mhScene == .slow {
                        return .blue
                    } else if laserConfig.mhScene == .medium {
                        return .orange
                    } else if laserConfig.mhScene == .fast {
                        return .red
                    }
                    return .gray
                }()) {
                    AnyView(
                        Text(laserConfig.mhScene.rawValue.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                .onLongPressGesture {
                    hapticFeedback()
                    laserConfig.toggleMHScene(.off)
                }
            }
            
            CustomSliderView(sliderValue: $laserConfig.mHBrightness, title: "Brightness", onValueChange: { newValue in
                if newValue > 0 {
                    laserConfig.mHMode = .manual
                } else {
                    laserConfig.mHMode = .blackout
                    laserConfig.mHBreathe = false
                }
                laserConfig.setMHBrightness()
            })
            
            CustomSliderView(sliderValue: $laserConfig.mHStrobe, title: "Strobe", onValueChange: { _ in
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

struct SquareButton: View {
    var title: String
    var action: () -> Void
    var backgroundColor: Color = Color.gray
    var content: () -> AnyView

    var body: some View {
        ZStack { // Utiliser un conteneur ZStack au lieu d'un Button
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 150)
                .overlay(content: {
                    ZStack {
                        content()
                        VStack {
                            Spacer()
                            Text(title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.5))
                                .padding()
                        }
                    }
                })
                .cornerRadius(10)
        }
        .onTapGesture {
            hapticFeedback()
            action()
        } // Action principale
    }

    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LaserConfig())
            .environmentObject(SharedStates())
    }
}
