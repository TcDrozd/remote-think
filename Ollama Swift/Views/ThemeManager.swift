//
//  ThemeManager.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/5/25.
//
import SwiftUI
import MarkdownUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var messageCornerRadius: CGFloat = 18
    @Published var receivedMessageBackground = Color.gray.opacity(0.2)
    @Published var sentMessageBackground = Color.blue
    @Published var accentColor = Color.blue
    
    func markdownStyle(for direction: ChatBubble.Direction) -> Theme {
        switch direction {
        case .incoming:
            return Theme()
                .text {
                    ForegroundColor(.primary)
                    FontSize(16)
                }
                .code {
                    FontFamily(.custom("Menlo"))
                    BackgroundColor(.gray.opacity(0.2))
                }
                
        case .outgoing:
            return Theme()
                .text {
                    ForegroundColor(.white)
                    FontSize(16)
                }
                .code {
                    FontFamily(.custom("Menlo"))
                    BackgroundColor(.white.opacity(0.2))
                }
        }
    }
}
