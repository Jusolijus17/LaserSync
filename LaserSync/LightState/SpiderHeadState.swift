//
//  SpiderHeadState.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-29.
//

import SwiftUI

struct SpiderHeadState: Codable {
    var color: SpiderHeadColor = .multicolor
    var ledSelection: [LEDCell]
    var mode: LightMode = .auto
    var scene: LightScene = .off
    var strobeSpeed: Double = 0
    var lightChaseSpeed: Double = 0
    var brightness: Double = 0
    var bpmSyncModes: Set<BPMSyncMode> = []
    var position: ShPositionPreset?
    
    init() {
        self.ledSelection = [
            LEDCell(id: 0, color: .red, side: "right",   isOn: false),
            LEDCell(id: 1, color: .green, side: "right", isOn: false),
            LEDCell(id: 2, color: .blue, side: "right",  isOn: false),
            LEDCell(id: 3, color: .white, side: "right", isOn: false),
            
            LEDCell(id: 4, color: .red, side: "left",   isOn: false),
            LEDCell(id: 5, color: .green, side: "left", isOn: false),
            LEDCell(id: 6, color: .blue, side: "left",  isOn: false),
            LEDCell(id: 7, color: .white, side: "left", isOn: false)
        ]
    }
}

extension SpiderHeadState {
    mutating func merge(with other: SpiderHeadState, settings: Set<LightSettings>) {
        self.mode = other.mode
        for setting in settings {
            switch setting {
            case .color:
                self.color = other.color
                self.ledSelection = other.ledSelection
                
            case .scene:
                self.scene = other.scene
                
            case .strobeSpeed:
                self.strobeSpeed = other.strobeSpeed
                
            case .chaseSpeed:
                self.lightChaseSpeed = other.lightChaseSpeed
                
            case .brightness:
                self.brightness = other.brightness
                
            default:
                break // Ignorer les réglages non pertinents au spider head
            }
        }
    }
}


struct ShPositionPreset: Codable, Identifiable {
    var id: UUID
    var name: String
    let leftAngle: Double
    let rightAngle: Double
}

extension ShPositionPreset {
    static let presetsKey = "headPositions"
    
    static func savePresets(_ presets: [ShPositionPreset]) {
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: presetsKey)
        } catch {
            print("Erreur lors de l'enregistrement des presets : \(error)")
        }
    }
    
    static func loadPresets() -> [ShPositionPreset] {
        guard let data = UserDefaults.standard.data(forKey: presetsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([ShPositionPreset].self, from: data)
        } catch {
            print("Erreur lors du chargement des presets : \(error)")
            return []
        }
    }
    
    static func addPreset(_ preset: ShPositionPreset) throws {
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
