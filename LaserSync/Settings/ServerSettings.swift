//
//  ServerSettings.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-16.
//

import SwiftUI

struct ServerSettings: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @State private var isServerSettingsSaved: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: connectionHeader) {
                        connectionFields
                    }
                }
                
                saveButton
            }
        }
        .navigationTitle("Server Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Header de la section Connection
    private var connectionHeader: some View {
        HStack {
            Text("Connection")
                .font(.headline)
            Spacer()
            if !isServerSettingsSaved {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
            }
        }
    }

    // Champs pour les adresses IP et les ports
    private var connectionFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Server:")
                Spacer()
                TextField("IP Address", text: $laserConfig.serverIp)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                    .onChange(of: laserConfig.serverIp) { _ in
                        isServerSettingsSaved = false
                    }
                    .frame(width: 150)
                Text(":")
                TextField("Port", text: $laserConfig.serverPort)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                    .onChange(of: laserConfig.serverPort) { _ in
                        isServerSettingsSaved = false
                    }
                    .frame(width: 70)
            }
            
            Divider()

            HStack {
                Text("OLA:")
                Spacer()
                TextField("IP Address", text: $laserConfig.olaIp)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                    .onChange(of: laserConfig.olaIp) { _ in
                        isServerSettingsSaved = false
                    }
                    .frame(width: 150)
                Text(":")
                TextField("Port", text: $laserConfig.olaPort)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
                    .onChange(of: laserConfig.olaPort) { _ in
                        isServerSettingsSaved = false
                    }
                    .frame(width: 70)
            }
        }
    }

    // Bouton de sauvegarde
    private var saveButton: some View {
        Button(action: saveServerSettings) {
            Text("Save")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(saveButtonDisabled() ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
        }
        .disabled(saveButtonDisabled())
    }

    // Validation des champs pour activer/désactiver le bouton
    private func saveButtonDisabled() -> Bool {
        return laserConfig.olaIp.isEmpty || laserConfig.olaPort.isEmpty || laserConfig.serverIp.isEmpty || laserConfig.serverPort.isEmpty
    }

    // Action pour sauvegarder les paramètres
    private func saveServerSettings() {
        laserConfig.saveConnectionSettings()
        isServerSettingsSaved = true
    }
}

#Preview {
    ServerSettings()
        .environmentObject(LaserConfig())
}
