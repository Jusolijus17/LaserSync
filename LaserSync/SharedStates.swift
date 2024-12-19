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
    
    func redirectToCueMaker() {
        self.activeTab = 4
        self.showCueMaker = true
    }
}
