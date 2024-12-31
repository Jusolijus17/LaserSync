//
//  ModeSelector.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-30.
//

import SwiftUI

struct ModeSelector: View {
    @Binding var selectedMode: LightMode
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
            ForEach(LightMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                }) {
                    Text(mode.rawValue.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(selectedMode == mode ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
    }
}

#Preview {
    ModeSelector(selectedMode: .constant(.manual))
}
