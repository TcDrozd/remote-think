//
//  ContentView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var ollamaController = OllamaController()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Chat", destination: ChatView())
                NavigationLink("Settings", destination: SettingsView())
            }
            .listStyle(SidebarListStyle()) // Ensures the list looks like a sidebar
            
            Text("Select an option")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Ollama Swift")
    }
}

#Preview {
    ContentView()
}
