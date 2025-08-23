//
//  ScannerView.swift
//  Hogwars
//
//  Created by Karis on 23/8/25.
//

import SwiftUI
import AVFoundation
import Vision

// 2. Implementing the view responsible for detecting the hand pose
struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var handPoseInfo: String
    @Binding var handPoints: [CGPoint]
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return viewController
        }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = .landscapeRight
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        return viewController
    }
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            self.detectHandPose(in: pixelBuffer)
        }
        
        func detectHandPose(in pixelBuffer: CVPixelBuffer) {
            let request = VNDetectHumanHandPoseRequest { (request, error) in
                guard let observations = request.results as? [VNHumanHandPoseObservation], !observations.isEmpty else {
                    DispatchQueue.main.async {
                        self.parent.handPoseInfo = "No hand detected"
                        self.parent.handPoints = []
                    }
                    return
                }
                
                if let observation = observations.first {
                    var points: [CGPoint] = []
                    
                    // Loop through all recognized points for each finger, including wrist
                    let handJoints: [VNHumanHandPoseObservation.JointName] = [
                        .wrist,  // Wrist joint
                        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,   // Thumb joints
                        .indexMCP, .indexPIP, .indexDIP, .indexTip, // Index finger joints
                        .middleMCP, .middlePIP, .middleDIP, .middleTip, // Middle finger joints
                        .ringMCP, .ringPIP, .ringDIP, .ringTip,     // Ring finger joints
                        .littleMCP, .littlePIP, .littleDIP, .littleTip // Little finger joints
                    ]
                    
                    for joint in handJoints {
                        if let recognizedPoint = try? observation.recognizedPoint(joint), recognizedPoint.confidence > 0.5 {
                            points.append(recognizedPoint.location)
                        }
                    }
                    
                    // Convert normalized Vision points to screen coordinates and update coordinates
                    let size = UIScreen.main.bounds.size
                    self.parent.handPoints = points.map { self.convertVisionPoint($0, in: size)}
                    self.parent.handPoseInfo = "Hand detected with \(points.count) points"
                }
            }
            
            request.maximumHandCount = 1
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Hand pose detection failed: \(error)")
            }
        }
        
        // Convert Vision's normalized coordinates to screen coordinates
        func convertVisionPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
            let screenSize = UIScreen.main.bounds.size
            let y = point.y * screenSize.height
            let x = point.x * screenSize.width
            return CGPoint(x: x, y: y)
        }
    }
}
