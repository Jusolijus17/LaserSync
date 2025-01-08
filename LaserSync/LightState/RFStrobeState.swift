//
//  RFStrobeState.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-03.
//

import SwiftUI

struct RFStrobeState: Codable {
    var color: StrobeColor = .red
    var mode: LightMode = .blackout
}
