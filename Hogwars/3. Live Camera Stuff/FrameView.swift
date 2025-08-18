//
//  FrameView.swift
//  Hogwars
//
//  Created by Karis on 16/8/25.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Frame")
    
    var body: some View {
        if let image = image {
            // scale is zoom
            Image(image, scale: 1.0, orientation: .up, label: label)
        } else {
            Color.black
                .ignoresSafeArea()
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
