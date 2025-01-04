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
            BPMViewer()
            
            TabView {
                LaserHomePage()
                MovingHeadHomePage()
                SpiderHeadHomePage()
                RFDevicesPage()
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .environmentObject(homeController)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
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
