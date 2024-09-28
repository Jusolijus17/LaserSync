//
//  LaserConfig.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-06.
//

import SwiftUI

class LaserConfig: ObservableObject {
    @Published var currentLaserColorIndex: Int = 0
    @Published var currentMHColorIndex: Int = 0
    @Published var currentPatternIndex: Int = 0
    @Published var currentMode: String = "auto"
    @Published var currentBpm: Int = 0
    @Published var bpmMultiplier: Double = 1.0
    @Published var strobeModeEnabled: Bool = false
    @Published var activeSyncTypes = Set<String>()
    @Published var includedPatterns: Set<String> = ["pattern1", "pattern2", "pattern3", "pattern4"]
    @Published var verticalAdjust: Double = 63
    @Published var horizontalAnimationEnabled: Bool = false
    @Published var horizontalAnimationSpeed: Double = 127
    @Published var verticalAnimationEnabled: Bool = false
    @Published var verticalAnimationSpeed: Double = 127
    @Published var lightControlColor = Set<Light>()
    @Published var mHMode: MovingHeadMode = .blackout
    @Published var mhScene: MovingHeadScene = .off
    @Published var mHDimmer: Double = 0
    @Published var mHStrobe: Double = 0
    @Published var mHColorSpeed: Double = 0
    
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
    
    // Computed vars
    var baseUrl: String {
        "http://\(serverIp):\(serverPort)"
    }
    
    var currentLaserColor: Color {
        return laserColors[currentLaserColorIndex].color
    }
    
    var currentMHColor: Color {
        return mHColors[currentMHColorIndex].color
    }
    
    var currentLaserColorName: String {
        return laserColors[currentLaserColorIndex].name
    }
    
    var currentMHColorName: String {
        return mHColors[currentMHColorIndex].name
    }
    
    var currentPattern: Pattern {
        return patterns[currentPatternIndex]
    }
    
    var patterns: [Pattern] = [
        Pattern(name: "pattern1", shape: AnyView(StraightLineShape())),
        Pattern(name: "pattern2", shape: AnyView(DashedLineShape())),
        Pattern(name: "pattern3", shape: AnyView(DottedLineShape())),
        Pattern(name: "pattern4", shape: AnyView(WaveLineShape()))
    ]
    
    var laserColors: [(name: String, color: Color)] = [
        ("multicolor", .clear),
        ("red", .red),
        ("blue", .blue),
        ("green", .green),
        ("pink", .pink),
        ("cyan", .cyan),
        ("yellow", .yellow)
    ]
    
    var mHColors: [(name: String, color: Color)] = [
        ("auto", .clear),
        ("red", .red),
        ("blue", .blue),
        ("green", .green),
        ("pink", .pink),
        ("cyan", .cyan),
        ("yellow", .yellow),
        ("orange", .orange),
        ("white", .white)
    ]
    
    var modes = ["auto", "manual", "sound", "blackout"]
    
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
                self.getCurrentBpm() { newBpm, networkError in
                    self.isRequestInProgress = false
                    if networkError {
                        self.networkErrorCount += 1
                        if self.networkErrorCount >= 3 {
                            self.stopBpmUpdate()
                        }
                    } else {
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
    
    // MARK: - Lights settings
    
    // Used to set which lights will change color using the color board
    func toggleIncludedLightsForColor(light: Light) {
        if lightControlColor.contains(light) {
            lightControlColor.remove(light)
        } else {
            lightControlColor.insert(light)
        }
        if lightControlColor.count == 2 {
            self.currentMHColorIndex = 1
            self.currentLaserColorIndex = 1
        }
        setIncludedLightsForColor()
    }
    
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
    
    func setColor(color: String? = nil) {
        guard let url = URL(string: "\(self.baseUrl)/set_color") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var colorToSend = color
        if getChangeColorTarget() == .laser && color == nil {
            colorToSend = self.currentLaserColorName
        } else if getChangeColorTarget() == .movingHead && color == nil {
            colorToSend = self.currentMHColorName
        } else if getChangeColorTarget() == .both && color == nil {
            colorToSend = self.currentLaserColorName
        } else if getChangeColorTarget() == .none {
            return
        }
        
        let body = ["color": colorToSend]
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
        let body = ["pattern": self.currentPattern.name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func togglePatternInclusion(name: String) {
        if includedPatterns.contains(name) {
            includedPatterns.remove(name)
        } else {
            includedPatterns.insert(name)
        }
        setPatternInclude()
    }

    func setPatternInclude() {
        let patternList = patterns.map { ["name": $0.name, "include": includedPatterns.contains($0.name)] }
        guard let url = URL(string: "\(self.baseUrl)/set_pattern_include") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["patterns": patternList]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Mode control
    
    func toggleMHMode() {
        if mHMode == .auto {
            mHMode = .manual
        } else {
            mHMode = .auto
        }
        setMHMode()
    }
    
    func toggleMHScene() {
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
        setMHScene()
    }
    
    func setMode() {
        guard let url = URL(string: "\(self.baseUrl)/set_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["mode": self.currentMode]
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
        guard let url = URL(string: "\(self.baseUrl)/set_mh_strobe") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.mHStrobe)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // MARK: - Brightness control
    func setMHDimmer() {
        guard let url = URL(string: "\(self.baseUrl)/set_mh_dimmer") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["value": Int(self.mHDimmer)]
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
    
    func toggleBpmSync(type: String) {
        if activeSyncTypes.contains(type) {
            activeSyncTypes.remove(type)
            if activeSyncTypes.isEmpty {
                stopBpmSyncTimer()
            }
        } else {
            activeSyncTypes.insert(type)
            startBpmSyncTimer()
        }
        setSyncMode()
    }
    
    private func startBpmSyncTimer() {
        stopBpmSyncTimer()
        bpmSyncTimer = Timer.scheduledTimer(withTimeInterval: (60.0 / Double(currentBpm)) * bpmMultiplier, repeats: true) { _ in
            if self.activeSyncTypes.contains("pattern") {
                let activePatterns = self.patterns.enumerated().filter { self.includedPatterns.contains($0.element.name) }
                if !activePatterns.isEmpty {
                    let currentActiveIndex = activePatterns.firstIndex(where: { $0.offset == self.currentPatternIndex }) ?? 0
                    let nextActiveIndex = (currentActiveIndex + 1) % activePatterns.count
                    self.currentPatternIndex = activePatterns[nextActiveIndex].offset
                }
            }
            if self.activeSyncTypes.contains("color") {
                self.currentLaserColorIndex = (self.currentLaserColorIndex + 1) % self.laserColors.count
            }
        }
    }
    
    func restartBpmSyncTimer() {
        stopBpmSyncTimer()
        if !activeSyncTypes.isEmpty {
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
        let syncModes = Array(activeSyncTypes).joined(separator: ",")
        guard let url = URL(string: "\(self.baseUrl)/set_sync_mode") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["sync_modes": syncModes]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request).resume()
    }
}
