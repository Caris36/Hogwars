import AVFoundation
import CoreImage

class FrameHandler: NSObject, ObservableObject {
    @Published var frontFrame: CGImage?
    @Published var backFrame: CGImage?
    
    private var permissionGranted = false
    private var captureSession = AVCaptureMultiCamSession()
    private var outputToCameraPosition: [AVCaptureOutput: AVCaptureDevice.Position] = [:]
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupCaptureSession() {
        guard permissionGranted else { return }
        
        // FRONT camera
        if let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let frontInput = try? AVCaptureDeviceInput(device: front),
           captureSession.canAddInput(frontInput) {
            captureSession.addInput(frontInput)
            
            let frontOutput = AVCaptureVideoDataOutput()
            frontOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "frontQueue"))
            if captureSession.canAddOutput(frontOutput) {
                captureSession.addOutput(frontOutput)
                outputToCameraPosition[frontOutput] = .front
            }
        }
        
        // BACK camera
        if let back = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let backInput = try? AVCaptureDeviceInput(device: back),
           captureSession.canAddInput(backInput) {
            captureSession.addInput(backInput)
            
            let backOutput = AVCaptureVideoDataOutput()
            backOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "backQueue"))
            if captureSession.canAddOutput(backOutput) {
                captureSession.addOutput(backOutput)
                outputToCameraPosition[backOutput] = .back
            }
        }
    }
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        DispatchQueue.main.async {
            if let position = self.outputToCameraPosition[output] {
                switch position {
                case .front:
                    self.frontFrame = cgImage
                case .back:
                    self.backFrame = cgImage
                default:
                    break
                }
            }
        }
    }
}
