//
//  HogwarsApp.swift
//  Hogwars
//
//  Created by Karis on 19/7/25.
//

import SwiftUI

@main
struct HogwarsApp: App {
    // If you need AppDelegate (e.g. push notifications), keep it
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
