//
//  MovingHeadState.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-28.
//

import SwiftUI

struct MovingHeadState: Codable {
    var color: MovingHeadColor = .red
    var gobo: Int = 0
    var mode: LightMode = .blackout
    var scene: LightScene = .off
    var brightness: Double = 0
    var strobeSpeed: Double = 0
    var colorSpeed: Double = 0
    var positionPreset: GyroPreset? = nil
}

extension MovingHeadState {
    mutating func merge(with other: MovingHeadState, settings: Set<LightSettings>) {
        self.mode = other.mode
        for setting in settings {
            switch setting {
            case .color:
                self.color = other.color
                self.colorSpeed = other.colorSpeed
                
            case .gobo:
                self.gobo = other.gobo

            case .scene:
                self.scene = other.scene

            case .position:
                self.positionPreset = other.positionPreset
                self.scene = .off

            case .strobeSpeed:
                self.strobeSpeed = other.strobeSpeed

            case .brightness:
                self.brightness = other.brightness

            default:
                break // Ignorer les réglages non pertinents au moving head
            }
        }
    }
}
