//
//  LaserConfig.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-06.
//

import SwiftUI

class LaserConfig: ObservableObject {
    @Published var laser = LaserState()
    @Published var movingHead = MovingHeadState()
    
    // Both
    @Published var bothColor: Color = .red
    @Published var includedLightsStrobe: Set<Light> = []
    private var previousLaserState: LaserState?
    private var previousMovingHeadState: MovingHeadState?
    
    // Connection settings
    @Published var serverIp: String
    @Published var serverPort: String
    @Published var olaIp: String
    @Published var olaPort: String
    
    // Other
    @Published var currentBpm: Int = 0
    @Published var bpmMultiplier: Double = 1.0
    private var bpmSyncTimer: Timer?
    private var bpmUpdateTimer: Timer?
    private var isRequestInProgress: Bool = false
    private var bpmUpdateTask: Task<Void, Never>?
    @Published var networkErrorCount: Int = 0
    @Published var successfullBpmFetch: Bool = false
    
    // Computed vars
    var baseUrl: String {
        "http://\(serverIp):\(serverPort)"
    }
    
    var bpmSyncLaserColorIndex: Int = 0
    var bpmSyncLaserPatternIndex: Int = 0
    
    var laserColors: [LaserColor] = LaserColor.allCases
    var laserPatterns: [LaserPattern] = LaserPattern.allCases
    
    var mHColors: [MovingHeadColor] = MovingHeadColor.allCases
    
    init() {
        self.serverIp = UserDefaults.standard.string(forKey: "serverIp") ?? ""
        self.serverPort = UserDefaults.standard.string(forKey: "serverPort") ?? "8080"
        self.olaIp = UserDefaults.standard.string(forKey: "olaIp") ?? ""
        self.olaPort = UserDefaults.standard.string(forKey: "olaPort") ?? "9090"
        
        self.startBpmUpdate()
    }
    
    // MARK: - Connection settings
    
    func saveConnectionSettings() {
        UserDefaults.standard.set(serverIp, forKey: "serverIp")
        UserDefaults.standard.set(serverPort, forKey: "serverPort")
        UserDefaults.standard.set(olaIp, forKey: "olaIp")
        UserDefaults.standard.set(olaPort, forKey: "olaPort")
        updateSocketConfiguration()
        self.setOlaAddress()
    }
    
    private func setOlaAddress() {
        guard let url = URL(string: "\(self.baseUrl)/set_ola_ip") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["ip": olaIp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
        
        guard let urlPort = URL(string: "\(self.baseUrl)/set_ola_port") else { return }
        var requestPort = URLRequest(url: urlPort)
        requestPort.httpMethod = "POST"
        requestPort.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyPort = ["port": olaPort]
        requestPort.httpBody = try? JSONSerialization.data(withJSONObject: bodyPort, options: [])
        
        URLSession.shared.dataTask(with: requestPort).resume()
    }
    
    // MARK: - Home
    
    func startBpmUpdate() {
        bpmUpdateTask?.cancel() // Annule toute tâche existante
        bpmUpdateTask = Task {
            await updateBpmContinuously()
        }
    }
    
    func stopBpmUpdate() {
        bpmUpdateTask?.cancel()
        bpmUpdateTask = nil
    }
    
    func restartBpmUpdate() {
        stopBpmUpdate()
        networkErrorCount = 0
        currentBpm = 0
        startBpmUpdate()
    }

    private func updateBpmContinuously() async {
        while !Task.isCancelled {
            do {
                // Appeler le réseau en arrière-plan
                let bpm = try await fetchCurrentBpm()

                // Mettre à jour l'interface utilisateur sur le thread principal
                await MainActor.run {
                    if self.currentBpm != bpm {
                        self.currentBpm = bpm
                        self.successfullBpmFetch = true
                    }
                    if self.networkErrorCount != 0 {
                        self.networkErrorCount = 0
                    }
                }
            } catch {
                // Gérer les erreurs sur le thread principal
                await MainActor.run {
                    self.networkErrorCount += 1
                    self.successfullBpmFetch = false
                    if self.networkErrorCount >= 3 {
                        self.stopBpmUpdate()
                    }
                }
            }

            // Attendre 5 secondes avant de refaire une requête
            try? await Task.sleep(nanoseconds: 5_000_000_000)
        }
    }
    
    private func fetchCurrentBpm() async throws -> Int {
        guard let url = URL(string: "\(baseUrl)/get_bpm") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Vérifier la réponse HTTP
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Décoder le JSON pour extraire le BPM
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Double],
            let bpm = json["bpm"]
        else {
            throw URLError(.cannotParseResponse)
        }
        
        return Int(bpm.rounded())
    }
    
    // MARK: - CUE settings
    
    func setCue(_ cue: Cue) {
        if cue.type == .temporary {
            self.savePreviousState()
        } else {
            self.applyCue(cue)
        }
        guard let url = URL(string: "\(self.baseUrl)/set_cue") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(cue)
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON to send: \(jsonString)")
            }
        } catch {
            print("Failed to encode Cue: \(error)")
            return
        }
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func stopCue() {
        guard let url = URL(string: "\(self.baseUrl)/set_cue") else { return }
        self.restorePreviousState()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Restore Cue
        let allSettings = Set(LightSettings.allCases)
        let previousStateCue = Cue(name: "Restore Cue", affectedLights: [.laser, .movingHead], laser: self.laser, laserSettings: allSettings, movingHead: self.movingHead, movingHeadSettings: allSettings)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(previousStateCue)
            request.httpBody = jsonData
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("JSON to send: \(jsonString)")
//            }
        } catch {
            print("Failed to encode Cue: \(error)")
            return
        }
        URLSession.shared.dataTask(with: request).resume()
    }
    
    private func savePreviousState() {
        self.previousLaserState = self.laser
        self.previousMovingHeadState = self.movingHead
    }
    
    private func restorePreviousState() {
        self.laser = self.previousLaserState ?? LaserState()
        self.movingHead = self.previousMovingHeadState ?? MovingHeadState()
    }
    
    private func applyCue(_ cue: Cue?) {
        guard let cue else { return }

        // Appliquer les réglages pour le laser
        if cue.affectedLights.contains(.laser) {
            self.laser.merge(with: cue.laser, settings: cue.laserSettings)
            if cue.laserSettings.contains(.pattern) || cue.laserSettings.contains(.color) {
                if !self.laser.bpmSyncModes.isEmpty {
                    self.startBpmSyncTimer()
                } else {
                    self.stopBpmSyncTimer()
                }
            }
        }
        
        print("Laser mode now : ", self.laser.mode)

        // Appliquer les réglages pour le moving head
        if cue.affectedLights.contains(.movingHead) {
            self.movingHead.merge(with: cue.movingHead, settings: cue.movingHeadSettings)
        }
        
        print("Moving head mode now : ", self.movingHead.mode)
    }

    
    // MARK: - Color control
    
    func changeColor(lights: [Light: Color]) {
        guard let url = URL(string: "\(self.baseUrl)/set_color") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Mise à jour locale des couleurs
        for (light, color) in lights {
            switch light {
            case .laser:
                self.laser.color = LaserColor.from(color: color)
            case .movingHead:
                self.movingHead.colorSpeed = 0
                self.movingHead.color = MovingHeadColor.from(color: color)
            case .both:
                self.movingHead.colorSpeed = 0
                self.laser.color = LaserColor.from(color: color)
                self.movingHead.color = MovingHeadColor.from(color: color)
            default:
                break
            }
        }
        
        // Construction du corps de la requête
        let body: [[String: String]] = lights.map { light, color in
            let colorName = (light == .laser && color == .clear) ? "multicolor" : color.name ?? "unknown"
            return [
                "light": light.rawValue,
                "color": colorName
            ]
        }
        
        // Ajout du JSON dans le corps de la requête
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Envoi de la requête
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setMHColorSpeed() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_color_speed") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["speed": Int(self.movingHead.colorSpeed)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Pattern control
    
    func setPattern() {
        guard let url = URL(string: "\(self.baseUrl)/set_pattern") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["pattern": self.laser.pattern.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func togglePatternInclusion(pattern: LaserPattern) {
        if laser.includedPatterns.contains(pattern) {
            self.laser.includedPatterns.remove(pattern)
        } else {
            self.laser.includedPatterns.insert(pattern)
        }
        setPatternInclude()
    }

    func setPatternInclude() {
        guard let url = URL(string: "\(self.baseUrl)/set_pattern_include") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let patternsArray = self.laser.includedPatterns.map { $0.rawValue }
        let body: [String: Any] = ["patterns": patternsArray]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Erreur lors de la sérialisation JSON : \(error)")
            return
        }
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Mode control
    
    func toggleMHMode(_ custom: LightMode? = nil) {
        if let custom {
            self.movingHead.mode = custom
        } else {
            if self.movingHead.mode == .manual {
                self.movingHead.mode = .sound
            } else {
                self.movingHead.mode = .manual
            }
        }
        setModeFor(.movingHead)
    }
    
    func toggleMHScene(_ custom: MovingHeadScene? = nil) {
        if let custom {
            self.movingHead.scene = custom
        } else {
            switch self.movingHead.scene {
            case .slow:
                self.movingHead.scene = .medium
            case .medium:
                self.movingHead.scene = .fast
            case .fast:
                self.movingHead.scene = .off
            case .off:
                self.movingHead.scene = .slow
            }
        }
        setMHScene()
    }
    
    func turnOffMovingHead() {
        self.movingHead.mode = .blackout
        self.movingHead.scene = .off
        if self.movingHead.breathe {
            self.toggleMhBreathe()
        }
        self.movingHead.brightness = 0
        
        self.setModeFor(.movingHead)
        self.setMHScene()
        self.setMHBrightness()
    }
    
    func setModeFor(_ light: Light) {
        guard let url = URL(string: "\(self.baseUrl)/set_mode_for/\(light)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var mode: String = ""
        if light == .laser {
            mode = self.laser.mode.rawValue
        } else if light == .movingHead {
            mode = self.movingHead.mode.rawValue
        } else {
            return
        }
        let body = ["mode": mode]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setStrobeMode() {
        for light in Light.allCases {
            guard let url = URL(string: "\(self.baseUrl)/set_strobe_mode_for/\(light)") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["enabled": self.includedLightsStrobe.contains(light)]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            URLSession.shared.dataTask(with: request).resume()
        }
    }
    
    private func setMHScene() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_scene") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["scene": self.movingHead.scene.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setMHStrobe() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.movingHead.strobeSpeed)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - MH Brightness control
    
    func setMHBrightness() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_brightness") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.movingHead.brightness)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func toggleMhBreathe() {
        self.movingHead.breathe.toggle()
        guard let url = URL(string: "\(self.baseUrl)/set_mh_breathe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Bool] = ["breathe": self.movingHead.breathe]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Advanced options
    
    func resetVerticalAdjust() {
        self.laser.verticalAdjust = 63
        setVerticalAdjust()
    }
    
    func setVerticalAdjust() {
        guard let url = URL(string: "\(self.baseUrl)/set_vertical_adjust") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["adjust": self.laser.verticalAdjust]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setHorizontalAnimation() {
        guard let url = URL(string: "\(self.baseUrl)/set_horizontal_animation") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["enabled": self.laser.horizontalAnimationEnabled, "speed": self.laser.horizontalAnimationSpeed] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setVerticalAnimation() {
        guard let url = URL(string: "\(self.baseUrl)/set_vertical_animation") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["enabled": self.laser.verticalAnimationEnabled, "speed": self.laser.verticalAnimationSpeed] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
        
        if !self.laser.verticalAnimationEnabled {
            // Set back vertical adjust to pre-animation setting
            self.setVerticalAdjust()
        }
    }
    
    // MARK: - BPM sync
    
    func toggleBpmSync(mode: BPMSyncMode) {
        if laser.bpmSyncModes.contains(mode) {
            laser.bpmSyncModes.remove(mode)
            if laser.bpmSyncModes.isEmpty {
                stopBpmSyncTimer()
            }
        } else {
            laser.bpmSyncModes.insert(mode)
            startBpmSyncTimer()
        }
        setSyncMode()
    }
    
    private func startBpmSyncTimer() {
        stopBpmSyncTimer()
        
        // Convertir le Set en un tableau ordonné
        
        bpmSyncTimer = Timer.scheduledTimer(withTimeInterval: (60.0 / Double(currentBpm)) * bpmMultiplier, repeats: true) { _ in
            let orderedLaserPatterns = Array(self.laser.includedPatterns)
            if self.laser.bpmSyncModes.contains(.pattern) && !orderedLaserPatterns.isEmpty {
                // Incrémenter l'index et réinitialiser lorsqu'on atteint la fin
                self.bpmSyncLaserPatternIndex = (self.bpmSyncLaserPatternIndex + 1) % orderedLaserPatterns.count
                self.laser.pattern = orderedLaserPatterns[self.bpmSyncLaserPatternIndex]
            }
            if self.laser.bpmSyncModes.contains(.color) && !self.laserColors.isEmpty {
                // Incrémenter l'index des couleurs et réinitialiser lorsqu'on atteint la fin
                self.bpmSyncLaserColorIndex = (self.bpmSyncLaserColorIndex + 1) % self.laserColors.count
                self.laser.color = self.laserColors[self.bpmSyncLaserColorIndex]
            }
        }
    }
    
    func restartBpmSyncTimer() {
        stopBpmSyncTimer()
        if !self.laser.bpmSyncModes.isEmpty {
            startBpmSyncTimer()
        }
    }

    private func stopBpmSyncTimer() {
        bpmSyncTimer?.invalidate()
        bpmSyncTimer = nil
    }
    
    func setMultiplier(multiplier: Double) {
        guard let url = URL(string: "\(self.baseUrl)/set_bpm_multiplier") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["multiplier": multiplier]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setSyncMode() {
        let syncModes = self.laser.bpmSyncModes.map { $0.rawValue }.joined(separator: ",")
        guard let url = URL(string: "\(self.baseUrl)/set_sync_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["sync_modes": syncModes]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
}
