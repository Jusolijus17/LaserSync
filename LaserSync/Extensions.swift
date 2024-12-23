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

extension CGSize {
    func limited(to radius: CGFloat) -> CGSize {
        let distance = hypot(width, height)
        if distance > radius {
            let angle = atan2(height, width)
            return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
        } else {
            return self
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color: Codable {
    private enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to extract color components."))
        }
        try container.encode(components[0], forKey: .red) // Rouge
        try container.encode(components[1], forKey: .green) // Vert
        try container.encode(components[2], forKey: .blue) // Bleu
        try container.encode(uiColor.cgColor.alpha, forKey: .opacity) // Opacité
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(CGFloat.self, forKey: .red)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        let opacity = try container.decode(CGFloat.self, forKey: .opacity)
        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension Color {
    var name: String? {
        switch self {
        case Color.red: return "red"
        case Color.blue: return "blue"
        case Color.green: return "green"
        case Color.pink: return "pink"
        case Color.cyan: return "cyan"
        case Color.yellow: return "yellow"
        case Color.orange: return "orange"
        case Color.white: return "white"
        default: return nil
        }
    }
}
