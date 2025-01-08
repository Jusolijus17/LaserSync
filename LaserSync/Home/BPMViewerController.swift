//
//  BPMViewerController.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-03.
//

import SwiftUI

class BPMViewerController: ObservableObject {
    private var laserConfig: LaserConfig?
    
    @Published var isRequestInProgress = false
    @Published var isBlinking = false
    @Published var networkErrorCount = 0
    @Published var showRetry = false
    
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
    
    func incrementMultiplier() {
        guard let laserConfig else { return }
        laserConfig.bpmMultiplier = min(16, laserConfig.bpmMultiplier * 2)
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
