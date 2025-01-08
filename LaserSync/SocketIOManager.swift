//
//  SocketIOManager.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-16.
//

import Foundation
import SocketIO

class SocketIOManager {
    static let shared = SocketIOManager() // Singleton pour accès global

    private var manager: SocketManager?
    private var socket: SocketIOClient?

    private init() {
        // Initialisation vide : les connexions se feront dynamiquement
    }

    func configureSocket(serverIp: String, serverPort: String) {
        // Déconnecter le socket précédent s'il est déjà connecté
        socket?.disconnect()

        // Créer une nouvelle instance de SocketManager avec les nouvelles configurations
        guard let url = URL(string: "http://\(serverIp):\(serverPort)") else {
            print("Invalid server address: \(serverIp):\(serverPort)")
            return
        }

        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager?.defaultSocket

        configureSocketEvents()

        // Se connecter au serveur
        socket?.connect()
    }

    private func configureSocketEvents() {
        socket?.on(clientEvent: .connect) { _, _ in
            print("SocketIO Connected")
        }

        socket?.on(clientEvent: .error) { data, _ in
            print("SocketIO Error: \(data)")
        }
    }

    func sendGyroData(pan: Double, tilt: Double) {
        guard let socket = socket else {
            print("Socket is not configured")
            return
        }
        socket.emit("gyro_data", ["pan": pan, "tilt": tilt])
    }
    
    func sendShPositionData(leftAngle: Double, rightAngle: Double) {
        guard let socket = socket else {
            print("Socket is not configured")
            return
        }
        socket.emit("sh_position_data", ["leftAngle": leftAngle, "rightAngle": rightAngle])
    }
}

extension LaserConfig {
    func updateSocketConfiguration() {
        SocketIOManager.shared.configureSocket(serverIp: serverIp, serverPort: serverPort)
    }

    func sendGyroData(pan: Double, tilt: Double) {
        SocketIOManager.shared.sendGyroData(pan: pan, tilt: tilt)
    }
    
    func sendShPositionData(leftAngle: Double, rightAngle: Double) {
        SocketIOManager.shared.sendShPositionData(leftAngle: leftAngle, rightAngle: rightAngle)
    }
}
