//
//  PracticeView.swift
//  Hogwars
//
//  Created by Karis on 19/7/25.
//

import SwiftUI

struct PracticeView: View {
    
    
        
    @State private var progress: CGFloat = 0
    var body: some View {
        NavigationStack{
            VStack {
                OpenableBookView(config: .init(progress:progress)) { size in
                    FrontView(size)
                }insideLeft: { size in
                    LeftView()
                }insideRight: { size in
                    RightView()
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.15))
        }
       
    }
    // Front view
    @ViewBuilder
    func FrontView(_ size: CGSize) -> some View {
        Button {
            withAnimation(.snappy(duration: 1)) {
                progress = (progress == 1.0 ? 0.2 : 1.0)
            }
        } label: {
            Image(.book1)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
        }
        
    }

    // Left View
    @ViewBuilder
    func LeftView() -> some View {
        VStack {
            Button {
                withAnimation(.snappy(duration: 1)) {
                    progress = (progress == 1.0 ? 0.2 : 1.0)
                }
            } label: {
                Image(.page1)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
    //Right view
    @ViewBuilder
    func RightView() -> some View {
        VStack {
            Button {
                withAnimation(.snappy(duration: 1)) {
                    progress = (progress == 1.0 ? 0.2 : 1.0)
                }
            } label: {
                Image(.page1)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
    

}



#Preview {
    PracticeView()
}
