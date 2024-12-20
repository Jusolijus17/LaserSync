//
//  EditCueView.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-12-17.
//

import SwiftUI

struct EditCueView: View {
    var body: some View {
        CueListView()
    }
}

struct CueListView: View {
    @State private var cues: [Cue] = [] // Stocker les cues chargées
    
    var body: some View {
        List {
            if cues.isEmpty {
                Text("No cues")
            } else {
                ForEach(cues) { cue in
                    NavigationLink(destination: CueMakerView(currentStep: getCueMakerStep(cue))) {
                        CueRowView(cue: cue)
                    }
                }
                .onDelete(perform: deleteCue)
            }
        }
        .navigationTitle("Saved Cues")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.cues = Cue().loadCues()
        }
    }
    
    func getCueMakerStep(_ cue: Cue) -> CueMakerStep {
        if cue.includeLaser {
            return .laserSettings
        }
        return .movingHeadSettings
    }
    
    // Fonction pour obtenir les lumières activées
    func getLights(cue: Cue) -> String {
        var lights: [String] = []
        if cue.includeLaser { lights.append("Laser") }
        if cue.includeMovingHead { lights.append("Moving Head") }
        return lights.isEmpty ? "No Lights" : "Lights: " + lights.joined(separator: ", ")
    }
    
    func deleteCue(at offsets: IndexSet) {
        cues.remove(atOffsets: offsets)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(cues) {
            UserDefaults.standard.set(data, forKey: "savedCues")
        }
    }
}

// Vue séparée pour la cellule (HStack)
struct CueRowView: View {
    let cue: Cue
    
    var body: some View {
        HStack {
            LaunchpadButton(color: cue.color)
                .frame(width: 40, height: 40)
            
            Divider()
                .frame(height: 50)
                .padding(.horizontal, 5)
            
            VStack(alignment: .leading) {
                Text(cue.name)
                    .font(.headline)
                Text(getLights(cue: cue))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    // Fonction locale pour obtenir les lumières activées
    func getLights(cue: Cue) -> String {
        var lights: [String] = []
        if cue.includeLaser { lights.append("Laser") }
        if cue.includeMovingHead { lights.append("Moving Head") }
        return lights.isEmpty ? "No Lights" : "Lights: " + lights.joined(separator: ", ")
    }
}

struct CueListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditCueView()
                .onAppear {
                    Cue.savePreviewCues()
                }
        }
    }
}
