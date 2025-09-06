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

        // Enable ARWorldTracking
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)

        // Load the Earth model from USDZ
        if let earthEntity = try? Entity.load(named: "Earth") {
            // Scale Earth (default might be huge)
            earthEntity.scale = SIMD3<Float>(0.1, 0.1, 0.1)

            // Place it at origin
            let anchor = AnchorEntity(world: [0, 0, -0.5]) // half a meter in front of camera
            anchor.addChild(earthEntity)
            arView.scene.addAnchor(anchor)
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
