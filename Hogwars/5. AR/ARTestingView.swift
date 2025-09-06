//
//  ARTestingView.swift
//  Hogwars
//
//  Created by Eugene Tan on 23/8/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ARTestingView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
        
    }
}
struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)

        do {
            let modelEntity = try ModelEntity.load(named: "Earth")
            print("✅ Loaded Earth model")
            modelEntity.scale = [0.1, 0.1, 0.1]

            let anchorEntity = AnchorEntity(world: [0, 0, -0.5])
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)

            print("✅ Added Earth to AR scene")

            // Optionally test fire
            castIncendio(on: modelEntity)

        } catch {
            print("❌ Failed to load model: \(error)")
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

//NEED TO MAKE Fire.usdz entity
func castIncendio(on earth: Entity) {
    // For iOS 16.6 we attach a fire model (usdz) instead of particles
    if let fire = try? Entity.load(named: "Fire") { // make sure Fire.usdz is in project
        fire.scale = [0.2, 0.2, 0.2]
        fire.setPosition([0, 0, 0], relativeTo: earth) // attach to Earth center
        earth.addChild(fire)
    }
}

