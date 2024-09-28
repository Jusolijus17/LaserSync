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
    @State private var isRequestInProgress = false
    @State private var isBlinking = false
    @State private var blinkingTimer: Timer?
    @State private var networkErrorCount = 0
    @State private var showRetry = false
    @State private var isHorizontalAnimationBlinking = false
    @State private var isVerticalAnimationBlinking = false
    @State private var horizontalBlinkTimer: Timer?
    @State private var verticalBlinkTimer: Timer?
    
    @State var touchDownTime: Date?
    @State var isPressed = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            HStack {
                Text("\(laserConfig.currentBpm) BPM")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .onChange(of: laserConfig.networkErrorCount) {
                        if laserConfig.networkErrorCount >= 3 {
                            self.showRetry = true
                            self.stopBlinking()
                        }
                    }
                
                Circle()
                    .fill(getBpmIndicatorColor())
                    .frame(width: 20, height: 20)
                    .opacity(isBlinking || laserConfig.currentBpm == 0 ? 1.0 : 0.0)
            }
            
            if showRetry {
                Button(action: {
                    laserConfig.restartBpmUpdate()
                    showRetry = false
                }) {
                    Label("Retry", systemImage: "arrow.clockwise.circle")
                }
            }

            
            TabView {
                laserControlGrid
                movingHeadControlGrid
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onChange(of: laserConfig.currentBpm) {
            if laserConfig.currentBpm != 0 {
                self.restartBlinking()
            }
        }
    }
    
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
                    changeMHColor()
                }) {
                    Rectangle()
                        .fill(laserConfig.currentMHColor)
                        .frame(height: 150)
                        .background {
                            if laserConfig.currentMHColorName == "auto" {
                                RoundedRectangle(cornerRadius: 10)
                                    .multicolor()
                            }
                        }
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.currentMHColorName.capitalized)
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
                
                // Manual Strobe
                Button(action: {
                }) {
                    Rectangle()
                        .fill(isPressed ? .white : .gray)
                        .frame(height: 150)
                        .overlay(content: {
                            ZStack {
                                Image(systemName: "exclamationmark.warninglight")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                                VStack {
                                    Spacer()
                                    Text("Strobe")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .padding()
                                }
                            }
                        })
                        .cornerRadius(10)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ value in
                                    if touchDownTime == nil {
                                        touchDownTime = value.time
                                        hapticFeedback()
                                        laserConfig.startMHStrobe()
                                        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                            isPressed.toggle()
                                        }
                                    }
                                })
                                .onEnded({ value in
                                    laserConfig.stopMHStrobe()
                                    if let touchDownTime,
                                       value.time.timeIntervalSince(touchDownTime) >= 1 { }
                                    hapticFeedback()
                                    self.touchDownTime = nil
                                    isPressed = false
                                    timer?.invalidate()
                                    timer = nil
                                })
                        )
                }
                
                // Mode
                SquareButton(title: "Mode", action: {
                    laserConfig.toggleMHMode()
                }, backgroundColor: {
                    if laserConfig.mHMode == .blackout {
                        return Color.gray
                    } else if laserConfig.mHMode == .auto {
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
            }
            
            CustomSliderView(sliderValue: $laserConfig.mHDimmer, title: "Brightness")
                .onChange(of: laserConfig.mHDimmer) { _, newValue in
                    if newValue > 0 {
                        laserConfig.mHMode = .manual
                    } else {
                        laserConfig.mHMode = .blackout
                    }
                    laserConfig.setMHDimmer()
                    if newValue == 0 || newValue == 100 {
                        hapticFeedback()
                    }
                }
            
            CustomSliderView(sliderValue: $laserConfig.mHStrobe, title: "Strobe")
                .onChange(of: laserConfig.mHStrobe) { _, newValue in
                    laserConfig.setMHStrobe()
                    if newValue == 0 || newValue == 100 {
                        hapticFeedback()
                    }
                }
        }
        .padding(.horizontal, 20)
    }
    
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
                    changeLaserColor()
                }) {
                    Rectangle()
                        .fill(laserConfig.currentLaserColor)
                        .frame(height: 150)
                        .background {
                            if laserConfig.currentLaserColorName == "multicolor" {
                                RoundedRectangle(cornerRadius: 10)
                                    .multicolor()
                            }
                        }
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.currentLaserColorName.capitalized)
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
                    changePattern()
                } content: {
                    AnyView(
                        laserConfig.currentPattern.shape
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 50)
                    )
                }
                
                // Mode
                SquareButton(title: "Mode", action: {
                    toggleLaserMode()
                }, backgroundColor: laserConfig.currentMode == "manual" ? Color.green : Color.gray) {
                    AnyView(
                        Text(laserConfig.currentMode.capitalized)
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
                                decrementMultiplier()
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
                            
                            Text(multiplierText())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Button {
                                hapticFeedback()
                                incrementMultiplier()
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
                .background(multiplierColor())
                .cornerRadius(10)
                
                SquareButton(title: "H-Animation", action: {
                    toggleHorizontalAnimation()
                }, backgroundColor: isHorizontalAnimationBlinking ? Color.yellow : Color.gray) {
                    AnyView(
                        Text(laserConfig.horizontalAnimationEnabled ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                .onAppear {
                    if laserConfig.horizontalAnimationEnabled {
                        startHorizontalBlinking()
                    } else {
                        stopHorizontalBlinking()
                    }
                }
                .onDisappear {
                    stopHorizontalBlinking()
                    stopVerticalBlinking()
                }
                
                SquareButton(title: "V-Animation", action: {
                    toggleVerticalAnimation()
                }, backgroundColor: isVerticalAnimationBlinking ? Color.yellow : Color.gray) {
                    AnyView(
                        Text(laserConfig.verticalAnimationEnabled ? "ON" : "OFF")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    )
                }
                .onAppear {
                    if laserConfig.verticalAnimationEnabled {
                        startVerticalBlinking()
                    } else {
                        stopVerticalBlinking()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    func startBlinking() {
        blinkingTimer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(laserConfig.currentBpm) / 2, repeats: true) { _ in
            isBlinking.toggle()
        }
    }

    func stopBlinking() {
        blinkingTimer?.invalidate()
        blinkingTimer = nil
        isBlinking = true
    }
    
    func restartBlinking() {
        stopBlinking()
        startBlinking()
    }
    
    func getBpmIndicatorColor() -> Color {
        if showRetry || laserConfig.currentBpm == 0 {
            return Color.red
        } else if laserConfig.networkErrorCount > 0 {
            return Color.orange
        } else {
            return Color.green
        }
    }

    func changeLaserColor() {
        var newColorIndex: Int
        repeat {
            newColorIndex = Int.random(in: 0..<laserConfig.laserColors.count)
        } while newColorIndex == laserConfig.currentLaserColorIndex
        laserConfig.currentLaserColorIndex = newColorIndex
        laserConfig.setColor()
    }
    
    func changeMHColor() {
        var newColorIndex: Int
        repeat {
            newColorIndex = Int.random(in: 0..<laserConfig.laserColors.count)
        } while newColorIndex == laserConfig.currentMHColorIndex
        laserConfig.currentMHColorIndex = newColorIndex
        laserConfig.setColor()
    }

    func changePattern() {
        var newPatternIndex: Int
        repeat {
            newPatternIndex = Int.random(in: 0..<laserConfig.patterns.count)
        } while newPatternIndex == laserConfig.currentPatternIndex
        laserConfig.currentPatternIndex = newPatternIndex
        laserConfig.setPattern()
    }

    func toggleLaserMode() {
        laserConfig.currentMode = laserConfig.currentMode == "manual" ? "blackout" : "manual"
        laserConfig.setMode()
    }
    
    func startHorizontalBlinking() {
        isHorizontalAnimationBlinking = true
        horizontalBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            isHorizontalAnimationBlinking.toggle()
        }
    }

    func stopHorizontalBlinking() {
        horizontalBlinkTimer?.invalidate()
        horizontalBlinkTimer = nil
        isHorizontalAnimationBlinking = false
    }

    func startVerticalBlinking() {
        isVerticalAnimationBlinking = true
        verticalBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            isVerticalAnimationBlinking.toggle()
        }
    }

    func stopVerticalBlinking() {
        verticalBlinkTimer?.invalidate()
        verticalBlinkTimer = nil
        isVerticalAnimationBlinking = false
    }

    func toggleHorizontalAnimation() {
        laserConfig.horizontalAnimationEnabled.toggle()
        if laserConfig.horizontalAnimationEnabled {
            startHorizontalBlinking()
        } else {
            stopHorizontalBlinking()
        }
        laserConfig.setHorizontalAnimation()
    }

    func toggleVerticalAnimation() {
        laserConfig.verticalAnimationEnabled.toggle()
        if laserConfig.verticalAnimationEnabled {
            startVerticalBlinking()
        } else {
            stopVerticalBlinking()
        }
        laserConfig.setVerticalAnimation()
    }


    func incrementMultiplier() {
        laserConfig.bpmMultiplier *= 2
        laserConfig.setMultiplier(multiplier: laserConfig.bpmMultiplier)
        laserConfig.restartBpmSyncTimer()
    }

    func decrementMultiplier() {
        laserConfig.bpmMultiplier = max(1 / 8, laserConfig.bpmMultiplier / 2)
        laserConfig.setMultiplier(multiplier: laserConfig.bpmMultiplier)
        laserConfig.restartBpmSyncTimer()
    }

    func multiplierText() -> String {
        if laserConfig.bpmMultiplier == 1.0 {
            return "1x"
        } else if laserConfig.bpmMultiplier < 1.0 {
            return "÷\(Int(1 / laserConfig.bpmMultiplier))"
        } else {
            return "x\(Int(laserConfig.bpmMultiplier))"
        }
    }
    
    func multiplierColor() -> Color {
        switch laserConfig.bpmMultiplier {
        case 1/8:
            return Color.purple
        case 1/4:
            return Color.blue
        case 1/2:
            return Color.cyan
        case 1.0:
            return Color.gray
        case 2.0:
            return Color.green
        case 4.0:
            return Color.yellow
        case 8.0:
            return Color.orange
        default:
            return Color.red
        }
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
        Button(action: {
            hapticFeedback()
            action()
        }) {
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
    }
}
