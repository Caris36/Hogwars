//
//  ARTestingView.swift
//  Hogwars
//
//  Created by Eugene Tan on 23/8/25.
//
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
            let earth2 = try ModelEntity.load(named: "Earth2")
            print("Loaded Earth model")

            earth2.scale = [5, 5, 5]

            let anchorEntity = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1])
            anchorEntity.addChild(earth2)
            arView.scene.addAnchor(anchorEntity)

            print("Added Earth to horizontal plane")

            // Attach fire effect
            if let fire = try? Entity.load(named: "Fire") {
                fire.scale = [1, 1, 1]
                fire.setPosition([0, 0, 0], relativeTo: earth2)
                earth2.addChild(fire)
                print("Fire added to Earth")
            } else {
                print("Could not load Fire.usdz")
            }



        } catch {
            print("Failed to load model: \(error)")
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
