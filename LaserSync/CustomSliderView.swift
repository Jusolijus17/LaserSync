//
//  CustomSliderView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-26.
//

import SwiftUI

struct CustomSliderView: View {
    @Binding var sliderValue: Double
    @State var title: String

    var body: some View {
        ZStack {
            // Outer border (blue rounded rectangle)
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue, lineWidth: 3)
                .frame(height: 50)

            // Slider background (gray rounded rectangle - stays static)
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.6))
                .frame(height: 50)
            
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.black.opacity(0.5))

            // Use GeometryReader to manage the fill of the slider
            GeometryReader { geometry in
                let sliderWidth = geometry.size.width
                
                ZStack(alignment: .leading) {
                    // Filled part of the slider (white, dynamic width based on slider value)
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .frame(width: CGFloat(sliderValue) / 100 * sliderWidth, height: 50)
                    
                    // Value text at the bottom-right inside the slider
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("\(Int(sliderValue))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.trailing, 10)
                                .padding(.bottom, 5)
                        }
                    }
                }
                .contentShape(Rectangle()) // Make the whole slider area tappable
                .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                    // Calculate the new slider value based on drag position within the full slider width
                    let newValue = min(max(0, value.location.x / sliderWidth * 100), 100)
                    sliderValue = newValue
                }))
            }
        }
        .frame(height: 50) // Fix the height to avoid conflicts in layout
    }
}

struct CustomSlider_Preview: PreviewProvider {
    static var previews: some View {
        CustomSliderView(sliderValue: .constant(50), title: "Test")
    }
}
