//
//  PresetManagerView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-18.
//

import SwiftUI

struct PresetManagerView: View {
    @State private var presets: [GyroPreset] = GyroPreset.loadPresets()
    
    var body: some View {
        List {
            if presets.isEmpty {
                Text("No presets")
            } else {
                ForEach(presets) { preset in
                    VStack {
                        Text(preset.name)
                            .font(.headline)
                        Text("Pan: \(preset.pan), Tilt: \(preset.tilt)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                .onDelete(perform: deletePreset)
            }
        }
        .navigationTitle("Preset manager")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deletePreset(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        GyroPreset.savePresets(presets)
    }
}

#Preview {
    NavigationView {
        PresetManagerView()
    }
}
