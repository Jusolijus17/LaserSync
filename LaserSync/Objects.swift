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

enum MovingHeadColor: String, Codable, CaseIterable, Identifiable {
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
}

extension MovingHeadColor {
    var color: Color {
        switch self {
        case .auto: return .clear
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .pink: return .pink
        case .cyan: return .cyan
        case .yellow: return .yellow
        case .orange: return .orange
        case .white: return .white
        }
    }
}

enum BPMSyncModes: String, Codable {
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

enum LaserColor: String, Codable, CaseIterable, Identifiable {
    case multicolor
    case red
    case blue
    case green
    case pink
    case cyan
    case yellow
    
    var id: String { rawValue }
}

extension LaserColor {
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

enum LaserPattern: String, Codable, CaseIterable, Identifiable {
    case straight
    case dashed
    case dotted
    case wave
    
    var id: String { rawValue }
}

extension LaserPattern {
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

struct GyroPreset: Identifiable, Codable {
    let id: UUID
    let name: String
    let pan: Double
    let tilt: Double
}

extension GyroPreset {
    static let presetsKey = "gyroPresets"
    
    static func savePresets(_ presets: [GyroPreset]) {
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: presetsKey)
        } catch {
            print("Erreur lors de l'enregistrement des presets : \(error)")
        }
    }
    
    static func loadPresets() -> [GyroPreset] {
        guard let data = UserDefaults.standard.data(forKey: presetsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([GyroPreset].self, from: data)
        } catch {
            print("Erreur lors du chargement des presets : \(error)")
            return []
        }
    }
}
