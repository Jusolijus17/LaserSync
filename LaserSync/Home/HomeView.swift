//
//  HomeView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-05.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @StateObject private var homeController = HomeController()
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text("\(laserConfig.currentBpm) BPM")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .onChange(of: laserConfig.networkErrorCount) {
                            if laserConfig.networkErrorCount >= 3 {
                                homeController.showRetry = true
                                homeController.stopBlinking()
                            }
                        }
                    
                    Circle()
                        .fill(homeController.getBpmIndicatorColor())
                        .frame(width: 20, height: 20)
                        .opacity(homeController.isBlinking || laserConfig.currentBpm == 0 ? 1.0 : 0.0)
                }
                
                if !homeController.showRetry {
                    HStack {
                        Button {
                            hapticFeedback()
                            homeController.decrementMultiplier()
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
                        
                        Text(homeController.multiplierText())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(homeController.multiplierColor())
                        
                        Button {
                            hapticFeedback()
                            homeController.incrementMultiplier()
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
                        homeController.showRetry = false
                    }) {
                        Label("Retry", systemImage: "arrow.clockwise.circle")
                            .frame(height: 30)
                    }
                }
            }
            
            TabView {
                LaserHomePage()
                MovingHeadHomePage()
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .environmentObject(homeController)
            .onChange(of: laserConfig.laser.mode) { oldValue, newValue in
                print("Changed!", newValue)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onChange(of: laserConfig.currentBpm) {
            if laserConfig.currentBpm != 0 {
                homeController.restartBlinking()
            }
        }
        .onAppear {
            homeController.setLaserConfig(laserConfig)
        }
    }
    
    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Square Button

struct SquareButton<Content: View>: View {
    var title: String
    var action: () -> Void
    var backgroundColor: Color = Color.gray
    var content: () -> Content // Closure retournant une vue

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 150)
                .overlay(content: {
                    ZStack {
                        content()
                        VStack {
                            Spacer()
                            Text(title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.5))
                                .padding()
                        }
                    }
                })
                .cornerRadius(10)
        }
        .onTapGesture {
            hapticFeedback()
            action()
        }
    }

    func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LaserConfig())
            .environmentObject(SharedStates())
    }
}
