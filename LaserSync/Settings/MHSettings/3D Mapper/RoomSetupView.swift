//
//  RoomSetupView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-11-25.
//

import SwiftUI
import SceneKit

struct RoomSetupView: View {
    @EnvironmentObject var roomModel: RoomModel

    var body: some View {
        Form {
            Section(header: Text("Dimensions de la pièce")) {
                HStack {
                    Text("Largeur (X)")
                    Spacer()
                    TextField("Largeur", value: $roomModel.roomWidth, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }

                HStack {
                    Text("Profondeur (Z)")
                    Spacer()
                    TextField("Profondeur", value: $roomModel.roomDepth, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }

                HStack {
                    Text("Hauteur (Y)")
                    Spacer()
                    TextField("Hauteur", value: $roomModel.roomHeight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }

            NavigationLink(destination: LightPositioningView().environmentObject(roomModel)) {
                Text("Positionner la lumière")
            }
        }
        .navigationTitle("Room config")
    }
}

#Preview {
    NavigationView {
        RoomSetupView()
            .environmentObject(RoomModel())
    }
}
