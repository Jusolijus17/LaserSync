//
//  Room3DView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-25.
//

import SwiftUI
import SceneKit

struct Room3DView: View {
    @EnvironmentObject var roomModel: RoomModel

    var body: some View {
        SceneView(
            scene: createScene(),
            pointOfView: nil,
            options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
        .edgesIgnoringSafeArea(.all)
    }

    private func createScene() -> SCNScene {
        let scene = SCNScene()

        // Cube représentant la pièce
        let room = SCNBox(
            width: CGFloat(roomModel.roomWidth),
            height: 10.0,
            length: CGFloat(roomModel.roomDepth),
            chamferRadius: 0
        )
        room.firstMaterial?.diffuse.contents = UIColor.lightGray
        let roomNode = SCNNode(geometry: room)
        roomNode.position = SCNVector3(roomModel.roomWidth / 2, 5.0, roomModel.roomDepth / 2)
        scene.rootNode.addChildNode(roomNode)

        // Lumière
        let light = SCNSphere(radius: 0.1)
        light.firstMaterial?.diffuse.contents = UIColor.blue
        let lightNode = SCNNode(geometry: light)
        lightNode.position = roomModel.lightPosition
        scene.rootNode.addChildNode(lightNode)

        // Flèche pointant vers la cible
        if roomModel.targetPosition != SCNVector3(0, 0, 0) {
            let arrow = SCNCylinder(radius: 0.05, height: 5.0)
            arrow.firstMaterial?.diffuse.contents = UIColor.red
            let arrowNode = SCNNode(geometry: arrow)
            arrowNode.position = SCNVector3(roomModel.lightPosition.x,
                                            roomModel.lightPosition.y,
                                            roomModel.lightPosition.z)
            scene.rootNode.addChildNode(arrowNode)
        }

        return scene
    }
}

extension SCNVector3 {
    static func != (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
    }
}

#Preview {
    Room3DView()
}
