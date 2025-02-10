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

    let content: AttributedString
    let direction: Direction
    let image: Image?
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack {
            if direction == .outgoing { Spacer() }
            VStack(alignment: .leading, spacing: 5) {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }

                Text(content) // Directly use AttributedString
                    .padding(10)
                    .background(bubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.messageCornerRadius))
            }
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

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

#Preview {
    ChatBubble(content: "Example", direction: .incoming, image: nil)
        .environmentObject(ThemeManager.shared)
}
