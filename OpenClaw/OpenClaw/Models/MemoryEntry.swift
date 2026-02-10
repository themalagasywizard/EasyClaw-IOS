//
//  MemoryEntry.swift
//  OpenClaw
//

import Foundation
import SwiftData

@Model
final class MemoryEntry {
    var id: UUID
    var content: String
    var category: MemoryCategory
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var embedding: [Float]? // Vector embedding for semantic search
    var source: String? // Where this memory came from
    var importance: Int // 0-10 scale
    
    init(
        id: UUID = UUID(),
        content: String,
        category: MemoryCategory = .general,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        embedding: [Float]? = nil,
        source: String? = nil,
        importance: Int = 5
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.embedding = embedding
        self.source = source
        self.importance = importance
    }
}

enum MemoryCategory: String, Codable, CaseIterable {
    case general = "General"
    case personal = "Personal"
    case work = "Work"
    case project = "Project"
    case decision = "Decision"
    case lesson = "Lesson"
    case todo = "To-Do"
    case fact = "Fact"
}
