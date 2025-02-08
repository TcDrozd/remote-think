//
//  ChatBubble.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/5/25.
//

import SwiftUI
import MarkdownUI

struct ChatBubble: View {
    enum Direction {
        case incoming
        case outgoing
    }

    let content: String
    let direction: Direction
    let image: Image?

    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack {
            if direction == .outgoing { Spacer() }

            VStack(alignment: .leading) {
                image?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                let (thinkingText, responseText) = formatThinkingText(content)

                VStack(alignment: .leading) {
                    if !thinkingText.isEmpty {
                        Text(thinkingText)
                            .foregroundColor(.gray)
                            .italic()
                            .padding(10)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if !responseText.isEmpty {
                        Markdown(responseText)
                            .markdownTheme(theme.markdownStyle(for: direction))
                            .padding(10)
                            .textSelection(.enabled)
                            .background(direction == .incoming ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Button(action: {
                                    copyToClipboard(responseText)
                                }) {
                                    Image(systemName: "doc.on.doc") // 📄 Copy icon
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(PlainButtonStyle()) // Remove button styling
                                .padding(.trailing, 8)
                    }
                }
            }
            .padding()
            .background(bubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.messageCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: theme.messageCornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )

            if direction == .incoming { Spacer() }
        }
    }

    private var bubbleBackground: some View {
        Group {
            switch direction {
            case .incoming:
                theme.receivedMessageBackground
            case .outgoing:
                theme.sentMessageBackground
            }
        }
    }

    private var borderColor: Color {
        direction == .outgoing ? theme.accentColor : Color.gray.opacity(0.4)
    }

    private func formatThinkingText(_ text: String) -> (thinking: String, response: String) {
        let pattern = "<think>(.*?)</think>(.*)" // Capture what's inside <think> and after it
        let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        
        if let match = regex?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
            let thinkingRange = Range(match.range(at: 1), in: text) // Inside <think>...</think>
            let responseRange = Range(match.range(at: 2), in: text) // Everything after </think>

            let thinking = thinkingRange.map { String(text[$0]) } ?? ""
            let response = responseRange.map { String(text[$0]) } ?? text // If no match, return full text

            return (thinking, response)
        }
        
        return ("", text) // No <think> tags found, return entire text as response
    }
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
