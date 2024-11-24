//
//  Objects.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-24.
//

import Foundation

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

enum MovingHeadMode: String, Codable {
    case auto
    case manual
    case blackout
}

enum MovingHeadScene: String, Codable {
    case slow
    case medium
    case fast
    case off
}
