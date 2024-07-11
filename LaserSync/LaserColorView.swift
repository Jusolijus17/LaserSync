//
//  LaserColorView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI
import UIKit

struct LaserColorView: View {
    @EnvironmentObject var laserConfig: LaserConfig

    var body: some View {
        VStack(spacing: 20) {
            Button {
                hapticFeedback()
                changeLaserColor()
            } label: {
                Rectangle()
                    .fill(laserConfig.currentColor)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .background {
                        if laserConfig.currentColorName == "multicolor" {
                            RoundedRectangle(cornerRadius: 20)
                                .multicolor()
                        }
                    }
                    .overlay(content: {
                        ZStack {
                            Text("Tap to change")
                                .font(.title)
                                .foregroundStyle(.white)
                            VStack {
                                Spacer()
                                Text(laserConfig.currentColorName.capitalized)
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                    .padding(.bottom)
                            }
                        }
                    })
                    .cornerRadius(20)
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(1..<laserConfig.colors.count, id: \.self) { index in
                    Button(action: {
                        hapticFeedback()
                        changeLaserColor(specificColorIndex: index)
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(laserConfig.colors[index].color)
                            .stroke(laserConfig.currentColorIndex == index ? Color.white : Color.clear, lineWidth: 3)
                            .frame(height: 100)
                            .overlay(content: {
                                Text(laserConfig.colors[index].name.capitalized)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            })
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                hapticFeedback()
                changeLaserColor(specificColorIndex: 0)
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .multicolor()
                    .frame(height: 50)
                    .overlay(content: {
                        Text(laserConfig.colors[0].name.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    })
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                hapticFeedback()
                laserConfig.toggleBpmSync(type: "color")
            }) {
                Text("BPM Sync")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(laserConfig.activeSyncTypes.contains("color") ? Color.yellow : Color.gray)
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

    func changeLaserColor(specificColorIndex: Int? = nil) {
        if let index = specificColorIndex {
            laserConfig.currentColorIndex = index
        } else {
            laserConfig.currentColorIndex = (laserConfig.currentColorIndex + 1) % laserConfig.colors.count
        }
        laserConfig.setColor()
    }
}

struct LaserColorView_Previews: PreviewProvider {
    static var previews: some View {
        LaserColorView()
            .environmentObject(LaserConfig())
    }
}
