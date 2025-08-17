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
        GeometryReader { geo in
            if let frame = model.frame {
                Image(decorative: frame, scale: 1.0, orientation: .up)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .scaleEffect(0.8)
                    .clipped()
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
    }
}
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
