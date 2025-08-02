//
//  SpellStruct.swift
//  Hogwars
//
//  Created by Eugene Tan on 2/8/25.
//


import SwiftUI
struct Spell: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var mastery: Int
    var description: String

    static let sampleData = [
        Spell(name: "Sampleio", mastery: 0, description:"It summons a sample")
    ]
}
