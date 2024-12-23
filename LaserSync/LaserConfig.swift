//
//  LaserConfig.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-06.
//

import SwiftUI

class LaserConfig: ObservableObject {
    // Laser vars
    //@Published var currentLaserColorIndex: Int = 0 // to dispatch
    @Published var laserColor: Color = .clear
    @Published var currentLaserPattern: LaserPattern = .straight
    @Published var laserMode: LaserMode = .auto
    @Published var currentBpm: Int = 0
    @Published var bpmMultiplier: Double = 1.0
    @Published var strobeModeEnabled: Bool = false
    @Published var laserBPMSyncModes: [BPMSyncMode] = []
    @Published var laserIncludedPatterns: Set<LaserPattern> = Set(LaserPattern.allCases)
    @Published var verticalAdjust: Double = 63
    @Published var horizontalAnimationEnabled: Bool = false
    @Published var horizontalAnimationSpeed: Double = 127
    @Published var verticalAnimationEnabled: Bool = false
    @Published var verticalAnimationSpeed: Double = 127
    
    // Moving Head vars
    //@Published var currentMHColorIndex: Int = 0 // to disptach
    @Published var mHColor: Color = .red
    @Published var mHMode: MovingHeadMode = .blackout
    @Published var mhScene: MovingHeadScene = .off
    @Published var mHBrightness: Double = 0
    @Published var mHStrobe: Double = 0
    @Published var mHColorSpeed: Double = 0
    @Published var positionPreset: GyroPreset? = nil
    
    // Both
    @Published var lightControlColor = Set<Light>()
    @Published var bothColor: Color = .red
    private var previousState: Cue?
    
    // Connection settings
    @Published var serverIp: String
    @Published var serverPort: String
    @Published var olaIp: String
    @Published var olaPort: String
    
    // Other
    private var bpmSyncTimer: Timer?
    private var bpmUpdateTimer: Timer?
    private var pauseRequests: Bool = false
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
        self.previousState = Cue(id: UUID(), color: .red, name: "Previous", type: .definitive, includeLaser: true, laserColor: laserColor, laserBPMSyncModes: self.laserBPMSyncModes, laserMode: self.laserMode, laserPattern: self.currentLaserPattern, laserIncludedPatterns: [], includeMovingHead: true, movingHeadMode: self.mHMode, movingHeadColor: mHColor, movingHeadColorFrequency: self.mHColorSpeed, movingHeadStrobeFrequency: self.mHStrobe, movingHeadScene: self.mhScene, movingHeadBrightness: self.mHBrightness, positionPreset: nil)
    }
    
    private func applyCue(_ cue: Cue?) {
        guard let cue else { return }
        self.pauseRequests = true
        if cue.includeLaser {
            self.currentLaserPattern = cue.laserPattern
            self.laserMode = cue.laserMode
            self.laserColor = cue.laserColor.color
            self.laserBPMSyncModes = cue.laserBPMSyncModes
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
        self.pauseRequests = false
    }
    
    // MARK: - Lights settings
    
    private func setIncludedLightsForColor() {
        guard let url = URL(string: "\(self.baseUrl)/set_lights_include_color") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Set<Light>] = ["lights": self.lightControlColor]
        print("Body to send : \(body)" )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("Failed to encode body: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request).resume()
    }

    
    // MARK: - Color control
    
//    func setColor(color: String? = nil) {
//        guard let url = URL(string: "\(self.baseUrl)/set_color") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        var colorToSend = color
//        if getChangeColorTarget() == .laser && color == nil {
//            colorToSend = self.currentLaserColorName
//        } else if getChangeColorTarget() == .movingHead && color == nil {
//            colorToSend = self.currentMHColorName
//        } else if getChangeColorTarget() == .both && color == nil {
//            colorToSend = self.currentLaserColorName
//        } else if getChangeColorTarget() == .none {
//            return
//        }
//        
//        let body = ["color": colorToSend]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//
//        URLSession.shared.dataTask(with: request).resume()
//    }
    
    func changeColor(light: Light, color: Color) {
        guard let url = URL(string: "\(self.baseUrl)/set_color_for/\(light.rawValue)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.pauseRequests = true
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
        self.pauseRequests = false
        
        var body = ["color": color.name]
        if light == .laser && color == .clear {
            body = ["color": "multicolor"]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func getChangeColorTarget() -> Light {
        if lightControlColor.count == 1 && lightControlColor.contains(.laser) {
            return .laser
        } else if lightControlColor.count == 1 && lightControlColor.contains(.movingHead) {
            return .movingHead
        } else if lightControlColor.count == 2 {
            return .both
        }
        return .none
    }
    
    func setMHColorSpeed() {
        guard !pauseRequests else { return }
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
        let patternList = laserPatterns.map { ["name": $0.rawValue, "include": laserIncludedPatterns.contains($0)] }
        guard let url = URL(string: "\(self.baseUrl)/set_pattern_include") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["patterns": patternList]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Mode control
    
    func toggleMHMode(_ custom: MovingHeadMode? = nil) {
        if let custom {
            mHMode = custom
        } else {
            if mHMode == .auto {
                mHMode = .manual
            } else {
                mHMode = .auto
            }
        }
        setMHMode()
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
    
    func setMode() {
        guard let url = URL(string: "\(self.baseUrl)/set_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["mode": self.laserMode.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func toggleStrobeMode() {
        self.strobeModeEnabled.toggle()
        setStrobeMode()
    }
    
    func setStrobeMode() {
        guard let url = URL(string: "\(self.baseUrl)/set_strobe_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["enabled": self.strobeModeEnabled]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    private func setMHMode() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["mode": self.mHMode.rawValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
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
    
    func sendSingleStrobe() {
        guard let url = URL(string: "\(self.baseUrl)/send_single_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func startMHStrobe() {
        guard let url = URL(string: "\(self.baseUrl)/start_mh_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func stopMHStrobe() {
        guard let url = URL(string: "\(self.baseUrl)/stop_mh_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func setMHStrobe() {
        guard !pauseRequests else { return }
        guard let url = URL(string: "\(self.baseUrl)/set_mh_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.mHStrobe)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Brightness control
    func setMHBrightness() {
        guard !pauseRequests else { return }
        guard let url = URL(string: "\(self.baseUrl)/set_mh_brightness") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.mHBrightness)]
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
            laserBPMSyncModes.removeAll { $0 == mode }
            if laserBPMSyncModes.isEmpty {
                stopBpmSyncTimer()
            }
        } else {
            laserBPMSyncModes.append(mode)
            startBpmSyncTimer()
        }
        setSyncMode()
    }
    
    private func startBpmSyncTimer() {
        stopBpmSyncTimer()
        bpmSyncTimer = Timer.scheduledTimer(withTimeInterval: (60.0 / Double(currentBpm)) * bpmMultiplier, repeats: true) { _ in
            if self.laserBPMSyncModes.contains(.pattern) {
                self.currentLaserPattern = LaserPattern.allCases.randomElement()!
            }
            if self.laserBPMSyncModes.contains(.color) {
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
