//
//  AdvancedSettingsView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-07-04.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject var laserConfig: LaserConfig
    @State private var isServerSettingsSaved: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Advanced Settings")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 25)

            VStack(alignment: .leading, spacing: 20) {
                Section(header: HStack {
                    Text("Connection").font(.title2).foregroundColor(.white)
                    if !isServerSettingsSaved {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                    }
                }) {
                    HStack {
                        TextField("Server IP Address", text: $laserConfig.serverIp)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                            .onChange(of: laserConfig.serverIp) {
                                isServerSettingsSaved = false
                            }
                        Text(":")
                        TextField("Port", text: $laserConfig.serverPort)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 70)
                            .onChange(of: laserConfig.serverPort) {
                                isServerSettingsSaved = false
                            }
                        Spacer()
                    }
                    HStack {
                        TextField("OLA IP Address", text: $laserConfig.olaIp)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                            .onChange(of: laserConfig.olaIp) {
                                isServerSettingsSaved = false
                            }
                        Text(":")
                        TextField("Port", text: $laserConfig.olaPort)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 70)
                            .onChange(of: laserConfig.olaPort) {
                                isServerSettingsSaved = false
                            }
                        Spacer()
                    }
                    Button(action: saveServerSettings) {
                        Text("Save")
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(saveButtonDisabled() ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .cornerRadius(10)
                    }
                    .disabled(saveButtonDisabled())
                }
                
                Divider()
                    .background()

                Section(header: Text("Adjustments").font(.title2).foregroundColor(.white)) {
                    Text("Vertical Adjust")
                    HStack {
                        Slider(value: $laserConfig.verticalAdjust, in: 31...95, step: 1)
                        Button("Reset", action: laserConfig.resetVerticalAdjust)
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 50, height: 40)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Divider()
                    .background()
                
                Section(header: HStack {
                    Text("Animations").font(.title2).foregroundColor(.white)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(laserConfig.horizontalAnimationEnabled || laserConfig.verticalAnimationEnabled ? .yellow : .primary.opacity(0.5))
                }) {
                    VStack(spacing: 10) {
                        Toggle(isOn: $laserConfig.horizontalAnimationEnabled) {
                            Text("Horizontal Animation")
                        }
                        HStack {
                            Slider(value: $laserConfig.horizontalAnimationSpeed, in: 127...190, step: 1)
                                .frame(maxWidth: .infinity)
                                .disabled(!laserConfig.horizontalAnimationEnabled)
                            Text("\(Int(laserConfig.horizontalAnimationSpeed))%")
                                .frame(width: 50)
                        }
                        Toggle(isOn: $laserConfig.verticalAnimationEnabled) {
                            Text("Vertical Animation")
                                .frame(width: 150, alignment: .leading)
                        }
                        HStack {
                            Slider(value: $laserConfig.verticalAnimationSpeed, in: 127...190, step: 1)
                                .frame(maxWidth: .infinity)
                                .disabled(!laserConfig.verticalAnimationEnabled)
                            Text("\(Int(laserConfig.verticalAnimationSpeed))%")
                                .frame(width: 50)
                        }
                        
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground).cornerRadius(20))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onChange(of: laserConfig.verticalAdjust) {
            laserConfig.setVerticalAdjust()
        }
        .onChange(of: laserConfig.horizontalAnimationEnabled) {
            laserConfig.setHorizontalAnimation()
        }
        .onChange(of: laserConfig.horizontalAnimationSpeed) {
            laserConfig.setHorizontalAnimation()
        }
        .onChange(of: laserConfig.verticalAnimationEnabled) {
            laserConfig.setVerticalAnimation()
        }
        .onChange(of: laserConfig.verticalAnimationSpeed) {
            laserConfig.setVerticalAnimation()
        }
    }
    
    func saveButtonDisabled() -> Bool {
        return laserConfig.olaIp.isEmpty || laserConfig.olaPort.isEmpty || laserConfig.serverIp.isEmpty || laserConfig.serverPort.isEmpty
    }
    
    func saveServerSettings() {
        laserConfig.saveConnectionSettings()
        isServerSettingsSaved = true
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
            .environmentObject(LaserConfig())
    }
}


