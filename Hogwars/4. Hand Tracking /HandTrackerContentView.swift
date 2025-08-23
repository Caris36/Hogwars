//
//  Untitled.swift
//  Hogwars
//
//  Created by Karis on 23/8/25.
//
import SwiftUI
import AVFoundation
import Vision

// 1. Application main interface
struct HandTrackerContentView: View {
    
    @State private var handPoseInfo: String = "Detecting hand poses..."
    @State private var handPoints: [CGPoint] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(handPoseInfo: $handPoseInfo, handPoints: $handPoints)
            
            // Draw lines between finger joints and the wrist
            Path { path in
                let fingerJoints = [
                    [1, 2, 3, 4],    // Thumb joints (thumbCMC -> thumbMP -> thumbIP -> thumbTip)
                    [5, 6, 7, 8],    // Index finger joints
                    [9, 10, 11, 12],  // Middle finger joints
                    [13, 14, 15, 16],// Ring finger joints
                    [17, 18, 19, 20] // Little finger joints
                ]
                
                if let wristIndex = handPoints.firstIndex(where: { $0 == handPoints.first }) {
                    for joints in fingerJoints {
                        guard joints.count > 1 else { continue }

                        // Connect wrist to the first joint of each finger
                        if joints[0] < handPoints.count {
                            let firstJoint = handPoints[joints[0]]
                            let wristPoint = handPoints[wristIndex]
                            path.move(to: wristPoint)
                            path.addLine(to: firstJoint)
                        }

                        // Connect the joints within each finger
                        for i in 0..<(joints.count - 1) {
                            if joints[i] < handPoints.count && joints[i + 1] < handPoints.count {
                                let startPoint = handPoints[joints[i]]
                                let endPoint = handPoints[joints[i + 1]]
                                path.move(to: startPoint)
                                path.addLine(to: endPoint)
                            }
                        }
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 3)
            
            // Draw circles for the hand points, including the wrist
            ForEach(handPoints, id: \.self) { point in
                Circle()
                    .fill(.red)
                    .frame(width: 15)
                    .position(x: point.x, y: point.y)
            }

            Text(handPoseInfo)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 50)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
