//
//  ARTestingView.swift
//  Hogwars
//
//  Created by Eugene Tan on 23/8/25.
//

import SwiftUI

struct ARTestingView: View {
    var body: some View {
        CustomARViewRepresentable()
            .ignoresSafeArea()
    }
}
struct ARTestingView_Previews: PreviewProvider{
    static var previews: some View {
        ARTestingView()
    }
}
