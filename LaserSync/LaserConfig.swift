//
//  LaserConfig.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-06.
//

import SwiftUI

class LaserConfig: ObservableObject {
    // Laser vars
    @Published var laserColor: Color = .clear
    @Published var currentLaserPattern: LaserPattern = .straight
    @Published var laserMode: LightMode = .auto
    @Published var currentBpm: Int = 0
    @Published var bpmMultiplier: Double = 1.0
    @Published var laserBPMSyncModes: Set<BPMSyncMode> = []
    @Published var laserIncludedPatterns: Set<LaserPattern> = Set(LaserPattern.allCases)
    @Published var verticalAdjust: Double = 63
    @Published var horizontalAnimationEnabled: Bool = false
    @Published var horizontalAnimationSpeed: Double = 127
    @Published var verticalAnimationEnabled: Bool = false
    @Published var verticalAnimationSpeed: Double = 127
    
    // Moving Head vars
    @Published var mHColor: Color = .red
    @Published var mHMode: LightMode = .blackout
    @Published var mhScene: MovingHeadScene = .off
    @Published var mHBrightness: Double = 0
    @Published var mHBreathe: Bool = false
    @Published var mHStrobe: Double = 0
    @Published var mHColorSpeed: Double = 0
    @Published var positionPreset: GyroPreset? = nil
    
    // Both
    @Published var bothColor: Color = .red
    @Published var includedLightsStrobe: Set<Light> = []
    private var previousState: Cue?
    
    // Connection settings
    @Published var serverIp: String
    @Published var serverPort: String
    @Published var olaIp: String
    @Published var olaPort: String
    
    // Other
    private var bpmSyncTimer: Timer?
    private var bpmUpdateTimer: Timer?
    private var isRequestInProgress: Bool = false
    @Published var networkErrorCount: Int = 0
    @Published var successfullBpmFetch: Bool = false
    
    // Computed vars
    var baseUrl: String {
        "http://\(serverIp):\(serverPort)"
    }
    
//    var currentLaserColor: Color {
//        return laserColors[currentLaserColorIndex].color
//    }
//    
//    var currentMHColor: Color {
//        return mHColors[currentMHColorIndex].color
//    }
//    
//    var currentLaserColorName: String {
//        return laserColors[currentLaserColorIndex].rawValue
//    }
//    
//    var currentMHColorName: String {
//        return mHColors[currentMHColorIndex].rawValue
//    }
    
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
        bpmUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if !self.isRequestInProgress {
                self.isRequestInProgress = true
                self.getCurrentBpm() { _, networkError in
                    self.isRequestInProgress = false
                    if networkError {
                        self.successfullBpmFetch = false
                        self.networkErrorCount += 1
                        if self.networkErrorCount >= 3 {
                            self.stopBpmUpdate()
                        }
                    } else {
                        self.successfullBpmFetch = true
                        self.networkErrorCount = 0
                    }
                }
            }
        }
    }
    
    func restartBpmUpdate() {
        self.networkErrorCount = 0
        self.currentBpm = 0
        self.startBpmUpdate()
    }

    func stopBpmUpdate() {
        bpmUpdateTimer?.invalidate()
        bpmUpdateTimer = nil
    }
    
    func getCurrentBpm(newBpm: @escaping (Bool, Bool) -> Void) {
        guard let url = URL(string: "\(self.baseUrl)/get_bpm") else {
            newBpm(false, true)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching BPM: \(error)")
                DispatchQueue.main.async {
                    newBpm(false, true) // Pass true to indicate a network error
                }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    newBpm(false, true) // Pass true to indicate a network error
                }
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received raw JSON: \(jsonString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Double],
                   let bpm = json["bpm"] {
                    DispatchQueue.main.async {
                        let roundedBpm = Int(bpm.rounded())
                        print("Received BPM from server: \(bpm), rounded to \(roundedBpm)")
                        if self.currentBpm != roundedBpm {
                            self.currentBpm = roundedBpm
                            print("Updated current BPM: \(self.currentBpm)")
                            newBpm(true, false) // Pass false to indicate no network error
                        } else {
                            newBpm(false, false) // Pass false to indicate no network error
                        }
                    }
                } else {
                    print("Failed to parse JSON or no BPM value found")
                    DispatchQueue.main.async {
                        newBpm(false, true) // Pass true to indicate a network error
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
                DispatchQueue.main.async {
                    newBpm(false, true) // Pass true to indicate a network error
                }
            }
        }.resume()
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
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("JSON to send: \(jsonString)")
//            }
        } catch {
            print("Failed to encode Cue: \(error)")
            return
        }
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func stopCue() {
        guard let previousState else { return }
        guard let url = URL(string: "\(self.baseUrl)/set_cue") else { return }
        self.applyCue(self.previousState)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(previousState)
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
        let laserColor = LaserColor.from(color: self.laserColor) ?? .multicolor
        let mHColor = MovingHeadColor.from(color: self.mHColor) ?? .red
        let affectedSettings: Set<LightSettings> = Set(LightSettings.allCases)
        self.previousState = Cue(id: UUID(), color: .red, name: "Previous", type: .definitive, includeLaser: true, laserSettings: affectedSettings, laserColor: laserColor, laserBPMSyncModes: self.laserBPMSyncModes, laserMode: self.laserMode, laserPattern: self.currentLaserPattern, laserIncludedPatterns: [], includeMovingHead: true, movingHeadSettings: affectedSettings, movingHeadMode: self.mHMode, movingHeadColor: mHColor, movingHeadColorFrequency: self.mHColorSpeed, movingHeadStrobeFrequency: self.mHStrobe, movingHeadScene: self.mhScene, movingHeadBrightness: self.mHBrightness)
    }
    
    private func applyCue(_ cue: Cue?) {
        guard let cue else { return }
        if cue.includeLaser {
            self.currentLaserPattern = cue.laserPattern
            self.laserMode = cue.laserMode
            self.laserColor = cue.laserColor.color
            self.laserBPMSyncModes = cue.laserBPMSyncModes
            if !self.laserBPMSyncModes.isEmpty {
                self.startBpmSyncTimer()
            } else {
                self.stopBpmSyncTimer()
            }
            self.laserIncludedPatterns = cue.laserIncludedPatterns
        }
        if cue.includeMovingHead {
            self.mHMode = cue.movingHeadMode
            self.mHColor = cue.movingHeadColor.color
            self.mHColorSpeed = cue.movingHeadColorFrequency
            self.mHStrobe = cue.movingHeadStrobeFrequency
            self.mhScene = cue.movingHeadScene
            self.mHBrightness = cue.movingHeadBrightness
            self.positionPreset = cue.positionPreset
        }
    }

    
    // MARK: - Color control
    
    func changeColor(light: Light, color: Color) {
        guard let url = URL(string: "\(self.baseUrl)/set_color_for/\(light.rawValue)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        switch light {
        case .laser:
            self.laserColor = color
        case .movingHead:
            self.mHColorSpeed = 0
            self.mHColor = color
        case .both:
            self.mHColorSpeed = 0
            self.laserColor = color
            self.mHColor = color
        default: break
        }
        
        var body = ["color": color.name]
        if light == .laser && color == .clear {
            body = ["color": "multicolor"]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setMHColorSpeed() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_color_speed") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["speed": Int(self.mHColorSpeed)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Pattern control
    
    func setPattern() {
        guard let url = URL(string: "\(self.baseUrl)/set_pattern") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["pattern": self.currentLaserPattern.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func togglePatternInclusion(pattern: LaserPattern) {
        if laserIncludedPatterns.contains(pattern) {
            laserIncludedPatterns.remove(pattern)
        } else {
            laserIncludedPatterns.insert(pattern)
        }
        setPatternInclude()
    }

    func setPatternInclude() {
        guard let url = URL(string: "\(self.baseUrl)/set_pattern_include") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let patternsArray = laserIncludedPatterns.map { $0.rawValue }
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
            mHMode = custom
        } else {
            if mHMode == .manual {
                mHMode = .sound
            } else {
                mHMode = .manual
            }
        }
        setModeFor(.movingHead)
    }
    
    func toggleMHScene(_ custom: MovingHeadScene? = nil) {
        if let custom {
            self.mhScene = custom
        } else {
            switch mhScene {
            case .slow:
                mhScene = .medium
            case .medium:
                mhScene = .fast
            case .fast:
                mhScene = .off
            case .off:
                mhScene = .slow
            }
        }
        setMHScene()
    }
    
    func setModeFor(_ light: Light) {
        guard let url = URL(string: "\(self.baseUrl)/set_mode_for/\(light)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var mode: String = ""
        if light == .laser {
            mode = self.laserMode.rawValue
        } else if light == .movingHead {
            mode = self.mHMode.rawValue
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
        let body: [String: String] = ["scene": self.mhScene.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setMHStrobe() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.mHStrobe)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - MH Brightness control
    
    func setMHBrightness() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_brightness") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.mHBrightness)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func toggleMhBreathe() {
        self.mHBreathe.toggle()
        guard let url = URL(string: "\(self.baseUrl)/set_mh_breathe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Bool] = ["breathe": self.mHBreathe]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Advanced options
    
    func resetVerticalAdjust() {
        self.verticalAdjust = 63
        setVerticalAdjust()
    }
    
    func setVerticalAdjust() {
        guard let url = URL(string: "\(self.baseUrl)/set_vertical_adjust") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["adjust": self.verticalAdjust]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setHorizontalAnimation() {
        guard let url = URL(string: "\(self.baseUrl)/set_horizontal_animation") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["enabled": self.horizontalAnimationEnabled, "speed": self.horizontalAnimationSpeed] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setVerticalAnimation() {
        guard let url = URL(string: "\(self.baseUrl)/set_vertical_animation") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["enabled": self.verticalAnimationEnabled, "speed": self.verticalAnimationSpeed] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
        
        if !self.verticalAnimationEnabled {
            // Set back vertical adjust to pre-animation setting
            self.setVerticalAdjust()
        }
    }
    
    // MARK: - BPM sync
    
    func toggleBpmSync(mode: BPMSyncMode) {
        if laserBPMSyncModes.contains(mode) {
            laserBPMSyncModes.remove(mode)
            if laserBPMSyncModes.isEmpty {
                stopBpmSyncTimer()
            }
        } else {
            laserBPMSyncModes.insert(mode)
            startBpmSyncTimer()
        }
        setSyncMode()
    }
    
    private func startBpmSyncTimer() {
        stopBpmSyncTimer()
        
        // Convertir le Set en un tableau ordonné
        
        bpmSyncTimer = Timer.scheduledTimer(withTimeInterval: (60.0 / Double(currentBpm)) * bpmMultiplier, repeats: true) { _ in
            let orderedLaserPatterns = Array(self.laserIncludedPatterns)
            if self.laserBPMSyncModes.contains(.pattern) {
                // Incrémenter l'index et réinitialiser lorsqu'on atteint la fin
                self.bpmSyncLaserPatternIndex = (self.bpmSyncLaserPatternIndex + 1) % orderedLaserPatterns.count
                self.currentLaserPattern = orderedLaserPatterns[self.bpmSyncLaserPatternIndex]
            }
            if self.laserBPMSyncModes.contains(.color) {
                // Incrémenter l'index des couleurs et réinitialiser lorsqu'on atteint la fin
                self.bpmSyncLaserColorIndex = (self.bpmSyncLaserColorIndex + 1) % self.laserColors.count
                self.laserColor = self.laserColors[self.bpmSyncLaserColorIndex].color
            }
        }
    }
    
    func restartBpmSyncTimer() {
        stopBpmSyncTimer()
        if !laserBPMSyncModes.isEmpty {
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
        let syncModes = laserBPMSyncModes.map { $0.rawValue }.joined(separator: ",")
        guard let url = URL(string: "\(self.baseUrl)/set_sync_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["sync_modes": syncModes]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
}
