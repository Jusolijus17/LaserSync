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
    @State private var timer: Timer?
    @State private var bpmUpdateTimer: Timer?
    @State private var errorCount = 0
    @State private var showRetry = false

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            HStack {
                Text("\(laserConfig.currentBpm) BPM")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Circle()
                    .fill(showRetry || laserConfig.currentBpm == 0 ? Color.red : Color.green)
                    .frame(width: 20, height: 20)
                    .opacity(isBlinking || laserConfig.currentBpm == 0 ? 1.0 : 0.0)
                    .onAppear {
                        startBpmUpdate()
                    }
                    .onDisappear {
                        stopBpmUpdate()
                    }
            }
            
            if showRetry {
                Button(action: {
                    errorCount = 0
                    showRetry = false
                    startBpmUpdate()
                }) {
                    Label("Retry", systemImage: "arrow.clockwise.circle")
                }
            }
            
            Spacer()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                // Color
                Button(action: {
                    hapticFeedback()
                    changeLaserColor()
                }) {
                    Rectangle()
                        .fill(laserConfig.currentColor)
                        .frame(height: 150)
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.currentColorName.capitalized)
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
                Button(action: {
                    hapticFeedback()
                    changePattern()
                }) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 150)
                        .overlay(content: {
                            ZStack {
                                laserConfig.currentPattern.shape
                                    .frame(width: 100, height: 50)
                                VStack {
                                    Spacer()
                                    Text("Pattern")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .padding()
                                }
                            }
                        })
                        .cornerRadius(10)
                }
                
                // Mode
                Button(action: {
                    hapticFeedback()
                    toggleLaserMode()
                }) {
                    Rectangle()
                        .fill(laserConfig.currentMode == "manual" ? Color.green : Color.gray)
                        .frame(height: 150)
                        .overlay(content: {
                            ZStack {
                                Text(laserConfig.currentMode.capitalized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                VStack {
                                    Spacer()
                                    Text("Mode")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .padding()
                            }
                        })
                        .cornerRadius(10)
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
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            laserConfig.getCurrentBpm() { newBpm, _  in
                if newBpm {
                    self.startBlinking()
                }
            }
        }
    }
    
    func startBlinking() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(laserConfig.currentBpm) / 2, repeats: true) { _ in
            isBlinking.toggle()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
    }
    
    func restartBlinking() {
        stopBlinking()
        startBlinking()
    }
    
    func startBpmUpdate() {
        bpmUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if !isRequestInProgress {
                isRequestInProgress = true
                print("Request in progress")
                laserConfig.getCurrentBpm() { newBpm, networkError in
                    isRequestInProgress = false
                    print("Request done")
                    if networkError {
                        print("Network error")
                        errorCount += 1
                        if errorCount >= 3 {
                            stopBpmUpdate()
                            showRetry = true
                        }
                    } else {
                        errorCount = 0
                        print("Request found BPM")
                        if newBpm {
                            self.restartBlinking()
                        }
                    }
                }
            }
        }
    }

    func stopBpmUpdate() {
        bpmUpdateTimer?.invalidate()
        bpmUpdateTimer = nil
    }

    func changeLaserColor() {
        var newColorIndex: Int
        repeat {
            newColorIndex = Int.random(in: 0..<laserConfig.colors.count)
        } while newColorIndex == laserConfig.currentColorIndex
        laserConfig.currentColorIndex = newColorIndex
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

    func incrementMultiplier() {
        laserConfig.bpmMultiplier *= 2
        laserConfig.setMultiplier(multiplier: laserConfig.bpmMultiplier)
    }

    func decrementMultiplier() {
        laserConfig.bpmMultiplier = max(1 / 8, laserConfig.bpmMultiplier / 2)
        laserConfig.setMultiplier(multiplier: laserConfig.bpmMultiplier)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LaserConfig())
    }
}
