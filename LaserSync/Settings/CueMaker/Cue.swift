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

    // Laser
    var includeLaser: Bool = false
    var laserColor: LaserColor = .red
    var laserBPMSyncModes: [BPMSyncMode] = []
    var laserMode: LaserMode = .blackout
    var laserPattern: LaserPattern = .straight
    var laserIncludedPatterns: Set<LaserPattern> = Set(LaserPattern.allCases)

    // Moving Head
    var includeMovingHead: Bool = false
    var movingHeadMode: MovingHeadMode = .blackout
    var movingHeadColor: MovingHeadColor = .red
    var movingHeadColorFrequency: Double = 0
    var movingHeadStrobeFrequency: Double = 0
    var movingHeadScene: MovingHeadScene = .off
    var movingHeadBrightness: Double = 50
    var positionPreset: GyroPreset? = nil
}

extension Cue {
    func preview() -> Cue {
        let cue = Cue(includeLaser: true, laserMode: .auto, includeMovingHead: true, movingHeadMode: .auto)
        return cue
    }
    
    mutating func save() {
        let encoder = JSONEncoder()
        
        var savedCues: [Cue] = loadCues()
        
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
    
    func loadCues() -> [Cue] {
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
            Cue(color: .blue, name: "Laser Show", includeLaser: true, laserMode: .auto),
            Cue(name: "Moving Head Rotation", includeMovingHead: true, movingHeadMode: .auto),
            Cue(color: .orange, name: "Full Light Show", includeLaser: true, includeMovingHead: true),
            Cue(color: .yellow, name: "Spotlight", includeLaser: false, includeMovingHead: false)
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