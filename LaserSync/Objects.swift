//
//  Objects.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-24.
//

import Foundation
import SwiftUI

enum Light: String, Codable, CaseIterable, Identifiable {
    case laser
    case movingHead
    case both
    case none
    
    var id: String { rawValue }
    
    static var displayableCases: [Light] {
        return [.laser, .movingHead]
    }
    
    var rawValue: String {
        switch self {
        case .laser: return "Laser"
        case .movingHead: return "Moving Head"
        case .both: return "Both"
        case .none: return "None"
        }
    }
}

enum MovingHeadMode: String, Codable, CaseIterable, Identifiable {
    case auto
    case manual
    case blackout
    
    var id: String { return self.rawValue }
}

enum MovingHeadScene: String, Codable, CaseIterable, Identifiable {
    case slow
    case medium
    case fast
    case off
    
    var id: String { return self.rawValue }
}

enum MovingHeadColor: String, CaseIterable, Identifiable {
    case auto
    case red
    case blue
    case green
    case pink
    case cyan
    case yellow
    case orange
    case white
    
    var id: String { return self.rawValue }
    
    var color: Color {
        switch self {
        case .auto:
            return .clear
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .pink:
            return .pink
        case .cyan:
            return .cyan
        case .yellow:
            return .yellow
        case .orange:
            return .orange
        case .white:
            return .white
        }
    }
}

enum BPMSyncModes {
    case color
    case pattern
}

enum LaserMode: String, Codable, CaseIterable, Identifiable {
    case manual
    case auto
    case sound
    case blackout
    
    var id: String { return self.rawValue }
}

enum LaserColor: String, CaseIterable, Identifiable {
    case multicolor
    case red
    case blue
    case green
    case pink
    case cyan
    case yellow
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .multicolor: return .clear
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .pink: return .pink
        case .cyan: return .cyan
        case .yellow: return .yellow
        }
    }
}

enum LaserPattern: String, CaseIterable, Identifiable {
    case straight
    case dashed
    case dotted
    case wave
    
    var id: String { rawValue }
    
    var shape: AnyView {
        switch self {
        case .straight:
            return AnyView(StraightLineShape())
        case .dashed:
            return AnyView(DashedLineShape())
        case .dotted:
            return AnyView(DottedLineShape())
        case .wave:
            return AnyView(WaveLineShape())
        }
    }
}
