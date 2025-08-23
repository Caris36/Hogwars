//
//  CustomARView.swift
//  Hogwars
//
//  Created by Eugene Tan on 23/8/25.
//
import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    dynamic required init?(coder decoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(){
        self.init(frame: UIScreen.main.bounds)
        placeBlueBlock()
    }
    func configurationExamples(){
        //tracks the device relative to the environment
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
        
//        //tracks wrt global coordinates (possibly not supported)
//        let _ = ARGeoTrackingConfiguration()
        
        //tracks faces in the scene
        let _ = ARFaceTrackingConfiguration()
        //tracks bodies in the scene
        let _ = ARBodyTrackingConfiguration()
    }
    func anchorExamples(){
        //attach anchors at specific coordinates in the iphone centered coordinate system
        let coordinateAnchor = AnchorEntity(world: .zero)
        
        //attach anchors to detected planes (works best with devices LIDAR sensor)
        let _ = AnchorEntity(plane: .horizontal)
        let _ = AnchorEntity(plane: .vertical)
        
        //attach anchors to tracked body parts
        let _ = AnchorEntity(.face)
        
//        //attach anchors to tracked images, such as markers and visual codes
//        let _ = AnchorEntity(.image(group: <#T##String#>, name: <#T##String#>))
        
        //add an anchor to the scene
        scene.addAnchor(coordinateAnchor)
    }
    func entityExamples(){
        //load an entity from a usdz file
        let _ = try? Entity.load(named: "usdzFileName")
        
        //load entity from a reality file, animations and interactive
        let _ = try? Entity.load(named: "realityFileName")
        
        //generate entity with code, like for super simple
        let box = MeshResource.generateBox(size: 1)
        let entity = ModelEntity(mesh: box)
        
        //add entity to an anchor so its placed in the scene
        let anchor = AnchorEntity()
        anchor.addChild(entity)
    }
    func placeBlueBlock(){
        let block = MeshResource.generateBox(size: 1)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let entity = ModelEntity(mesh: block, materials: [material])
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(entity)
        scene.addAnchor(anchor)
    }
}
