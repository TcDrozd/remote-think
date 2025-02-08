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
    
    
    var body: some View {
        VStack(spacing: 0)
        {
            ScrollViewReader{ sv in
                ScrollView {
                    Text(verbatim: "This is the start of your chat")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                    ForEach(Array(chatController.sentPrompt.enumerated()), id: \.offset) { idx, sent in
                        ChatBubble(
                            content: sent.trimmingCharacters(in: .whitespacesAndNewlines),
                            direction: .outgoing,
                            image: chatController.sentImages[idx]
                        )
                        .padding(.all, 10)
                        
                        ChatBubble(
                            content: chatController.receivedResponse.indices.contains(idx) ?
                            chatController.receivedResponse[idx].trimmingCharacters(in: .whitespacesAndNewlines) : "...",
                            direction: .incoming,
                            image: nil
                        )
                        .padding(.all, 10)
                    }
                    .animation(.spring(), value: chatController.sentPrompt)
                    Text("")
                        .id(bottomId)
                }
                .scrollIndicators(.visible) // macOS 13+
                .scrollContentBackground(.hidden)
                .onChange(of: chatController.receivedResponse) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            sv.scrollTo(bottomId, anchor: .bottom)
                        }
                    }
                }
            }
            VStack{
                VStack{
                    TextField("Enter system prompt...", text: $chatController.prompt.system, axis: .vertical)
                        .lineLimit(3)
                        .disabled(chatController.disabledEditor)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    chatController.photoImage?
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 300)
                    HStack{
                        Text("Make sure to use a multimodal model such as llava when using images")
                        Spacer()
                        if(chatController.photoPath != ""){
                            Button("Remove photo"){
                                chatController.photoPath = ""
                                chatController.photoImage = nil
                            }
                        }
                        Button("Select photo"){
                            let dialog = NSOpenPanel()
                            
                            dialog.title = "Choose an image"
                            dialog.showsResizeIndicator = true
                            dialog.showsHiddenFiles = false
                            dialog.allowsMultipleSelection = false
                            dialog.canChooseDirectories = false
                            dialog.allowedContentTypes = [.png, .jpeg]
                            
                            if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                                let result = dialog.url // Pathname of the file
                                
                                if (result != nil) {
                                    let path: String = result!.path
                                    chatController.photoPath = path
                                    // path contains the file path e.g
                                }
                                
                            } else {
                                // User clicked on "Cancel"
                                return
                            }
                        }
                    }
                }
                .onChange(of: chatController.photoPath) {
                    Task {
                        if let loaded =
                            NSImage(contentsOf: URL(filePath: chatController.photoPath)) {
                            chatController.photoBase64 = loaded.base64String() ?? ""
                            chatController.photoImage = Image(nsImage: loaded)
                        } else {
                            print("Failed")
                        }
                    }
                }
                .frame(height: chatController.expandOptions ? nil : 0)
                .clipped()
                HStack(){
                    ZStack(alignment: .topLeading) {
                        if chatController.prompt.prompt.isEmpty {
                            Text("CMD + Enter prompt...")
                                .foregroundColor(Color.gray)
                                .padding(.leading, 10)
                        }
                        TextEditor(text: $chatController.prompt.prompt)
                            .padding(.leading, 5)
                            .frame(minHeight: 50, maxHeight: 200)
                            .foregroundColor(.primary)
                            .dynamicTypeSize(.medium ... .xxLarge)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(chatController.prompt.prompt.isEmpty ? 0.75 : 1)
                            .onChange(of: chatController.prompt.prompt) { newValue, _ in
                                chatController.disabledButton = chatController.prompt.prompt.isEmpty
                            }
                            .focused(self.$promptFieldIsFocused)
                            .disabled(chatController.disabledEditor)
                    }
                    .frame(minHeight: 50)
                    
                    VStack{
                        Button{
                            withAnimation {
                                chatController.expandOptions.toggle()
                            }
                        } label: {
                            if(!chatController.expandOptions){
                                Text("More Options")
                                Image(systemName: "arrow.up")
                                    .frame(width: 20, height: 20, alignment: .center)
                            }else{
                                Text("Hide Options")
                                Image(systemName: "arrow.down")
                                    .frame(width: 20, height: 20, alignment: .center)
                            }
                        }
                        HStack{
                            Button {
                                chatController.send()
                            } label: {
                                Image(systemName: "paperplane")
                                    .frame(width: 40, height: 20, alignment: .center)
                            }
                            .disabled(chatController.disabledButton)
                            .keyboardShortcut(.return, modifiers: [.command])
                            
                            Button {
                                chatController.resetChat()
                            } label: {
                                Image(systemName: "trash")
                                    .frame(width: 40, height: 20, alignment: .center)
                            }
                        }
                    }
                }
            }
            .padding(6)
            .background(.ultraThickMaterial)
        }
        .frame(minWidth: 400, idealWidth: 700, minHeight: 600, idealHeight: 800)
        .background(Color(NSColor.controlBackgroundColor))
        .task {
            chatController.getTags()
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic){
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
                if chatController.errorModel.showError {
                    Button {
                        chatController.showingErrorPopover.toggle()
                    } label: {
                        Label("Error", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                    .popover(isPresented: $chatController.showingErrorPopover) {
                        VStack(alignment: .leading) {
                            Text(chatController.errorModel.errorTitle)
                                .font(.title2)
                                .textSelection(.enabled)
                            Text(chatController.errorModel.errorMessage)
                                .textSelection(.enabled)
                        }
                        .padding()
                    }
                    
                } else {
                    Text("Server:")
                    Label("Connected", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                }
                Button {
                    chatController.getTags()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 20, height: 20, alignment: .center)
                }
                .keyboardShortcut("r", modifiers: [.command])

            }
        }
    }
}

#Preview {
    ChatView()
}
