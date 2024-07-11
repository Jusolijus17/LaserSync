//
//  Extensions.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-10.
//

import Foundation
import SwiftUI

extension View {
    func multicolor(isEnabled: Bool = true) -> some View {
        Group {
            if isEnabled {
                self.overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                ).mask(self)
            } else {
                self
            }
        }
    }
}
