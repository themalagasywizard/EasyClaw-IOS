//
//  LogsView.swift
//  OpenClaw
//

import SwiftUI
import SwiftData

struct LogsView: View {
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]
    @Query(sort: \MemoryEntry.createdAt, order: .reverse) private var memories: [MemoryEntry]
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("View", selection: $selectedTab) {
                    Text("Conversations").tag(0)
                    Text("Memories").tag(1)
                    Text("System").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    ConversationsLog(conversations: conversations)
                        .tag(0)
                    
                    MemoriesLog(memories: memories)
                        .tag(1)
                    
                    SystemLog()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Logs")
        }
    }
}

struct ConversationsLog: View {
    let conversations: [Conversation]
    
    var body: some View {
        List {
            ForEach(conversations) { conversation in
                NavigationLink {
                    ConversationDetail(conversation: conversation)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(conversation.title ?? "Untitled Conversation")
                            .font(.headline)
                        
                        HStack {
                            Text("\(conversation.messageCount) messages")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if let lastMessage = conversation.lastMessageDate {
                                Text(lastMessage, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct ConversationDetail: View {
    let conversation: Conversation
    
    var body: some View {
        List {
            Section("Metadata") {
                LabeledContent("Model", value: conversation.model)
                LabeledContent("Created", value: conversation.createdAt, format: .dateTime)
                LabeledContent("Updated", value: conversation.updatedAt, format: .dateTime)
                LabeledContent("Messages", value: "\(conversation.messageCount)")
            }
            
            if let systemPrompt = conversation.systemPrompt {
                Section("System Prompt") {
                    Text(systemPrompt)
                        .font(.caption)
                }
            }
            
            Section("Messages") {
                ForEach(conversation.messages) { message in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(message.role.rawValue.capitalized)
                                .font(.caption)
                                .bold()
                            Spacer()
                            if let timestamp = message.timestamp {
                                Text(timestamp, format: .dateTime)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text(message.content)
                            .font(.system(.body, design: .monospaced))
                        
                        if let toolCalls = message.toolCalls, !toolCalls.isEmpty {
                            ForEach(toolCalls) { toolCall in
                                Label {
                                    Text("Tool: \(toolCall.name)")
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: "wrench.and.screwdriver")
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        
                        if let toolResults = message.toolResults, !toolResults.isEmpty {
                            ForEach(toolResults) { result in
                                Label {
                                    Text(result.isError ? "Error: \(result.error ?? "Unknown")" : "Success")
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: result.isError ? "xmark.circle" : "checkmark.circle")
                                }
                                .foregroundStyle(result.isError ? .red : .green)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(conversation.title ?? "Conversation")
    }
}

struct MemoriesLog: View {
    let memories: [MemoryEntry]
    @State private var selectedCategory: MemoryCategory? = nil
    
    var filteredMemories: [MemoryEntry] {
        if let category = selectedCategory {
            return memories.filter { $0.category == category }
        }
        return memories
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button(selectedCategory == nil ? "All ✓" : "All") {
                        selectedCategory = nil
                    }
                    .buttonStyle(.bordered)
                    
                    ForEach(MemoryCategory.allCases, id: \.self) { category in
                        Button(selectedCategory == category ? "\(category.rawValue) ✓" : category.rawValue) {
                            selectedCategory = category
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            }
            
            List {
                ForEach(filteredMemories) { memory in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(memory.category.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(categoryColor(memory.category).opacity(0.2))
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            Text(memory.createdAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(memory.content)
                            .font(.body)
                        
                        if !memory.tags.isEmpty {
                            HStack {
                                ForEach(memory.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        HStack {
                            ForEach(0..<memory.importance, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func categoryColor(_ category: MemoryCategory) -> Color {
        switch category {
        case .general: return .gray
        case .personal: return .blue
        case .work: return .orange
        case .project: return .purple
        case .decision: return .green
        case .lesson: return .red
        case .todo: return .yellow
        case .fact: return .cyan
        }
    }
}

struct SystemLog: View {
    @State private var logs: [String] = [
        "System initialized",
        "Agent runtime started",
        "LLM service connected",
        "Tool registry ready"
    ]
    
    var body: some View {
        List {
            ForEach(logs.reversed(), id: \.self) { log in
                Text(log)
                    .font(.system(.caption, design: .monospaced))
            }
        }
    }
}

#Preview {
    LogsView()
        .modelContainer(for: [Conversation.self, Message.self, MemoryEntry.self])
}
