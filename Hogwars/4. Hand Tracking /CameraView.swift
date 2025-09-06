//
//  CameraView.swift
//  Hogwars
//
//  Created by Karis on 30/8/25.
//

import SwiftUI
import UIKit
import AVFoundation

// MARK: - UIKit Camera View
class CameraView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    func showPoints(_ points: [CGPoint], color: UIColor) {
        // Optional: draw points on top of the preview
    }
}

// MARK: - SwiftUI Wrapper for CameraView
struct CameraPreview: UIViewRepresentable {
    var session: AVCaptureSession

    func makeUIView(context: Context) -> CameraView {
        let view = CameraView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraView, context: Context) {
        // Update UI dynamically if needed
    }
}

// MARK: - SwiftUI Container View
struct CameraContainerView: View {
    @ObservedObject var model: CameraModel  // Your model with videoDeviceFrame
    var session: AVCaptureSession

    var body: some View {
        ZStack {
             // Live camera preview
//            if model.isCameraReady {
//                CameraPreview(session: session)
//                    .frame(width: 170, height: 140)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .shadow(radius: 4)
//                    rotationEffect(.degrees(180))
//                    .scaleEffect(x: -1, y: 1)
//                    .padding(.top, 15)
//                    .padding(.bottom, 10)
//            }
            //  Fallback video snapshot
            if model.isCameraReady {
                CameraPreview(session: session)
                if let videoDeviceFrame = model.videoDeviceFrame {
                    Image(decorative: videoDeviceFrame as! CGImage, scale: 0.5, orientation: .up)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 140, alignment: .topLeading)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: -1, y: 1)
                        .padding(.top, 15)
                        .padding(.bottom, 10)
                        .position(x: 85, y: 85)
                }
            }
            //  Black placeholder
            else {
                Color.black
                    .frame(width: 170, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
            }
        }
    }
}
