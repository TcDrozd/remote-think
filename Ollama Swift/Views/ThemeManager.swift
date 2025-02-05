//
//  ThemeManager.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/5/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    // MARK: - Message Styling
    @Published var sentMessageBackground = Color.blue
    @Published var receivedMessageBackground = Color(NSColor.secondarySystemFill)
    @Published var messageCornerRadius: CGFloat = 18
    @Published var accentColor = Color.blue
    
    // MARK: - Markdown Styling
    func markdownStyle(for direction: ChatBubble.Direction) -> MarkdownStyle {
        switch direction {
        case .outgoing:
            return MarkdownStyle(
                text: .white,
                code: .white.opacity(0.8),
                codeBlockBackground: Color.white.opacity(0.1)
            )
        case .incoming:
            return MarkdownStyle(
                text: .primary,
                code: .secondary,
                codeBlockBackground: Color.gray.opacity(0.1)
            )
        }
    }
}

struct MarkdownStyle {
    let text: Color
    let code: Color
    let codeBlockBackground: Color
}
