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
                    NavigationLink {
                        ChatView(conversation: conversation)
                    } label: {
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
            .toolbar {
                Button(action: createNewConversation) {
                    Label("New Chat", systemImage: "plus")
                }
            }
            .navigationTitle("Chat History")
        } detail: {
            Text("Select a conversation")
        }
    }
    
    private func createNewConversation() {
        let newConversation = Conversation(title: "New Chat", timestamp: Date())
        modelContext.insert(newConversation)
        selectedConversation = newConversation
    }
}
