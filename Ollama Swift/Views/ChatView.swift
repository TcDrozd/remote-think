//
//  ChatView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 08.10.23.
//

import MarkdownUI
import MarkdownUI
import SwiftUI
import PhotosUI

struct ChatView: View {
    let conversation: Conversation
    @StateObject var chatController = ChatController()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow  // New environment key for windows
    @EnvironmentObject var theme: ThemeManager

    @FocusState private var promptFieldIsFocused: Bool
    @Namespace var bottomId

    var body: some View {
        Text("Conversation ID: \(conversation.id.uuidString)") // ddebugging
        Text("Messages Count: \(conversation.messages.count)")
        
        VStack(spacing: 0) {
            chatMessages
            inputControls
        }
        .task {
            print("ChatView opened for: \(conversation.title)")
            print("Message count: \(conversation.messages.count)")
        }
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .background(Color(NSColor.controlBackgroundColor))
        .task { chatController.getTags() }
        
        .toolbar {
            // Model Picker and Manage Models
            ToolbarItemGroup(placement: .automatic) {
                HStack {
                    Picker("Model:", selection: $chatController.prompt.model) {
                        ForEach(chatController.tags?.models ?? [], id: \.self) { model in
                            Text(model.name).tag(model.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())  // You can adjust the style if needed
                    NavigationLink(destination: ManageModelsView()) {
                        Label("Manage Models", systemImage: "gearshape")
                    }
                }
            }
            
            // Settings Button
            ToolbarItem(placement: .automatic) {
                Button {
                    openWindow(id: "settings")
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            
            // Error Status
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
            
            // Refresh Button
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
        VStack(spacing: 2) {
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
            // Photo/image controls - collapsible
            VStack {
                HStack {
                    Text("Make sure to use a multimodal model such as llava when using images")
                    Spacer()
                    if !chatController.photoPath.isEmpty {
                        Button("Remove photo") {
                            chatController.photoPath = ""
                            chatController.photoImage = nil
                        }
                    }
                    Button("Select photo") {
                        let dialog = NSOpenPanel()
                        dialog.title = "Choose an image"
                        dialog.showsResizeIndicator = true
                        dialog.showsHiddenFiles = false
                        dialog.allowsMultipleSelection = false
                        dialog.canChooseDirectories = false
                        dialog.allowedContentTypes = [.png, .jpeg]
                        if (dialog.runModal() == NSApplication.ModalResponse.OK),
                           let result = dialog.url {
                               chatController.photoPath = result.path
                        }
                    }
                }
                .onChange(of: chatController.photoPath) {
                    Task {
                        if let loaded = NSImage(contentsOf: URL(filePath: chatController.photoPath)) {
                            chatController.photoBase64 = loaded.base64String() ?? ""
                            chatController.photoImage = Image(nsImage: loaded)
                        } else {
                            print("Failed")
                        }
                    }
                }
            }
            .frame(height: chatController.expandOptions ? nil : 0)
            .clipped()
            .padding(.top, 10)
            
            // Text input area
            HStack {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $chatController.prompt.prompt)
                        .padding(.leading, 5)
                        .frame(minHeight: 50, idealHeight: 75, maxHeight: 200)
                        .foregroundColor(.primary)
                        .dynamicTypeSize(.medium ... .xxLarge)
                        .opacity(chatController.prompt.prompt.isEmpty ? 0.75 : 1)
                        .onChange(of: chatController.prompt.prompt) { newValue, _ in
                            chatController.disabledButton = chatController.prompt.prompt.isEmpty
                        }
                        .focused(self.$promptFieldIsFocused)
                        .disabled(chatController.disabledEditor)
                    
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
                    .keyboardShortcut(.return, modifiers: [.command])
                    
                    Button {
                        chatController.resetChat()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .padding()
        }
        .background(.ultraThickMaterial)
    }
}

#Preview {
    let dummyConversation = Conversation(title: "Preview Chat", timestamp: Date())
    ChatView(conversation: dummyConversation)
}
