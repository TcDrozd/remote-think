//
//  SettingsWindow.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/10/25.
//
import SwiftUI

struct SettingsWindow: Scene {
    var body: some Scene {
        Window("Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 400, minHeight: 300)
        }
        .windowResizability(.contentSize)
    }
}
