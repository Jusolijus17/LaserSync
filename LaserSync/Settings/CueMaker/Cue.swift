//
//  Cue.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-17.
//

import SwiftUI

struct Cue: Identifiable, Codable {
    var id = UUID()
    var color: Color = .red
    var name: String = ""
    var type: CueType = .definitive
    var affectedLights: Set<Light> = []

    // Laser
    var laser = LaserState()
    var laserSettings: Set<LightSettings> = []

    // Moving Head
    var movingHead = MovingHeadState()
    var movingHeadSettings: Set<LightSettings> = []
    
    // All
    var includedLightStrobe: Set<Light> = []
}

enum LightSettings: String, Codable, CaseIterable {
    // All
    case color
    case strobe
    
    // Moving Head
    case scene
    case position
    case strobeSpeed
    case brightness
    
    // Laser
    case pattern
    case vAdjust
    case hAnimation
    case vAnimation
}

extension Cue {
    static func preview() -> Cue {
        let cue = Cue(name: "Test", affectedLights: [.laser, .movingHead], laser: LaserState(mode: .auto), movingHead: MovingHeadState(mode: .auto))
        return cue
    }
    
    mutating func save() {
        let encoder = JSONEncoder()
        
        var savedCues: [Cue] = Cue.loadCues()
        
        savedCues.append(self)
        
        do {
            let data = try encoder.encode(savedCues)
            UserDefaults.standard.set(data, forKey: "savedCues")
            self = Cue()
            print("Cue saved successfully!")
        } catch {
            print("Failed to save cue: \(error)")
        }
    }
    
    static func loadCues() -> [Cue] {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: "savedCues") {
            do {
                let cues = try decoder.decode([Cue].self, from: data)
                return cues
            } catch {
                print("Failed to load cues: \(error)")
            }
        }
        return []
    }
    
    static func savePreviewCues() {
        let previewCues = [
            Cue(name: "Test", affectedLights: [.laser], laser: LaserState(mode: .auto)),
            Cue(color: .blue, name: "Laser Show", affectedLights: [.laser], laser: LaserState(mode: .auto)),
            Cue(color: .pink, name: "Moving Head Rotation", affectedLights: [.movingHead], movingHead: MovingHeadState(mode: .manual)),
            Cue(color: .orange, name: "Full Light Show", affectedLights: [.laser, .movingHead], laser: LaserState(mode: .sound), movingHead: MovingHeadState(mode: .sound))
        ]
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(previewCues)
            UserDefaults.standard.set(data, forKey: "savedCues")
            print("Preview cues saved successfully!")
        } catch {
            print("Failed to save preview cues: \(error)")
        }
    }
}
