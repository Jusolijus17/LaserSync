//
//  PatternControlView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI
import UIKit

struct PatternControlView: View {
    @EnvironmentObject var laserConfig: LaserConfig

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(style: .init(lineWidth: 5, lineJoin: .round))
                .background {
                    laserConfig.currentLaserPattern.shape
                        .multicolor(isEnabled: laserConfig.laserColor == .clear)
                        .foregroundStyle(laserConfig.laserColor)
                        .padding(20)
                }
                .shadow(radius: 10)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(LaserPattern.allCases) { laserPattern in
                    Button(action: {
                        hapticFeedback()
                        if laserConfig.laserBPMSyncModes.contains(.pattern) {
                            laserConfig.togglePatternInclusion(pattern: laserPattern)
                        } else {
                            laserConfig.currentLaserPattern = laserPattern
                            laserConfig.setPattern()
                        }
                    }) {
                        laserPattern.shape
                            .foregroundStyle(.white)
                            .padding(20)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(getBackgroundColor(pattern: laserPattern))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                hapticFeedback()
                laserConfig.toggleBpmSync(mode: .pattern)
            }) {
                Text("BPM Sync")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(laserConfig.laserBPMSyncModes.contains(.pattern) ? Color.yellow : Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func getBackgroundColor(pattern: LaserPattern) -> Color {
        if laserConfig.currentLaserPattern == pattern && laserConfig.laserBPMSyncModes.contains(.pattern) && laserConfig.laserIncludedPatterns.contains(pattern) {
            return .green
        } else if laserConfig.currentLaserPattern == pattern && !laserConfig.laserBPMSyncModes.contains(.pattern) {
            return .green
        } else if laserConfig.laserBPMSyncModes.contains(.pattern) && !laserConfig.laserIncludedPatterns.contains(pattern) {
            return .gray.opacity(0.5)
        } else {
            return .gray
        }
    }
}

struct PatternControlView_Previews: PreviewProvider {
    static var previews: some View {
        PatternControlView()
            .environmentObject(LaserConfig())
    }
}

struct Pattern {
    let name: String
    let shape: AnyView
}

struct StraightLineShape: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 10, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width - 10, y: geometry.size.height / 2))
            }
            .stroke(lineWidth: 5)
        }
    }
}

struct DashedLineShape: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 5, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: (geometry.size.width / 3) - 5, y: geometry.size.height / 2))
                path.move(to: CGPoint(x: geometry.size.width / 3 + 5, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: (geometry.size.width / 3) * 2 - 5, y: geometry.size.height / 2))
                path.move(to: CGPoint(x: (geometry.size.width / 3) * 2 + 5, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width - 5, y: geometry.size.height / 2))
            }
            .stroke(lineWidth: 5)
        }
    }
}

struct DottedLineShape: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 5, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width - 5, y: geometry.size.height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: 5, dash: [8, 13]))
        }
    }
}

struct WaveLineShape: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height / 2
                let waveHeight = height / 6
                let waveLength = width / 4

                path.move(to: CGPoint(x: 0, y: midHeight + waveHeight))
                for i in stride(from: 0, to: width - 10, by: waveLength) {
                    path.addQuadCurve(to: CGPoint(x: i + waveLength / 2, y: midHeight - waveHeight),
                                      control: CGPoint(x: i + waveLength / 4, y: midHeight))
                    path.addQuadCurve(to: CGPoint(x: i + waveLength, y: midHeight + waveHeight),
                                      control: CGPoint(x: i + 3 * waveLength / 4, y: midHeight))
                }
            }
            .stroke(lineWidth: 5)
        }
    }
}
