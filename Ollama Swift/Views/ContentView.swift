//
// ContentView.swift
// Ollama Swift
//
// Created by Trevor Drozd on 2025.02.10
//
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var conversations: [Conversation]
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedConversation) {
                ForEach(conversations) { conversation in
                    NavigationLink(destination: ChatView(conversation: conversation)) {
                        VStack(alignment: .leading) {
                            Text(conversation.title)
                                .font(.headline)
                            Text(conversation.lastMessagePreview)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(conversation)
                }
            }
            .navigationDestination(for: Conversation.self) { conversation in
                
                ChatView(conversation: conversation)
            }
        } detail: {
            Text("Select a conversation")
        }
    }
    
    private func createNewConversation() {
        let newConversation = Conversation(title: "New Chat", timestamp: Date())
        modelContext.insert(newConversation)
        
        Task { @MainActor in
            try? modelContext.save()  // Save immediately
            selectedConversation = newConversation
        }
    }
}
