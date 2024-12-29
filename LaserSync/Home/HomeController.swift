//
//  HomeController.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-21.
//

import SwiftUI
import Foundation

class HomeController: ObservableObject {
    private var laserConfig: LaserConfig?
    
    @Published var isRequestInProgress = false
    @Published var isBlinking = false
    @Published var networkErrorCount = 0
    @Published var showRetry = false
    @Published var isHorizontalAnimationBlinking = false
    @Published var isVerticalAnimationBlinking = false
    @Published var horizontalBlinkTimer: Timer?
    @Published var verticalBlinkTimer: Timer?
    
    @Published var touchDownTime: Date?
    @Published var isPressed = false
    @Published var timer: Timer?
    
    private var blinkingTimer: DispatchSourceTimer?
    
    func setLaserConfig(_ laserConfig: LaserConfig) {
        self.laserConfig = laserConfig
    }
    
    func startBlinking() {
        guard let laserConfig else { return }
        
        // Arrête le Timer existant avant d'en créer un nouveau
        blinkingTimer?.cancel()
        blinkingTimer = nil
        
        let interval = 60.0 / Double(laserConfig.currentBpm) / 2
        
        // Crée un nouveau DispatchSourceTimer
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer.schedule(deadline: .now(), repeating: interval)
        
        // Définir le comportement du Timer
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isBlinking.toggle()
            }
        }
        
        // Démarre le Timer
        blinkingTimer = timer
        timer.activate()
    }
    
    func stopBlinking() {
        blinkingTimer?.cancel()
        blinkingTimer = nil
        DispatchQueue.main.async {
            self.isBlinking = false
        }
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
        var nextColor: LaserColor? = laserConfig.laser.color
        repeat {
            nextColor = LaserColor.allCases.randomElement()
        } while nextColor == laserConfig.laser.color || nextColor == nil
        laserConfig.laser.color = nextColor!
        laserConfig.changeColor(lights: [.laser: laserConfig.laser.color.colorValue])
    }
    
    func changeMHColor() {
        guard let laserConfig else { return }
        var nextColor: MovingHeadColor? = laserConfig.movingHead.color
        repeat {
            nextColor = MovingHeadColor.allCases.randomElement()
        } while nextColor == laserConfig.movingHead.color || nextColor == nil
        laserConfig.movingHead.color = nextColor!
        laserConfig.changeColor(lights: [.movingHead : laserConfig.movingHead.color.colorValue])
    }

    func changePattern() {
        guard let laserConfig else { return }
        var newPattern: LaserPattern
        repeat {
            newPattern = LaserPattern.allCases.randomElement()!
        } while newPattern == laserConfig.laser.pattern
        laserConfig.laser.pattern = newPattern
        laserConfig.setPattern()
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
        laserConfig.laser.horizontalAnimationEnabled.toggle()
        if laserConfig.laser.horizontalAnimationEnabled {
            startHorizontalBlinking()
        } else {
            stopHorizontalBlinking()
        }
        laserConfig.setHorizontalAnimation()
    }

    func toggleVerticalAnimation() {
        guard let laserConfig else { return }
        laserConfig.laser.verticalAnimationEnabled.toggle()
        if laserConfig.laser.verticalAnimationEnabled {
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
