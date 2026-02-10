//
//  MemoryService.swift
//  OpenClaw
//

import Foundation
import SwiftData

actor MemoryService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Search
    
    func search(query: String, limit: Int = 10) async throws -> [MemoryEntry] {
        // TODO: Implement semantic search with embeddings
        // For now, do simple text search
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.content.localizedStandardContains(query)
            },
            sortBy: [
                SortDescriptor(\.importance, order: .reverse),
                SortDescriptor(\.updatedAt, order: .reverse)
            ]
        )
        
        let results = try modelContext.fetch(descriptor)
        return Array(results.prefix(limit))
    }
    
    func searchByTag(_ tag: String, limit: Int = 10) async throws -> [MemoryEntry] {
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.tags.contains(tag)
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        let results = try modelContext.fetch(descriptor)
        return Array(results.prefix(limit))
    }
    
    func searchByCategory(_ category: MemoryCategory, limit: Int = 20) async throws -> [MemoryEntry] {
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.category == category
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        let results = try modelContext.fetch(descriptor)
        return Array(results.prefix(limit))
    }
    
    // MARK: - CRUD
    
    func save(_ entry: MemoryEntry) async throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
    
    func get(id: UUID) async throws -> MemoryEntry? {
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func update(_ entry: MemoryEntry, content: String? = nil, tags: [String]? = nil) async throws {
        if let content = content {
            entry.content = content
        }
        if let tags = tags {
            entry.tags = tags
        }
        entry.updatedAt = Date()
        try modelContext.save()
    }
    
    func delete(_ entry: MemoryEntry) async throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    // MARK: - Daily Logs
    
    func exportDailyLog(for date: Date = Date()) async throws -> String {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<MemoryEntry>(
            predicate: #Predicate { entry in
                entry.createdAt >= startOfDay && entry.createdAt < endOfDay
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        let entries = try modelContext.fetch(descriptor)
        
        // Format as markdown
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        var markdown = "# Daily Log: \(dateString)\n\n"
        
        for entry in entries {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let time = timeFormatter.string(from: entry.createdAt)
            
            markdown += "## \(time) - \(entry.category.rawValue)\n"
            markdown += "\(entry.content)\n"
            if !entry.tags.isEmpty {
                markdown += "_Tags: \(entry.tags.joined(separator: ", "))_\n"
            }
            markdown += "\n"
        }
        
        return markdown
    }
    
    func importFromMarkdown(_ markdown: String) async throws {
        // TODO: Parse markdown and create memory entries
        // This would support importing from desktop OpenClaw
    }
    
    // MARK: - Embeddings (TODO)
    
    func generateEmbedding(for text: String) async throws -> [Float] {
        // TODO: Call embedding API (OpenAI, Voyage, etc.)
        // For MVP, we'll skip this and use text search
        return []
    }
    
    func semanticSearch(embedding: [Float], limit: Int = 10) async throws -> [MemoryEntry] {
        // TODO: Implement cosine similarity search
        // Requires storing embeddings and computing distances
        return []
    }
}

// MARK: - Memory Tools

struct MemorySearchTool: Tool {
    let name = "memory_search"
    let description = "Search through saved memories using keywords or phrases. Returns relevant past information."
    
    private let memory: MemoryService
    
    init(memory: MemoryService) {
        self.memory = memory
    }
    
    var parameters: [String: Any] {
        buildParameters(
            properties: [
                "query": stringProperty(description: "Search query to find relevant memories"),
                "limit": numberProperty(description: "Maximum number of results (default: 10)")
            ],
            required: ["query"]
        )
    }
    
    func execute(arguments: [String: Any]) async throws -> String {
        guard let query = arguments["query"] as? String else {
            throw ToolError.invalidArguments("Missing 'query' parameter")
        }
        
        let limit = arguments["limit"] as? Int ?? 10
        let results = try await memory.search(query: query, limit: limit)
        
        if results.isEmpty {
            return "No memories found matching '\(query)'"
        }
        
        var output = "Found \(results.count) memories:\n\n"
        for (index, entry) in results.enumerated() {
            output += "\(index + 1). [\(entry.category.rawValue)] \(entry.content)\n"
            if !entry.tags.isEmpty {
                output += "   Tags: \(entry.tags.joined(separator: ", "))\n"
            }
            output += "\n"
        }
        
        return output
    }
}

struct MemoryGetTool: Tool {
    let name = "memory_get"
    let description = "Retrieve specific memories by category or tag"
    
    private let memory: MemoryService
    
    init(memory: MemoryService) {
        self.memory = memory
    }
    
    var parameters: [String: Any] {
        buildParameters(
            properties: [
                "category": stringProperty(description: "Memory category: general, personal, work, project, decision, lesson, todo, fact"),
                "tag": stringProperty(description: "Filter by specific tag"),
                "limit": numberProperty(description: "Maximum results (default: 10)")
            ]
        )
    }
    
    func execute(arguments: [String: Any]) async throws -> String {
        let limit = arguments["limit"] as? Int ?? 10
        
        var results: [MemoryEntry] = []
        
        if let categoryStr = arguments["category"] as? String,
           let category = MemoryCategory(rawValue: categoryStr.capitalized) {
            results = try await memory.searchByCategory(category, limit: limit)
        } else if let tag = arguments["tag"] as? String {
            results = try await memory.searchByTag(tag, limit: limit)
        } else {
            throw ToolError.invalidArguments("Must provide either 'category' or 'tag'")
        }
        
        if results.isEmpty {
            return "No memories found with the specified criteria"
        }
        
        var output = "Found \(results.count) memories:\n\n"
        for (index, entry) in results.enumerated() {
            output += "\(index + 1). \(entry.content)\n\n"
        }
        
        return output
    }
}
