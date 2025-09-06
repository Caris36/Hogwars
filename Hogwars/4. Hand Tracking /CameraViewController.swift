import UIKit
import SwiftUI
import AVFoundation
import Vision
import Combine

enum UIDeviceOrientation {
    case landscapeRight
}

let Orientation = UIDeviceOrientation.landscapeRight

//TODO: Initialise

class CameraModel: ObservableObject {
    /// Snapshot frame from camera feed (used as fallback)
    @Published var videoDeviceFrame: UIImage? = nil
    
    /// Indicates whether the live camera preview is running
    @Published var isCameraReady: Bool = false
    
    /// Optional: store processed points from Vision if needed
    @Published var processedPoints: [(thumbTip: CGPoint, indexTip: CGPoint)] = []
    
    /// Reset the model state
    func reset() {
        videoDeviceFrame = nil
        processedPoints.removeAll()
        isCameraReady = false
    }
    
    /// Update snapshot frame
    func updateFrame(_ image: UIImage) {
        DispatchQueue.main.async {
            self.videoDeviceFrame = image
        }
    }
    
    /// Update camera ready state
    func setCameraReady(_ ready: Bool) {
        DispatchQueue.main.async {
            self.isCameraReady = ready
        }
    }
    
    /// Add processed points (optional for gestures)
    func addPoints(_ thumb: CGPoint, _ index: CGPoint) {
        DispatchQueue.main.async {
            self.processedPoints.append((thumbTip: thumb, indexTip: index))
        }
    }
}

struct CameraViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No dynamic updates needed
    }
}

class CameraViewController: UIViewController, ObservableObject{
    @Published var frontFrame: CGImage?
    private var cameraView: CameraView { return view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private let drawOverlay = CAShapeLayer()
    private let drawPath = UIBezierPath()
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private var gestureProcessor = HandGestureProcessor()
    private var outputToCameraPosition: [AVCaptureOutput: AVCaptureDevice.Position] = [:]
    private let context = CIContext()
    override func loadView() {
        self.view = CameraView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawOverlay.frame = view.layer.bounds
        drawOverlay.lineWidth = 5
        drawOverlay.backgroundColor = UIColor.clear.cgColor
        drawOverlay.strokeColor = UIColor.systemPink.cgColor
        drawOverlay.fillColor = UIColor.clear.cgColor
        drawOverlay.lineCap = .round
        view.layer.addSublayer(drawOverlay)
        
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        // Add double tap gesture recognizer for clearing the draw path.
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        recognizer.numberOfTouchesRequired = 1
        recognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(recognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            print("Camera error: \(error)")
        }
        
        let previewLayer = cameraView.previewLayer
        previewLayer.connection!.videoOrientation = .landscapeRight
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw NSError(domain: "Camera", code: 1, userInfo: [NSLocalizedDescriptionKey: "No front camera"])
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw NSError(domain: "Camera", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create device input"])
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard session.canAddInput(deviceInput) else {
            throw NSError(domain: "Camera", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not add device input"])
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            outputToCameraPosition[dataOutput] = .front
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
                                        Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw NSError(domain: "Camera", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not add output"])
        }
        
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], color: .clear)
            return
        }
        
        let previewLayer = cameraView.previewLayer
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        
        gestureProcessor.processPointsPair((thumbPointConverted, indexPointConverted))
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        var tipsColor: UIColor
        switch state {
        case .possiblePinch, .possibleApart:
            evidenceBuffer.append(pointsPair)
            tipsColor = .orange
        case .pinched:
            for bufferedPoints in evidenceBuffer {
                updatePath(with: bufferedPoints, isLastPointsPair: false)
            }
            evidenceBuffer.removeAll()
            updatePath(with: pointsPair, isLastPointsPair: false)
            tipsColor = .green
        case .apart, .unknown:
            evidenceBuffer.removeAll()
            updatePath(with: pointsPair, isLastPointsPair: true)
            tipsColor = .red
        }
        cameraView.showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
    }
    
    private func updatePath(with points: HandGestureProcessor.PointsPair, isLastPointsPair: Bool) {
        let (thumbTip, indexTip) = points
        let drawPoint = CGPoint.midPoint(p1: thumbTip, p2: indexTip)

        if isLastPointsPair {
            if let lastPoint = lastDrawPoint {
                drawPath.addLine(to: lastPoint)
            }
            lastDrawPoint = nil
        } else {
            if lastDrawPoint == nil {
                drawPath.move(to: drawPoint)
                isFirstSegment = true
            } else {
                let lastPoint = lastDrawPoint!
                let midPoint = CGPoint.midPoint(p1: lastPoint, p2: drawPoint)
                if isFirstSegment {
                    drawPath.addLine(to: midPoint)
                    isFirstSegment = false
                } else {
                    drawPath.addQuadCurve(to: midPoint, controlPoint: lastPoint)
                }
            }
            lastDrawPoint = drawPoint
        }
        drawOverlay.path = drawPath.cgPath
    }
    
    @objc func handleGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        evidenceBuffer.removeAll()
        drawPath.removeAllPoints()
        drawOverlay.path = drawPath.cgPath
    }
}

// MARK: - Capture Output Delegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
                if let position = self.outputToCameraPosition[output] {
                    switch position {
                    case .front:
                        self.frontFrame = cgImage
                    default:
                        break
                    }
                }
            }
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else { return }
            
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            
            guard let thumbTipPoint = thumbPoints[.thumbTip],
                  let indexTipPoint = indexFingerPoints[.indexTip] else { return }
            
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else { return }
            
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            cameraFeedSession?.stopRunning()
            print("Vision error: \(error)")
        }
    }
}

// MARK: - Helpers

extension CGPoint {
    static func midpointBetween(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
}


