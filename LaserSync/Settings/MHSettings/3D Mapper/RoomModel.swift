//
//  RoomModel.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-25.
//

import Foundation
import SceneKit

class RoomModel: ObservableObject {
    @Published var roomWidth: Float = 5.0 // Dimension X
    @Published var roomDepth: Float = 5.0 // Dimension Z
    @Published var roomHeight: Float = 3.0 // Dimension Y (nouveau)
    @Published var lightPosition: SCNVector3 = SCNVector3(0, 0, 0) // Position de la lumière
    @Published var targetPosition: SCNVector3 = SCNVector3(0, 0, 0) // Position ciblée
    @Published var currentView: String = "Top"
}
