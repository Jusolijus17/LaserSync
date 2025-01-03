//
//  RFDevicesPage.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-02.
//

import SwiftUI

struct RFDevicesPage: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    
    var body: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                
                AnimatedSquareButton(title: "Strobe", action: {
                    laserConfig.setRfStrobeOnOff(isOn: true)
                }, highlightColor: .green) {
                    Text("ON")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                AnimatedSquareButton(title: "Strobe", action: {
                    laserConfig.setRfStrobeOnOff(isOn: false)
                }, highlightColor: .red) {
                    Text("OFF")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                AnimatedSquareButton(title: "Strobe speed", action: {
                    laserConfig.setRfStrobeSpeedFasterSlower(faster: true)
                }, highlightColor: .green) {
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                AnimatedSquareButton(title: "Strobe speed", action: {
                    laserConfig.setRfStrobeSpeedFasterSlower(faster: false)
                }, highlightColor: .blue) {
                    Image(systemName: "minus")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                AnimatedSquareButton(title: "Smoke", action: {
                    laserConfig.setSmokeOnOff(isOn: true)
                }, highlightColor: .green) {
                    Text("ON")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                AnimatedSquareButton(title: "Smoke", action: {
                    laserConfig.setSmokeOnOff(isOn: false)
                }, highlightColor: .red) {
                    Text("OFF")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
            
            AnimatedButton(action: {
                laserConfig.rfStrobeReset()
            }) {
                Label("Reset Strobe", systemImage: "gobackward")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .padding(.bottom)
        }
        .padding()
    }
}

struct AnimatedSquareButton<Content: View>: View {
    var title: String
    var action: () -> Void
    var initialColor: Color = .gray
    var highlightColor: Color = .yellow
    var content: () -> Content

    @State private var backgroundColor: Color

    init(title: String, action: @escaping () -> Void, initialColor: Color = .gray, highlightColor: Color = .yellow, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.action = action
        self.initialColor = initialColor
        self.highlightColor = highlightColor
        self.content = content
        _backgroundColor = State(initialValue: initialColor) // Initialiser la couleur avec `initialColor`
    }

    var body: some View {
        SquareButton(title: title, action: {
            backgroundColor = highlightColor

            // Revenir à la couleur d'origine après un délai
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                backgroundColor = initialColor
            }

            // Exécuter l'action principale
            action()
        }, backgroundColor: backgroundColor, content: content)
    }
}

struct AnimatedButton<Label: View>: View {
    var action: () -> Void
    var initialColor: Color = .gray
    var highlightColor: Color = .yellow
    @ViewBuilder var label: () -> Label
    
    @State private var backgroundColor: Color
    
    init(action: @escaping () -> Void, initialColor: Color = .gray, highlightColor: Color = .yellow, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.initialColor = initialColor
        self.highlightColor = highlightColor
        self.label = label
        _backgroundColor = State(initialValue: initialColor)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)
            .frame(height: 50)
            .overlay {
                label()
            }
            .onTapGesture {
                backgroundColor = highlightColor
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    backgroundColor = initialColor
                }
                action()
            }
        
    }
}

#Preview {
    RFDevicesPage()
        .environmentObject(LaserConfig())
}
