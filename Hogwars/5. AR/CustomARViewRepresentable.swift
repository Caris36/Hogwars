//
//  CustomARViewRepresentable.swift
//  Hogwars
//
//  Created by Eugene Tan on 23/8/25.
//

import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView()
    }
    func updateUIView(_ uiView: CustomARView, context: Context) {
        
    }
}
