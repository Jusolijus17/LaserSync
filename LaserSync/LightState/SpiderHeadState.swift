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
