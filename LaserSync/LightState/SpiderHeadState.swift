//
//  SpiderHeadState.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-29.
//

import SwiftUI

struct SpiderHeadState: Codable {
    var color: SpiderHeadColor = .multicolor
    var ledSelection: [LEDCell]?
    var mode: LightMode = .auto
    var scene: LightScene = .off
    var strobeSpeed: Double = 0
    var lightChaseSpeed: Double = 0
    var brightness: Double = 0
}

struct ShPosition: Codable, Identifiable {
    var id: UUID
    var name: String
    let leftAngle: Double
    let rightAngle: Double
}

extension ShPosition {
    static let presetsKey = "headPositions"
    
    static func savePresets(_ presets: [ShPosition]) {
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: presetsKey)
        } catch {
            print("Erreur lors de l'enregistrement des presets : \(error)")
        }
    }
    
    static func loadPresets() -> [ShPosition] {
        guard let data = UserDefaults.standard.data(forKey: presetsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([ShPosition].self, from: data)
        } catch {
            print("Erreur lors du chargement des presets : \(error)")
            return []
        }
    }
    
    static func addPreset(_ preset: ShPosition) throws {
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
