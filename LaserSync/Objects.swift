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
    case spiderHead
    case all
    case none
    
    var id: String { rawValue }
    
    static var displayableCases: [Light] {
        return [.laser, .movingHead]
    }
}

enum CueMakerStep {
    case selectLights
    case laserSettings
    case movingHeadSettings
    case summary
}

enum CueType: String, Codable, CaseIterable, Identifiable {
    case definitive
    case temporary
    
    var id: String { return self.rawValue }
}

enum LightScene: String, Codable, CaseIterable, Identifiable {
    case slow
    case medium
    case fast
    case off
    
    var id: String { return self.rawValue }
}

protocol LightColors: Codable, Identifiable, CaseIterable {
    var id: String { get }
    var colorValue: Color { get }
}

enum SpiderHeadColor: String, LightColors {
    case multicolor
    case red
    case blue
    case green
    case white
    
    var id: String { return self.rawValue }
}

extension SpiderHeadColor {
    var colorValue: Color {
        switch self {
        case .multicolor: return .clear
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .white: return .white
        }
    }
    
    static func from(color: Color) -> SpiderHeadColor {
        return SpiderHeadColor.allCases.first(where: { $0.colorValue == color }) ?? .red
    }
}

enum MovingHeadColor: String, LightColors {
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
    var colorValue: Color {
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
    
    static func from(color: Color) -> MovingHeadColor {
        return MovingHeadColor.allCases.first(where: { $0.colorValue == color }) ?? .red
    }
}

enum BPMSyncMode: String, Codable {
    case color
    case pattern
}

enum LightMode: String, Codable, CaseIterable, Identifiable {
    case manual
    case auto
    case sound
    case blackout
    
    var id: String { return self.rawValue }
}

enum LaserColor: String, LightColors {
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
    var colorValue: Color {
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
    
    static func from(color: Color) -> LaserColor {
        return LaserColor.allCases.first(where: { $0.colorValue == color }) ?? .multicolor
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
    var name: String
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
    
    static func addPreset(_ preset: GyroPreset) throws {
        var currentPresets = loadPresets()
        
        // Vérification du nom
        if currentPresets.contains(where: { $0.name == preset.name }) {
            throw NSError(domain: "", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "A preset with the same name already exists. Please choose a different name."
            ])
        }
        
        // Ajout et sauvegarde
        currentPresets.append(preset)
        savePresets(currentPresets)
    }
}


