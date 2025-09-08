//
//  ARTestingView2.swift
//  Hogwars
//
//  Created by Hailey Tan on 8/9/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ARTestingView2: View {

    private static let planeX: Float = 3.75
    private static let planeZ: Float = 2.625

    @State private var assistant: Entity? = nil
    @State private var projectile: Entity? = nil

    var body: some View {
        ARViewContainer()
        }
    }
struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Enable plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)

        Task {
            do {
                // Load Earth model
                let earthEntity = try await ModelEntity(named: "Earth2")
                earthEntity.scale = [5, 5, 5]

                // Create anchor and add Earth to scene
                let anchorEntity = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1])
                anchorEntity.addChild(earthEntity)
                arView.scene.addAnchor(anchorEntity)
                print("Added Earth to scene")

                // Delay before particle animation
                try await Task.sleep(for: .seconds(1))

                // Load particle projectile
                let projectileSceneEntity = try await Entity(named: "MainParticle", in: Bundle.main)

                guard let projectile = projectileSceneEntity.findEntity(named: "ParticleRoot") else {
                    print("Could not find ParticleRoot")
                    return
                }

                projectile.scale = [1.0, 1.0, 1.0]
                arView.scene.anchors.append(AnchorEntity(world: [0, 0, 0])) // Temporary root

                // Place projectile at camera position
                if let cameraTransform = arView.session.currentFrame?.camera.transform {
                    let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x,
                                                      cameraTransform.columns.3.y,
                                                      cameraTransform.columns.3.z)
                    projectile.position = cameraPosition
                }

                let projectileAnchor = AnchorEntity(world: projectile.position)
                projectileAnchor.addChild(projectile)
                arView.scene.addAnchor(projectileAnchor)


                // Start particle emission
                projectile.children.first?.components[ParticleEmitterComponent.self]?.isEmitting = true

                // Animate to Earth
                let destination = earthEntity.position(relativeTo: nil)
                projectile.move(to: Transform(translation: destination),
                                relativeTo: nil,
                                duration: 3.0,
                                timingFunction: .easeInOut)

                // Stop emission after arrival
                try await Task.sleep(for: .seconds(1))
                projectile.children.first?.components[ParticleEmitterComponent.self]?.isEmitting = false

                // Attach to Earth after arrival
                earthEntity.addChild(projectile)
                projectile.position = .zero // Attach to center of Earth

                print("Particle reached Earth and attached")

            } catch {
                print("Error loading models: \(error)")
            }
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
