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
        case name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let colorName = self.name {
            try container.encode(colorName, forKey: .name)
        } else {
            try container.encode("unknown", forKey: .name)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorName = try container.decode(String.self, forKey: .name)

        switch colorName {
        case "red": self = .red
        case "blue": self = .blue
        case "green": self = .green
        case "pink": self = .pink
        case "cyan": self = .cyan
        case "yellow": self = .yellow
        case "orange": self = .orange
        case "white": self = .white
        case "purple": self = .purple
        case "gray": self = .gray
        case "multicolor": self = .clear
        default: self = .clear // Valeur par défaut pour les couleurs inconnues
        }
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
        case Color.purple: return "purple"
        case Color.gray: return "gray"
        case Color.clear: return "multicolor"
        default: return nil
        }
    }
}

struct DisabledStyle: ViewModifier {
    let isDisabled: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isDisabled) // Désactive la vue
            .opacity(isDisabled ? 0.5 : 1.0) // Change l'opacité pour donner un effet visuel
    }
}

extension View {
    func disabledStyle(_ isDisabled: Bool) -> some View {
        self.modifier(DisabledStyle(isDisabled: isDisabled))
    }
}

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

extension Set where Element == Light {
    func binding(for light: Light, in bindingSet: Binding<Set<Light>>) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                bindingSet.wrappedValue.contains(light)
            },
            set: { isSelected in
                if isSelected {
                    bindingSet.wrappedValue.insert(light)
                } else {
                    bindingSet.wrappedValue.remove(light)
                }
            }
        )
    }
}

extension LaserConfig {
    func mode(for light: Light) -> LightMode? {
        switch light {
        case .laser:
            return laser.mode
        case .movingHead:
            return movingHead.mode
        case .spiderHead:
            return spiderHead.mode // Assurez-vous que cette propriété existe
        default:
            return nil
        }
    }
}
