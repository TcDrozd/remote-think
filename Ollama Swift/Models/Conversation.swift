//
//  SavedMessages.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/10/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Conversation: Identifiable {
    @Attribute(.unique) let id = UUID()
    var title: String
    var timestamp: Date
    var messages: [Message] = []
    
    init(title: String, timestamp: Date) {
        self.title = title
        self.timestamp = timestamp
    }
    
    var lastMessagePreview: String {
        if let lastMessage = messages.last {
            return lastMessage.content // Assuming Message has a content property
        } else {
            return "No messages yet"
        }
    }
}

@Model
class Message {
    var content: String
    var timestamp: Date
    var isFromUser: Bool
    @Relationship(deleteRule: .cascade) var conversation: Conversation?
    
    init(content: String, timestamp: Date, isFromUser: Bool) {
        self.content = content
        self.timestamp = timestamp
        self.isFromUser = isFromUser
    }
}
