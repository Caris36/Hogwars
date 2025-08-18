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
            // insert back camera view
            
            if let frame = model.frame {
                Image(decorative: frame, scale: 0.5, orientation: .up)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 170, alignment: .topLeading)
                    .clipped()
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .padding(.top, 10)
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
