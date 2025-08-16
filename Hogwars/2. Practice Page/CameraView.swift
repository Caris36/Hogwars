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
        FrameView(image: model.frame)
            .ignoresSafeArea()
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
