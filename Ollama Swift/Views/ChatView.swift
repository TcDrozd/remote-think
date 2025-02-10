//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import MarkdownUI
import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject var chatController = ChatController()
    
    @FocusState private var promptFieldIsFocused: Bool
    @Namespace var bottomId
    
    private var chatMessages: some View {
        ScrollViewReader { sv in
            ScrollView {
                LazyVStack {
                    ForEach(Array(chatController.sentPrompt.enumerated()), id: \.offset) { idx, sent in
                        messageBubble(idx: idx, sent: sent)
                    }
                    Text("") // Anchor to scroll to
                        .id(bottomId)
                }
                .padding(.bottom, 10)
            }
            .onChange(of: chatController.receivedResponse) { _ in
                // Trigger scroll to bottom after a delay to allow the UI to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        sv.scrollTo(bottomId, anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func messageBubble(idx: Int, sent: String) -> some View {
        VStack(spacing: 0) {
            ChatBubble(
                content: parseMessage(sent),
                direction: .outgoing,
                image: chatController.sentImages[idx]
            )
            
            if chatController.receivedResponse.indices.contains(idx) {
                ChatBubble(
                    content: parseMessage(chatController.receivedResponse[idx]),
                    direction: .incoming,
                    image: nil
                )
            }
        }
        .padding(.horizontal, 10)
    }
    
    func parseMessage(_ message: String) -> AttributedString {
        var attributedString = AttributedString("")
        var isThinking = false
        
        let parts = message.split(separator: "<", omittingEmptySubsequences: false)
        
        for part in parts {
            if part.hasPrefix("think>") {
                isThinking = true
                let text = part.dropFirst(6)
                var formattedText = AttributedString(String(text))
                formattedText.foregroundColor = .gray
                var container = AttributeContainer()
                container.inlinePresentationIntent = .emphasized
                formattedText.mergeAttributes(container)
                attributedString.append(formattedText)
            } else if part.hasPrefix("/think>") {
                isThinking = false
                let text = part.dropFirst(7)
                attributedString.append(AttributedString(String(text)))
            } else {
                var formattedText = AttributedString(String(part))
                if isThinking {
                    formattedText.foregroundColor = .gray
                    var container = AttributeContainer()
                    container.inlinePresentationIntent = .emphasized
                    formattedText.mergeAttributes(container)
                }
                attributedString.append(formattedText)
            }
        }
        return attributedString
    }
    
    private var inputControls: some View {
        VStack {
            // Photo/image controls
            HStack {
                Text("Make sure to use a multimodal model...")
                Spacer()
                if !chatController.photoPath.isEmpty {
                    Button("Remove photo") {
                        chatController.photoPath = ""
                        chatController.photoImage = nil
                    }
                }
                Button("Select photo") {
                    // Photo selection logic
                }
            }
            .padding(.horizontal)
            
            // Text input area
            HStack {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $chatController.prompt.prompt)
                        .focused(self.$promptFieldIsFocused)
                    
                    if chatController.prompt.prompt.isEmpty {
                        Text("CMD + Enter prompt...")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
                
                // Action buttons
                VStack {
                    Button {
                        withAnimation { chatController.expandOptions.toggle() }
                    } label: {
                        Image(systemName: chatController.expandOptions ? "arrow.down" : "arrow.up")
                    }
                    
                    Button {
                        chatController.send()
                    } label: {
                        Image(systemName: "paperplane")
                    }
                    .disabled(chatController.disabledButton)
                    
                    Button {
                        chatController.resetChat()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .keyboardShortcut(.return, modifiers: [.command])  // On send button
                .keyboardShortcut("r", modifiers: [.command])       // On refresh button

            }
            .padding()
        }
        .background(.ultraThickMaterial)
    }
    

    var body: some View {
            VStack(spacing: 0) {
                chatMessages
                inputControls
            }
            .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
            .background(Color(NSColor.controlBackgroundColor))
            .task {
                chatController.getTags()
            }
            .toolbar {
                // Model selector and primary controls
                ToolbarItemGroup(placement: .automatic) {
                    HStack {
                        Picker("Model:", selection: $chatController.prompt.model) {
                            ForEach(chatController.tags?.models ?? [], id: \.self) { model in
                                Text(model.name).tag(model.name)
                            }
                        }
                        NavigationLink {
                            ManageModelsView()
                        } label: {
                            Label("Manage Models", systemImage: "gearshape")
                        }
                    }
                }
                
                // Error status on trailing side
                ToolbarItem(placement: .automatic) {
                    HStack {
                        if chatController.errorModel.showError {
                            Button {
                                chatController.showingErrorPopover.toggle()
                            } label: {
                                Label("Error", systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.red)
                            }
                        } else {
                            Text("Server:")
                            Label("Connected", systemImage: "circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                
                // Refresh button
                ToolbarItem(placement: .automatic) {
                    Button {
                        chatController.getTags()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .keyboardShortcut("r", modifiers: [.command])
                }
            }

    }
}

#Preview {
    ChatView()
}
