//
//  Laser.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-28.
//

import SwiftUI

struct LaserState: Codable {
    var color: LaserColor = .multicolor
    var pattern: LaserPattern = .straight
    var mode: LightMode = .auto
    var bpmSyncModes: Set<BPMSyncMode> = []
    var includedPatterns: Set<LaserPattern> = Set(LaserPattern.allCases)
    var verticalAdjust: Double = 63
    var horizontalAnimationEnabled: Bool = false
    var horizontalAnimationSpeed: Double = 140
    var verticalAnimationEnabled: Bool = false
    var verticalAnimationSpeed: Double = 140
}

extension LaserState {
    mutating func merge(with other: LaserState, settings: Set<LightSettings>) {
        self.mode = other.mode
        for setting in settings {
            switch setting {
            case .pattern:
                self.pattern = other.pattern
                self.includedPatterns = other.includedPatterns
                updateBpmSyncModes(for: .pattern, from: other.bpmSyncModes)
            case .color:
                self.color = other.color
                updateBpmSyncModes(for: .color, from: other.bpmSyncModes)
            default:
                break
            }
        }
    }

    private mutating func updateBpmSyncModes(for mode: BPMSyncMode, from otherModes: Set<BPMSyncMode>) {
        if self.bpmSyncModes.contains(mode) && !otherModes.contains(mode) {
            self.bpmSyncModes.remove(mode)
        } else if !self.bpmSyncModes.contains(mode) && otherModes.contains(mode) {
            self.bpmSyncModes.insert(mode)
        }
    }
}
