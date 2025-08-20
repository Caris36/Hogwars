//
//  CameraView.swift
//  Hogwars
//
//  Created by Karis on 16/8/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var model = FrameHandler()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // BACK CAMERA full screen
            if let backFrame = model.backFrame {
                Image(decorative: backFrame, scale: 1.0, orientation: .up)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // FRONT CAMERA thumbnail (top-left)
            if let frontFrame = model.frontFrame {
                Image(decorative: frontFrame, scale: 0.5, orientation: .up)
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
            } else {
                Color.black
                    .frame(width: 170, height: 170)
                    .padding(.top, 15)
                    .padding(.leading, 10)
                    .position(x: 85, y: 85)
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
