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
    
    func changeSHColor() {
        guard let laserConfig else { return }
        var nextColor: SpiderHeadColor? = laserConfig.spiderHead.color
        repeat {
            nextColor = SpiderHeadColor.allCases.randomElement()
        } while nextColor == laserConfig.spiderHead.color || nextColor == nil
        laserConfig.spiderHead.color = nextColor!
        laserConfig.changeColor(lights: [.spiderHead : laserConfig.spiderHead.color.colorValue])
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
}
