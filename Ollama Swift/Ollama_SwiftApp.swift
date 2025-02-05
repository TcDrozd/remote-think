//
//  Ollama_SwiftApp.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 07.10.23.
//

import SwiftUI

@main
struct Ollama_SwiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ThemeManager.shared)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowStyle(.titleBar)
        
        #if os(macOS)
        Settings {
            SettingsView()
                .frame(width: 550, height: 130)
        }
        .windowToolbarStyle(.unified(showsTitle: false))
        .windowStyle(.titleBar)
        #endif
    }
}
