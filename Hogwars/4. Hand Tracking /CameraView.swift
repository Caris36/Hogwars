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
        
        if let connection = view.previewLayer.connection, connection.isVideoOrientationSupported {
            
                connection.videoOrientation = .landscapeRight
            }
        return view
    }

    func updateUIView(_ uiView: CameraView, context: Context) {
        // Update UI dynamically if needed
    }
}

// MARK: - SwiftUI Container View
