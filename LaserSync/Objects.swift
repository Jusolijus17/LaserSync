//
//  Objects.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-24.
//

import Foundation

enum Light: String, Codable {
    case laser
    case movingHead
    case both
    case none
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
