//
//  MasterSliderPage.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-31.
//

import SwiftUI

struct MasterSliderPage: View {
    @EnvironmentObject private var laserConfig: LaserConfig
    
    var body: some View {
        CustomSliderView(sliderValue: $laserConfig.masterSliderValue, title: "Master", orientation: .vertical, onValueChange: { value in
            laserConfig.setMasterSliderValue(value)
        })
            .frame(width: 125, height: 550)
    }
}

#Preview {
    MasterSliderPage()
        .environmentObject(LaserConfig())
}
