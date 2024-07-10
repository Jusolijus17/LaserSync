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
                ForEach(0..<laserConfig.colors.count, id: \.self) { index in
                    Button(action: {
                        hapticFeedback()
                        changeLaserColor(specificColorIndex: index)
                    }) {
                        Rectangle()
                            .fill(laserConfig.colors[index].color)
                            .frame(height: 100)
                            .overlay(content: {
                                Text(laserConfig.colors[index].name.capitalized)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            })
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                hapticFeedback()
                changeLaserColor(specificColorIndex: -1)
            }) {
                Text("Multicolor")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
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
            if index == -1 {
                laserConfig.currentColorIndex = 0
                laserConfig.setColor(color: "multicolor")
            } else {
                laserConfig.currentColorIndex = index
                laserConfig.setColor()
            }
        } else {
            laserConfig.currentColorIndex = (laserConfig.currentColorIndex + 1) % laserConfig.colors.count
            laserConfig.setColor()
        }
    }
}

struct LaserColorView_Previews: PreviewProvider {
    static var previews: some View {
        LaserColorView()
            .environmentObject(LaserConfig())
    }
}
