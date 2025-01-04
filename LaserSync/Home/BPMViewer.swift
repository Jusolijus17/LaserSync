//
//  BPMViewer.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2025-01-03.
//

import SwiftUI

struct BPMViewer: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    @StateObject private var bpmController = BPMViewerController()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(laserConfig.currentBpm) BPM")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .onChange(of: laserConfig.networkErrorCount) {
                        if laserConfig.networkErrorCount >= 3 {
                            bpmController.showRetry = true
                            bpmController.stopBlinking()
                        }
                    }
                
                Circle()
                    .fill(bpmController.getBpmIndicatorColor())
                    .frame(width: 20, height: 20)
                    .opacity(bpmController.isBlinking || laserConfig.currentBpm == 0 ? 1.0 : 0.0)
            }
            
            if !bpmController.showRetry {
                HStack {
                    Button {
                        hapticFeedback()
                        bpmController.decrementMultiplier()
                    } label: {
                        Image(systemName: "minus")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .fill(Color.red)
                            )
                    }
                    
                    Text(bpmController.multiplierText())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(bpmController.multiplierColor())
                    
                    Button {
                        hapticFeedback()
                        bpmController.incrementMultiplier()
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .fill(Color.white)
                            )
                    }
                }
                .frame(height: 30)
            } else {
                Button(action: {
                    laserConfig.restartBpmUpdate()
                    bpmController.showRetry = false
                }) {
                    Label("Retry", systemImage: "arrow.clockwise.circle")
                        .frame(height: 30)
                }
            }
        }
        .onChange(of: laserConfig.currentBpm) {
            if laserConfig.currentBpm != 0 {
                bpmController.restartBlinking()
            }
        }
        .onAppear {
            bpmController.setLaserConfig(laserConfig)
        }
        
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

#Preview {
    BPMViewer()
        .environmentObject(LaserConfig())
}
