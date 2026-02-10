//
//  Message.swift
//  OpenClaw
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var role: MessageRole
    var content: String
    var timestamp: Date?
    var toolCalls: [ToolCall]?
    var toolResults: [ToolResult]?
    
    @Relationship(deleteRule: .nullify, inverse: \Conversation.messages)
    var conversation: Conversation?
    
    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date? = Date(),
        toolCalls: [ToolCall]? = nil,
        toolResults: [ToolResult]? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.toolCalls = toolCalls
        self.toolResults = toolResults
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
    case tool
}

struct ToolCall: Codable, Identifiable {
    let id: String
    let name: String
    let arguments: String // JSON string
    
    var decodedArguments: [String: Any]? {
        guard let data = arguments.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
}

struct ToolResult: Codable, Identifiable {
    let id: String // Matches ToolCall.id
    let toolCallId: String
    let content: String
    let error: String?
    
    var isError: Bool { error != nil }
}
