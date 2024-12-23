//
//  SettingToggle.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-23.
//
import SwiftUI

struct SettingToggle: View {
    @Binding var settings: Set<LightSettings> // Utilisation d'un Set
    let setting: LightSettings // Le paramètre spécifique pour ce toggle
    let label: String // Le label du toggle

    var body: some View {
        Toggle(isOn: Binding(
            get: {
                settings.contains(setting) // Vérifie si le paramètre est dans le Set
            },
            set: { isOn in
                if isOn {
                    settings.insert(setting) // Ajoute au Set
                } else {
                    settings.remove(setting) // Retire du Set
                }
            }
        )) {
            Text(label)
                .font(.title2)
        }
        .toggleStyle(SwitchToggleStyle())
        .padding(.bottom)
    }
}
