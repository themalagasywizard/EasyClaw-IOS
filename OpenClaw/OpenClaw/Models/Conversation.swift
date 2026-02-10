//
//  Conversation.swift
//  OpenClaw
//

import Foundation
import SwiftData

@Model
final class Conversation {
    var id: UUID
    var title: String?
    var createdAt: Date
    var updatedAt: Date
    var model: String
    var systemPrompt: String?
    
    @Relationship(deleteRule: .cascade)
    var messages: [Message]
    
    init(
        id: UUID = UUID(),
        title: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        model: String = "anthropic/claude-sonnet-4-5",
        systemPrompt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
        self.systemPrompt = systemPrompt
        self.messages = []
    }
    
    var messageCount: Int {
        messages.count
    }
    
    var lastMessageDate: Date? {
        messages.last?.timestamp
    }
    
    func addMessage(_ message: Message) {
        messages.append(message)
        message.conversation = self
        updatedAt = Date()
        
        // Auto-generate title from first user message if needed
        if title == nil, message.role == .user {
            title = String(message.content.prefix(50))
        }
    }
}
