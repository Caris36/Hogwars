//
//  OpeanableBookView.swift
//  Hogwars
//
//  Created by Eugene Tan on 2/8/25.
//

import SwiftUI

//interactive book card view
struct OpenableBookView<Front: View, InsideLeft: View, InsideRight: View>:View, Animatable {
    var config: Config = .init()
    @ViewBuilder var front: (CGSize) -> Front
    @ViewBuilder var insideLeft: (CGSize) -> InsideLeft
    @ViewBuilder var insideRight: (CGSize) -> InsideRight
    
    var animatableData: CGFloat {
        get {return config.progress}
        set {config.progress = newValue}
    }
    var body: some View {
        GeometryReader {
            let size = $0.size
            let progress = max(min(config.progress, 1), 0)
            let rotation = progress * -180
            let cornerRadius = config.cornerRadius
            let shadowColor = config.shadowColor
            ZStack {
                insideRight(size)
                    .frame(width: size.width, height: size.height)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: cornerRadius,
                            topTrailingRadius: cornerRadius
                        )
                    )
                    .shadow(color: shadowColor.opacity(0.1 * progress), radius: 5, x: 5, y: 0)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(config.dividerBackground.shadow(.inner(color: shadowColor.opacity(0.15), radius : 2)))
                            .frame(width: 6)
                            .offset(x: -3)
                            .clipped()
                    }
                front(size)
                    .frame(width: size.width, height: size.height)
                    .allowsHitTesting(-rotation < 90)
                    .overlay {
                        if -rotation > 90 {
                            insideLeft(size)
                                .frame(width: size.width, height: size.height)
                                .scaleEffect(x: -1)
                                .transition(.identity)
                        }
                    }
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: cornerRadius,
                            topTrailingRadius: cornerRadius
                        )
                    ).shadow(color: shadowColor.opacity(0.1), radius: 5, x: 5, y: 0)
                    .rotation3DEffect(
                    .init(degrees: rotation),
                    axis: (x: 0.0, y: 1.0, z: 0.0),
                    anchor: .leading,
                    perspective: 0.3
                )
            }
            .offset(x: (config.width / 2) * progress)
        }
        .frame(width: config.width, height: config.height)
    }
    //configuration
    struct Config {
        var width: CGFloat = 150
        var height: CGFloat = 200
        var progress: CGFloat = 0
        var cornerRadius: CGFloat = 10
        var shadowColor: Color = .black
        var dividerBackground: Color = .white
    }
}


#Preview {
    PracticeView()
}

