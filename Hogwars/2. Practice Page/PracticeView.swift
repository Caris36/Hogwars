//
//  PracticeView.swift
//  Hogwars
//
//  Created by Karis on 19/7/25.
//

import SwiftUI

struct PracticeView: View {
    
    let spells = [
        Spell(name: "Incendio", mastery: 0, description: "a charm that conjures a jet of flames used to ignite objects or substances"),
        
        Spell(name: "Expelliarmus", mastery: 0, description: "a disarming spell that causes an opponent's wand to fly out of their hand effectively disarming them"),
        
        Spell(name: "Riddikulus", mastery: 0, description: "a charm used to defeat Boggarts by making them humorous"),
        
        Spell(name: "Expecto Patronum", mastery: 0, description: "a complex defensive spell used to conjure a magical animal-shaped guardian called a Patronus which acts as a shield against dark creatures"),
        
        Spell(name: "Lumos", mastery: 0, description: "a basic spell that conjures a beam of light at the tip of a wizard's wand"),
        
        Spell(name: "Avada Kedavra", mastery: 0, description: "an unforgivable curse that when successfully cast causes instant painless death, there is no known way to block the curse")
    ]
        
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
                HStack(spacing: 12) {
                    Slider(value: $progress)
                    Button("Toggle"){
                        withAnimation(.snappy(duration: 1)) {
                            progress = (progress == 1.0 ? 0.2 : 1.0)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(10)
                .background(.background, in: .rect(cornerRadius: 10))
                .padding(.top, 50)
            }
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.15))
            .navigationTitle("Book View")
        }
       
    }
    // Front view
    @ViewBuilder
    func FrontView(_ size: CGSize) -> some View {
        Image(.book1)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
        
    }

    // Left View
    @ViewBuilder
    func LeftView() -> some View {
        VStack {
            Image(.page1)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
       
    
    }
    //Right view
    @ViewBuilder
    func RightView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.system(size: 14))
            Text("Sample description")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
    

}



#Preview {
    PracticeView()
}
