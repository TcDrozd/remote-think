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
                .modelContainer(for: Conversation.self)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowStyle(.automatic)
        
        #if os(macOS)
        SettingsWindow()
            .environmentObject(ThemeManager.shared)
        #endif
        
    }
}
