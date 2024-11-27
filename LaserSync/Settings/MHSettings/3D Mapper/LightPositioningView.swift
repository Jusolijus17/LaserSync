//
//  LightPositioningView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-25.
//

import SceneKit
import SwiftUI

struct LightPositioningView: View {
    @EnvironmentObject var roomModel: RoomModel

    var body: some View {
        VStack {
            Picker("Vue", selection: $roomModel.currentView) {
                Text("Vue de haut").tag("Top")
                Text("Vue de côté").tag("Side")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            SceneView(
                scene: createScene(),
                pointOfView: setupCamera(),
                options: [.allowsCameraControl]
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Positionner la lumière")
    }

    /// Crée une scène avec un cube quadrillé
    private func createScene() -> SCNScene {
        let scene = SCNScene()

        // Cube représentant la pièce
        let roomGeometry = SCNBox(
            width: CGFloat(roomModel.roomWidth),
            height: CGFloat(roomModel.roomHeight),
            length: CGFloat(roomModel.roomDepth),
            chamferRadius: 0
        )
        roomGeometry.firstMaterial?.diffuse.contents = createGridTexture()
        roomGeometry.firstMaterial?.isDoubleSided = true

        let roomNode = SCNNode(geometry: roomGeometry)
        roomNode.position = SCNVector3(
            roomModel.roomWidth / 2,
            roomModel.roomHeight / 2,
            roomModel.roomDepth / 2
        )

        scene.rootNode.addChildNode(roomNode)

        // Ajout des arêtes du cube
        let edgesGeometry = SCNBox(
            width: CGFloat(roomModel.roomWidth),
            height: CGFloat(roomModel.roomHeight),
            length: CGFloat(roomModel.roomDepth),
            chamferRadius: 0
        )
        edgesGeometry.firstMaterial?.diffuse.contents = UIColor.clear // Pas de remplissage
        edgesGeometry.firstMaterial?.isDoubleSided = true
        edgesGeometry.firstMaterial?.fillMode = .lines // Mode wireframe pour les arêtes

        let edgesNode = SCNNode(geometry: edgesGeometry)
        edgesNode.position = SCNVector3(
            roomModel.roomWidth / 2,
            roomModel.roomHeight / 2,
            roomModel.roomDepth / 2
        )
        scene.rootNode.addChildNode(edgesNode)

        // Lumière représentée par un point rouge
        let lightGeometry = SCNSphere(radius: 0.1)
        lightGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let lightNode = SCNNode(geometry: lightGeometry)
        lightNode.name = "light"
        lightNode.position = roomModel.lightPosition

        scene.rootNode.addChildNode(lightNode)

        return scene
    }

    /// Configure la caméra
    private func setupCamera() -> SCNNode {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        cameraNode.camera = camera

        // Position de la caméra selon la vue actuelle
        if roomModel.currentView == "Top" {
            cameraNode.position = SCNVector3(roomModel.roomWidth / 2, roomModel.roomHeight * 4.5, roomModel.roomDepth / 2)
            cameraNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0) // Vue de haut
        } else { // Vue de côté
            cameraNode.position = SCNVector3(roomModel.roomWidth / 2, roomModel.roomHeight / 2, roomModel.roomDepth * 3)
            cameraNode.eulerAngles = SCNVector3(0, 0, 0) // Vue de côté
        }

        return cameraNode
    }

    /// Crée une texture quadrillée
    private func createGridTexture() -> UIImage {
        let size = 512
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)

        // Dessiner la grille
        let step = size / 10
        for i in 0...10 {
            let position = CGFloat(i * step)
            context.move(to: CGPoint(x: position, y: 0))
            context.addLine(to: CGPoint(x: position, y: CGFloat(size)))
            context.move(to: CGPoint(x: 0, y: position))
            context.addLine(to: CGPoint(x: CGFloat(size), y: position))
        }
        context.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

#Preview {
    LightPositioningView()
        .environmentObject(RoomModel())
}
