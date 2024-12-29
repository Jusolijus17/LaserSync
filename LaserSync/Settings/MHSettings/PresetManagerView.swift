//
//  PresetManagerView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-18.
//

import SwiftUI

struct PresetManagerView: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var presets: [GyroPreset] = []
    @State private var showingAlert = false
    @State private var newPresetName = ""
    @State private var presetToRename: GyroPreset?

    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        List {
            if presets.isEmpty {
                Text("No presets")
            } else {
                ForEach($presets) { $preset in
                    Button {
                        laserConfig.sendGyroData(pan: preset.pan, tilt: preset.tilt)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("Pan: \(Int(preset.pan))°, Tilt: \(Int(preset.tilt))°")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = presets.firstIndex(where: { $0.id == preset.id }) {
                                deletePreset(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button("Rename") {
                            presetToRename = preset
                            newPresetName = preset.name
                            showingAlert = true
                        }
                        .tint(.blue)
                    }
                }
                .onDelete(perform: deletePreset)
            }
        }
        .navigationTitle("Preset manager")
        .navigationBarTitleDisplayMode(.inline)
        .alert("New Preset", isPresented: $showingAlert) {
            TextField("Preset Name", text: $newPresetName)
            Button("Save", action: savePreset)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a name for the new preset.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            presets = GyroPreset.loadPresets()
        }
    }

    private func deletePreset(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        GyroPreset.savePresets(presets)
    }

    private func savePreset() {
        guard let presetToRename = presetToRename else { return }

        // Vérification de la duplicité du nom
        let nameAlreadyExists = presets.contains { $0.name == newPresetName && $0.id != presetToRename.id }

        if nameAlreadyExists {
            errorMessage = "A preset with the same name already exists. Please choose a different name."
            showingErrorAlert = true
        } else {
            if let index = presets.firstIndex(where: { $0.id == presetToRename.id }) {
                presets[index].name = newPresetName
                GyroPreset.savePresets(presets)
            }
        }
    }
}

#Preview {
    NavigationView {
        PresetManagerView()
            .environmentObject(LaserConfig())
            .onAppear {
                GyroPreset.savePresets([GyroPreset(id: UUID(), name: "Test", pan: 1.5, tilt: 2.2)])
            }
    }
}
