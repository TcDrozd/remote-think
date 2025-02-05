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
                
                Markdown(content)
                    .markdownStyle(theme.markdownStyle(for: direction))
                    .textSelection(.enabled)
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
}
