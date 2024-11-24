//
//  MotionManager.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-23.
//

import CoreMotion
import Foundation

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var pan: Double = 0 // Rotation accumulée gauche-droite (yaw)
    @Published var tilt: Double = 0 // Inclinaison avant-arrière (pitch)
    
    private var lastYaw: Double? = nil
    private var referencePitch: Double? = nil
    
    let panLimit: Double = 360
    let tiltLimit: Double = 90

    // Callback pour envoyer les données
    var onMotionDataUpdate: ((Double, Double) -> Void)?

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        print("Starting motion updates")
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            let attitude = data.attitude
            
            if self.lastYaw == nil || self.referencePitch == nil {
                self.lastYaw = attitude.yaw * 180 / .pi
                self.referencePitch = attitude.pitch * 180 / .pi
            }
            
            let currentYaw = attitude.yaw * 180 / .pi
            let currentPitch = attitude.pitch * 180 / .pi
            
            var deltaYaw = currentYaw - self.lastYaw!
            
            if deltaYaw > 180 {
                deltaYaw -= 360
            } else if deltaYaw < -180 {
                deltaYaw += 360
            }
            
            self.pan += deltaYaw
            self.pan = max(-self.panLimit, min(self.panLimit, self.pan))
            self.tilt = max(-self.tiltLimit, min(self.tiltLimit, currentPitch - self.referencePitch!))
            
            self.lastYaw = currentYaw
            
            // Appeler le callback pour transmettre les données
            self.onMotionDataUpdate?(self.pan, self.tilt)
        }
    }
    
    func stopMotionUpdates() {
        print("Stopping motion updates")
        motionManager.stopDeviceMotionUpdates()
        lastYaw = nil
        referencePitch = nil
        pan = 0
        tilt = 0
    }
}
