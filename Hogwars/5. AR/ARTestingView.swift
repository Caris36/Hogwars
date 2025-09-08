////
////  ARTestingView.swift
////  Hogwars
////
//  Created by Eugene Tan on 23/8/25.
////
////
//import SwiftUI
//import RealityKit
//import ARKit
//
//struct ARTestingView: View {
//    
//    private static let planeX: Float = 3.75
//    private static let planeZ: Float = 2.625
//    
//    @State private var assistant: Entity? = nil
//    @State private var projectile: Entity? = nil
//    
//    var body: some View {
//        RealityView { content, attachments in
//            do {
//                // identify root
//                let immersiveEntity = try await Entity(named: "Immersive", in: realityKitContentBundle)
//                
//                let projectileSceneEntity = try await Entity(named: "MainParticle", in: realityKitContentBundle)
//                guard let projectile = projectileSceneEntity.findEntity(named: "ParticleRoot") else { return }
//                projectile.children[0].components[ParticleEmitterComponent.self]?.isEmitting = false
//                projectile.children[1].components[ParticleEmitterComponent.self]?.isEmitting = false
//                projectile.components.set(ProjectileComponent())
//                
//                let impactParticleSceneEntity = try await Entity(named: "ImpactParticle", in: realityKitContentBundle)
//                guard let impactParticle = impactParticleSceneEntity.findEntity(named: "ImpactParticle") else { return }
//                impactParticle.position = [0, 0, 0]
//                impactParticle.components[ParticleEmitterComponent.self]?.burstCount = 500
//                impactParticle.components[ParticleEmitterComponent.self]?.emitterShapeSize.x = Self.planeX / 2.0
//                impactParticle.components[ParticleEmitterComponent.self]?.emitterShapeSize.z = Self.planeZ / 2.0
//                
//            }
//            //put ARView Container inside do {}
//        }
//    }
//    
//    struct ARViewContainer: UIViewRepresentable {
//        func makeUIView(context: Context) -> ARView {
//            let arView = ARView(frame: .zero)
//            
//            let config = ARWorldTrackingConfiguration()
//            config.planeDetection = [.horizontal, .vertical]
//            arView.session.run(config)
//            let seconds = 4.0
//            
//            do {
//                let earth2 = try ModelEntity.load(named: "Earth2")
//                print("Loaded Earth model")
//                
//                earth2.scale = [5, 5, 5]
//                
//                let anchorEntity = AnchorEntity(plane: .horizontal, minimumBounds: [0.1, 0.1])
//                anchorEntity.addChild(earth2)
//                arView.scene.addAnchor(anchorEntity)
//                
//                print("Added Earth to horizontal plane")
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//                    // Attach fire effect
//                    if let fire = try? Entity.load(named: "Fire") {
//                        fire.scale = [1.0, 1.0, 1.0]
//                        fire.setPosition([0, 0, 0], relativeTo: earth2)
//                        earth2.addChild(fire)
//                        print("Fire added to Earth")
//                    } else {
//                        print("Could not load Fire.usdz")
//                    }
//                }
//                
//                
//                
//            } catch {
//                print("Failed to load model: \(error)")
//            }
//            
//            
//            // particles
//            switch newValue {
//            case .projectileFlying:
//                // animate particle projectile
//                if let projectile = self.projectile {
//                    // hardcode the destination where the particle is going to move
//                    // so that it always traverse towards the center of the simulator screeen
//                    // the reason we do that is because we can't get the real transform of the anchor entity
//                    let dest = Transform(scale: projectile.transform.scale, rotation: projectile.transform.rotation,
//                                         translation: [-0.7, 0.15, -0.5] * 2)
//                    Task {
//                        let duration = 3.0
//                        projectile.position = [0, 0, 0]
//                        projectile.children[0].components[ParticleEmitterComponent.self]?.isEmitting = true
//                        projectile.children[1].components[ParticleEmitterComponent.self]?.isEmitting = true
//                        projectile.move(to: dest, relativeTo: self.characterEntity, duration: duration, timingFunction: .easeInOut)
//                        try? await Task.sleep(for: .seconds(duration))
//                        projectile.children[0].components[ParticleEmitterComponent.self]?.isEmitting = false
//                        projectile.children[1].components[ParticleEmitterComponent.self]?.isEmitting = false
//                    }
//                }
//                self.projectile?.components[ProjectileComponent.self]?.canBurst = true
//            }
//            
//            return arView
//        }
//        
//        func updateUIView(_ uiView: ARView, context: Context) {}
//    }
//}
