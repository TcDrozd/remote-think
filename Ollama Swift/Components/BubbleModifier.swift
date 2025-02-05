//
//  BubbleModifier.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/5/25.
//
import SwiftUI


struct BubbleModifier: ViewModifier {
    @EnvironmentObject var theme: ThemeManager
    let direction: ChatBubble.Direction
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: theme.messageCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: theme.messageCornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
    
    private var background: Color {
        direction == .outgoing ?
        theme.sentMessageBackground :
        theme.receivedMessageBackground
    }
    
    private var borderColor: Color {
        direction == .outgoing ?
        theme.accentColor :
        Color.gray.opacity(0.4)
    }
}
