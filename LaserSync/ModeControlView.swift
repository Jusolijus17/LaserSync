//
//  ModeControlView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

struct ModeControlView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(laserConfig.laserMode.rawValue.capitalized)
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(LaserMode.allCases) { mode in
                    Button(action: {
                        hapticFeedback()
                        changeLaserMode(mode: mode)
                    }) {
                        Text(mode.rawValue.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(laserConfig.laserMode == mode ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                hapticFeedback()
                laserConfig.toggleStrobeMode()
            }) {
                Text("Strobe")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(laserConfig.strobeModeEnabled ? Color.yellow : Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom)
            
            Spacer().fixedSize()
        }
    }
    
    func changeLaserMode(mode: LaserMode) {
        laserConfig.laserMode = mode
        laserConfig.setMode()
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct ModeControlView_Previews: PreviewProvider {
    static var previews: some View {
        ModeControlView()
            .environmentObject(LaserConfig())
    }
}

