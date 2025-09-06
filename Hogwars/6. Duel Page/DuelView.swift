//
//  DuelView.swift
//  Hogwars
//
//  Created by Karis on 19/7/25.
//

import SwiftUI

struct DuelView: View {
    var body: some View {
        NavigationStack() {
            VStack {
                ARViewContainer().edgesIgnoringSafeArea(.all)
                
            }
        }
    }
}

#Preview {
    DuelView()
}
