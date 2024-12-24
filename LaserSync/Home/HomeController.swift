//
//  HomeController.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-21.
//

import SwiftUI

class HomeController: ObservableObject {
    private var laserConfig: LaserConfig?
    
    @Published var isRequestInProgress = false
    @Published var isBlinking = false
    @Published var blinkingTimer: Timer?
    @Published var networkErrorCount = 0
    @Published var showRetry = false
    @Published var isHorizontalAnimationBlinking = false
    @Published var isVerticalAnimationBlinking = false
    @Published var horizontalBlinkTimer: Timer?
    @Published var verticalBlinkTimer: Timer?
    
    @Published var touchDownTime: Date?
    @Published var isPressed = false
    @Published var timer: Timer?
    
    func setLaserConfig(_ laserConfig: LaserConfig) {
        self.laserConfig = laserConfig
    }
    
    func startBlinking() {
        guard let laserConfig else { return }
        blinkingTimer = Timer.scheduledTimer(withTimeInterval: 60.0 / Double(laserConfig.currentBpm) / 2, repeats: true) { _ in
            self.isBlinking.toggle()
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
        guard let laserConfig else { return .orange }
        if !laserConfig.successfullBpmFetch && !showRetry {
            return Color.orange
        } else if showRetry {
            return Color.red
        } else {
            return Color.green
        }
    }

    func changeLaserColor() {
        guard let laserConfig else { return }
        var nextColor: Color? = laserConfig.laserColor
        repeat {
            nextColor = LaserColor.allCases.randomElement()?.color
        } while nextColor == laserConfig.laserColor || nextColor == nil
        laserConfig.laserColor = nextColor!
        laserConfig.changeColor(light: .laser, color: laserConfig.laserColor)
    }
    
    func changeMHColor() {
        guard let laserConfig else { return }
        var nextColor: Color? = laserConfig.mHColor
        repeat {
            nextColor = MovingHeadColor.allCases.randomElement()?.color
        } while nextColor == laserConfig.mHColor || nextColor == nil
        laserConfig.mHColor = nextColor!
        laserConfig.changeColor(light: .movingHead, color: laserConfig.mHColor)
    }

    func changePattern() {
        guard let laserConfig else { return }
        var newPattern: LaserPattern
        repeat {
            newPattern = LaserPattern.allCases.randomElement()!
        } while newPattern == laserConfig.currentLaserPattern
        laserConfig.currentLaserPattern = newPattern
        laserConfig.setPattern()
    }

    func toggleLaserMode() {
        guard let laserConfig else { return }
        laserConfig.laserMode = laserConfig.laserMode == .manual ? .blackout : .manual
        laserConfig.setModeFor(.laser)
    }
    
    func startHorizontalBlinking() {
        isHorizontalAnimationBlinking = true
        horizontalBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.isHorizontalAnimationBlinking.toggle()
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
            self.isVerticalAnimationBlinking.toggle()
        }
    }

    func stopVerticalBlinking() {
        verticalBlinkTimer?.invalidate()
        verticalBlinkTimer = nil
        isVerticalAnimationBlinking = false
    }

    func toggleHorizontalAnimation() {
        guard let laserConfig else { return }
        laserConfig.horizontalAnimationEnabled.toggle()
        if laserConfig.horizontalAnimationEnabled {
            startHorizontalBlinking()
        } else {
            stopHorizontalBlinking()
        }
        laserConfig.setHorizontalAnimation()
    }

    func toggleVerticalAnimation() {
        guard let laserConfig else { return }
        laserConfig.verticalAnimationEnabled.toggle()
        if laserConfig.verticalAnimationEnabled {
            startVerticalBlinking()
        } else {
            stopVerticalBlinking()
        }
        laserConfig.setVerticalAnimation()
    }


    func incrementMultiplier() {
        guard let laserConfig else { return }
        laserConfig.bpmMultiplier *= 2
        laserConfig.setMultiplier(multiplier: laserConfig.bpmMultiplier)
        laserConfig.restartBpmSyncTimer()
    }

    func decrementMultiplier() {
        guard let laserConfig else { return }
        laserConfig.bpmMultiplier = max(1 / 8, laserConfig.bpmMultiplier / 2)
        laserConfig.setMultiplier(multiplier: laserConfig.bpmMultiplier)
        laserConfig.restartBpmSyncTimer()
    }

    func multiplierText() -> String {
        guard let laserConfig else { return "1x" }
        if laserConfig.bpmMultiplier == 1.0 {
            return "1x"
        } else if laserConfig.bpmMultiplier < 1.0 {
            return "÷\(Int(1 / laserConfig.bpmMultiplier))"
        } else {
            return "x\(Int(laserConfig.bpmMultiplier))"
        }
    }
    
    func multiplierColor() -> Color {
        guard let laserConfig else { return .gray }
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
}
