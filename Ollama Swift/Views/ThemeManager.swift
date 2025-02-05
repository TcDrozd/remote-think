//
//  ThemeManager.swift
//  Ollama Swift
//
//  Created by Trevor Drozd on 2/5/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var accentColor = Color.blue
    @Published var messageCornerRadius: CGFloat = 18
    @Published var chatBackground = Color(NSColor.controlBackgroundColor)
    
    static let shared = ThemeManager()
    
    // Add more theme properties as needed
}
