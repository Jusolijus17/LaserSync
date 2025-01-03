//
//  PrecisionControlView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-18.
//

import SwiftUI

struct ShPrecisionControlView: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @State private var leftOffset: CGFloat = 0
    @State private var rightOffset: CGFloat = 0
    
    @State private var showingAlert: Bool = false
    @State private var newPresetName = ""
    @State private var reset = false
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        GeometryReader { _ in
            VStack {
                Spacer()
                
                HStack(spacing: 50) {
                    VerticalJoystickView(angle: $leftOffset, reset: $reset, width: 50, height: 300)
                    VerticalJoystickView(angle: $rightOffset, reset: $reset, width: 50, height: 300)
                }
                
                Text("Left: \(Int(leftOffset))")
                Text("Right: \(Int(rightOffset))")
                
                Spacer()
                
                // Bouton pour réinitialiser la position
                Button {
                    resetPosition()
                } label: {
                    Text("Reset position")
                }
                
                // Save preset
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Save Preset")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .onChange(of: leftOffset) {
                laserConfig.sendShPositionData(leftAngle: Double(leftOffset), rightAngle: Double(rightOffset))
            }
            .onChange(of: rightOffset) {
                laserConfig.sendShPositionData(leftAngle: Double(leftOffset), rightAngle: Double(rightOffset))
            }
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
            .navigationBarTitle("Precision control")
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func savePreset() {
        guard !newPresetName.isEmpty else { return }

        let newPreset = ShPosition(
            id: UUID(),
            name: newPresetName,
            leftAngle: Double(leftOffset),
            rightAngle: Double(rightOffset)
        )

        do {
            try ShPosition.addPreset(newPreset)
            newPresetName = ""
        } catch {
            errorMessage = error.localizedDescription
            showingErrorAlert = true
        }
    }
    
    private func resetPosition() {
        reset = true
        leftOffset = 0
        rightOffset = 0
        laserConfig.sendShPositionData(leftAngle: 0, rightAngle: 0)
    }
}

#Preview {
    NavigationView {
        ShPrecisionControlView()
            .environmentObject(LaserConfig())
    }
}
