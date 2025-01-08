//
//  CueMakerView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-26.
//

import SwiftUI

struct CueMakerView: View {
    @State var currentStep: CueMakerStep = .selectLights
    @State private var cue = Cue()
    
    var body: some View {
        VStack {
            switch currentStep {
            case .selectLights:
                SelectLightsView(
                    cue: $cue,
                    onNext: {
                        if cue.affectedLights.contains(.laser) {
                            currentStep = .laserSettings
                        } else if cue.affectedLights.contains(.movingHead) {
                            currentStep = .movingHeadSettings
                        } else if cue.affectedLights.contains(.spiderHead) {
                            currentStep = .spiderHeadSettings
                        } else {
                            currentStep = .summary
                        }
                    }
                )
            case .laserSettings:
                LaserCueSetup(
                    cue: $cue,
                    onNext: {
                        if cue.affectedLights.contains(.movingHead) {
                            currentStep = .movingHeadSettings
                        } else if cue.affectedLights.contains(.spiderHead) {
                            currentStep = .spiderHeadSettings
                        } else {
                            currentStep = .summary
                        }
                    }
                )
                .navigationTitle("Laser settings")
                .navigationBarTitleDisplayMode(.inline)
            case .movingHeadSettings:
                MovingHeadCueSetup(
                    cue: $cue,
                    onNext: {
                        if cue.affectedLights.contains(.spiderHead) {
                            currentStep = .spiderHeadSettings
                        } else {
                            currentStep = .summary
                        }
                    }
                )
                .navigationTitle("Moving Head settings")
                .navigationBarTitleDisplayMode(.inline)
            case .spiderHeadSettings:
                SpiderHeadCueSetup(cue: $cue) {
                    currentStep = .summary
                }
                .navigationTitle("Spider Head settings")
                .navigationBarTitleDisplayMode(.inline)
            case .summary:
                SummaryView(cue: $cue, onConfirm: {
                    cue.save()
                    currentStep = .selectLights
                }, onEditSection: { step in
                    navigateTo(step)
                })
                .navigationTitle("Summary")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationTitle("Cue Maker")
    }
    
    private func navigateTo(_ step: CueMakerStep) {
        currentStep = step
    }
}

struct SelectLightsView: View {
    @Binding var cue: Cue
    var onNext: () -> Void
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Select lights")
                .bold()
                .font(.title)
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    LightSelectionButton(
                        title: "Laser",
                        isSelected: cue.affectedLights.binding(for: .laser, in: $cue.affectedLights),
                        imageName: "laser_icon"
                    )
                    LightSelectionButton(
                        title: "Moving Head",
                        isSelected: cue.affectedLights.binding(for: .movingHead, in: $cue.affectedLights),
                        imageName: "moving_head_icon"
                    )
                }
                LightSelectionButton(title: "Spider Head", isSelected: cue.affectedLights.binding(for: .spiderHead, in: $cue.affectedLights), imageName: "spider_head_icon")
            }
            
            Spacer()
            
            NavigationLink(destination: CueSettingsView()) {
                Text("Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

// Bouton personnalisé pour sélectionner une lumière
struct LightSelectionButton: View {
    let title: String
    @Binding var isSelected: Bool
    let imageName: String
    
    var body: some View {
        VStack {
            Button(action: { isSelected.toggle() }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 150, height: 150)
                    .overlay {
                        VStack(spacing: 0) {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding()
                            
                            Divider()
                            
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isSelected ? .green : .gray.opacity(0.7))
                                .padding(10)
                        }
                    }
            }
        }
    }
}

#Preview {
    NavigationView {
        CueMakerView()
    }
}
