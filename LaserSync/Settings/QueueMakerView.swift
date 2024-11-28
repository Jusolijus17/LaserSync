//
//  QueueMakerView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-26.
//

import SwiftUI

struct QueueMakerView: View {
    @State private var currentStep: Step = .selectLights
    @State private var includeLaser: Bool = false
    @State private var includeMovingHead: Bool = false
    @State private var laserColor: String = "Red"
    @State private var laserMode: String = ""
    @State private var laserPattern: String = ""
    @State private var movingHeadColor: String = "Blue"
    @State private var strobeFrequency: Double = 1.0
    
    @State private var queue = Queue()
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case .selectLights:
                    SelectLightsView(
                        includeLaser: $includeLaser,
                        includeMovingHead: $includeMovingHead,
                        onNext: { currentStep = includeLaser ? .laserSettings : (includeMovingHead ? .movingHeadSettings : .summary) }
                    )
                case .laserSettings:
                    LaserSettingsView(
                        queue: $queue,
                        onNext: { currentStep = includeMovingHead ? .movingHeadSettings : .summary }
                    )
                case .movingHeadSettings:
                    MovingHeadSettingsView(
                        selectedColor: $movingHeadColor,
                        strobeFrequency: $strobeFrequency,
                        onNext: { currentStep = .summary }
                    )
                case .summary:
                    SummaryView(
                        includeLaser: includeLaser,
                        laserColor: laserColor,
                        laserMode: laserMode,
                        laserPattern: laserPattern,
                        includeMovingHead: includeMovingHead,
                        movingHeadColor: movingHeadColor,
                        strobeFrequency: strobeFrequency,
                        onConfirm: { currentStep = .selectLights }
                    )
                }
            }
            .navigationTitle("Queue Maker")
        }
    }
}

// Étape 1 : Sélection des lumières
struct SelectLightsView: View {
    @Binding var includeLaser: Bool
    @Binding var includeMovingHead: Bool
    var onNext: () -> Void
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Select lights")
                .bold()
                .font(.title)
            
            HStack(spacing: 20) {
                LightSelectionButton(
                    title: "Laser",
                    isSelected: $includeLaser,
                    imageName: "laser_icon"
                )
                LightSelectionButton(
                    title: "Moving Head",
                    isSelected: $includeMovingHead,
                    imageName: "moving_head_icon"
                )
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
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

// Étape 2 : Paramètres du laser
struct LaserSettingsView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @Binding var queue: Queue
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Select Laser Color")
                .font(.title2)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(1..<laserConfig.laserColors.count, id: \.self) { index in
                        let colorName = laserConfig.laserColors[index].name
                        let color = laserConfig.laserColors[index].color
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color)
                            .frame(width: 50, height: 50)
                            .overlay {
                                if queue.laserColor == colorName {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                        .font(.title)
                                }
                            }
                            .onTapGesture {
                                queue.laserColor = colorName
                            }
                    }
                    RoundedRectangle(cornerRadius: 10)
                        .multicolor()
                        .frame(width: 50, height: 50)
                        .overlay {
                            if queue.laserColor == laserConfig.laserColors[0].name {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                                    .font(.title)
                            }
                        }
                        .onTapGesture {
                            queue.laserColor = laserConfig.laserColors[0].name
                        }
                }
                .padding(.vertical)
            }
            
            Text("Select Laser Mode")
                .font(.title2)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Étape 3 : Paramètres du moving head
struct MovingHeadSettingsView: View {
    @Binding var selectedColor: String
    @Binding var strobeFrequency: Double
    var onNext: () -> Void
    
    let movingHeadColors = ["Blue", "White", "Pink", "Orange", "Green"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Moving Head Settings")
                .font(.title2)
            
            Text("Select Moving Head Color")
                .font(.headline)
            HStack {
                ForEach(movingHeadColors, id: \.self) { color in
                    Button(action: { selectedColor = color }) {
                        Circle()
                            .fill(Color(color.lowercased()))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                            )
                    }
                }
            }
            
            Slider(value: $strobeFrequency, in: 0...10, step: 0.1) {
                Text("Strobe Frequency")
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
        }
        .padding()
    }
}

// Résumé
struct SummaryView: View {
    let includeLaser: Bool
    let laserColor: String
    let laserMode: String
    let laserPattern: String
    let includeMovingHead: Bool
    let movingHeadColor: String
    let strobeFrequency: Double
    
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Summary")
                .font(.title2)
            
            if includeLaser {
                Text("Laser: Color \(laserColor), Mode \(laserMode), Pattern \(laserPattern)")
            }
            if includeMovingHead {
                Text("Moving Head: Color \(movingHeadColor), Strobe \(strobeFrequency, specifier: "%.1f") Hz")
            }
            
            Button(action: onConfirm) {
                Text("Confirm")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

enum Step {
    case selectLights
    case laserSettings
    case movingHeadSettings
    case summary
}

// Modèle de données pour une queue
struct Queue: Identifiable {
    let id = UUID()
    var includeLaser: Bool = false
    var laserColor: String = ""
    var laserMode: String = ""
    var laserPattern: String = ""
    var includeMovingHead: Bool = false
    var movingHeadColor: String = ""
    var strobeFrequency: Double = 0
}

struct CustomQueueMakerPreview: View {
    @State private var queue = Queue()
    var body: some View {
        LaserSettingsView(queue: $queue) {
            
        }
        .environmentObject(LaserConfig())
    }
}

#Preview {
    CustomQueueMakerPreview()
}
