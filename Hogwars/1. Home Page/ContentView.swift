//
//  ContentView.swift
//  Hogwars
//
//  Created by Karis on 19/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack()  {
            ZStack {
                Image("Hogwars3")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                VStack {
                    NavigationLink {
                        PracticeView()
                    } label: {
                        Image("Start1")
                            .scaleEffect(0.5)
                            .frame(width: 50, height: 50)
                    }
                }
                VStack{
                    NavigationLink {
                        DuelView()
                    } label: {
                        Image("Duel3")
                            .scaleEffect(0.5)
                            .frame(width: 50, height: 50)
                    } .offset(y: 75)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
