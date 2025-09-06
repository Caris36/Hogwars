//
//  ContentView.swift
//  Hogwars
//
//  Created by Karis on 19/7/25.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    var body: some View {
        ZStack {
            CameraViewControllerWrapper()
             //CameraContainerView(model: CameraModel(), session: AVCaptureSession())
            // CameraPreview(session: AVCaptureSession())
            // CameraView()
            
            VStack {
                Spacer()
                Text("Hand Tracking Active")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
                    .padding()
            }
        }
        .ignoresSafeArea()
    }
}
