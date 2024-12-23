//
//  SharedStates.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-17.
//

import Foundation

class SharedStates: ObservableObject {
    @Published var activeTab: Int = 0
    @Published var showCueMaker: Bool = false
    @Published var showCueLabels: Bool = false
    
    private let showCueLabelsKey = "showCueLabelsPreference"

    init() {
        self.showCueLabels = UserDefaults.standard.bool(forKey: showCueLabelsKey)
    }

    func redirectToCueMaker() {
        self.activeTab = 4
        self.showCueMaker = true
    }

    func setShowCueLabels(_ value: Bool) {
        self.showCueLabels = value
        UserDefaults.standard.set(value, forKey: showCueLabelsKey)
    }
}
