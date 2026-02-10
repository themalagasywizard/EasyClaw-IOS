//
//  AgentRuntime.swift
//  OpenClaw
//

import Foundation
import SwiftData

@Observable
@MainActor
class AgentRuntime {
    enum State {
        case idle
        case running
        case thinking
        case error(Error)
    }
    
    private(set) var state: State = .idle
    private(set) var currentConversation: Conversation?
    
    private let modelContext: ModelContext
    private let llm: LLMService
    private let tools: ToolRegistry
    private let memory: MemoryService
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.llm = LLMService()
        self.tools = ToolRegistry()
        self.memory = MemoryService(modelContext: modelContext)
    }
    
    func initialize() async {
        state = .running
        
        // Register default tools
        await registerDefaultTools()
        
        // Load or create conversation
        await loadOrCreateConversation()
    }
    
    func sendMessage(_ text: String) async {
        guard let conversation = currentConversation else {
            print("No active conversation")
            return
        }
        
        state = .thinking
        
        // Create user message
        let userMessage = Message(role: .user, content: text)
        conversation.addMessage(userMessage)
        try? modelContext.save()
        
        // Build message history for LLM
        let llmMessages = await buildLLMMessages(from: conversation)
        
        // Get tool definitions
        let llmTools = await tools.getLLMToolDefinitions()
        
        // Stream response
        var accumulatedContent = ""
        var pendingToolCalls: [ToolCall] = []
        
        do {
            let stream = await llm.chat(
                messages: llmMessages,
                model: AppSettings.shared.selectedModel,
                tools: llmTools,
                temperature: AppSettings.shared.temperature,
                maxTokens: AppSettings.shared.maxTokens,
                stream: true
            )
            
            for try await event in stream {
                switch event {
                case .delta(let content):
                    accumulatedContent += content
                    
                case .toolCall(let toolCall):
                    pendingToolCalls.append(toolCall)
                    
                case .done:
                    // Save assistant message
                    let assistantMessage = Message(
                        role: .assistant,
                        content: accumulatedContent,
                        toolCalls: pendingToolCalls.isEmpty ? nil : pendingToolCalls
                    )
                    conversation.addMessage(assistantMessage)
                    try? modelContext.save()
                    
                    // Execute tool calls if any
                    if !pendingToolCalls.isEmpty {
                        await executeToolCalls(pendingToolCalls, in: conversation)
                    }
                    
                case .error(let error):
                    state = .error(error)
                    print("LLM error: \(error)")
                }
            }
            
            state = .running
            
        } catch {
            state = .error(error)
            print("Stream error: \(error)")
        }
    }
    
    func startNewConversation() {
        let newConversation = Conversation(
            model: AppSettings.shared.selectedModel,
            systemPrompt: AppSettings.shared.systemPrompt.isEmpty ? nil : AppSettings.shared.systemPrompt
        )
        modelContext.insert(newConversation)
        currentConversation = newConversation
        try? modelContext.save()
    }
    
    // MARK: - Private Methods
    
    private func loadOrCreateConversation() async {
        let descriptor = FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        if let conversations = try? modelContext.fetch(descriptor),
           let latest = conversations.first {
            currentConversation = latest
        } else {
            startNewConversation()
        }
    }
    
    private func buildLLMMessages(from conversation: Conversation) async -> [LLMMessage] {
        var messages: [LLMMessage] = []
        
        // Add system prompt if present
        if let systemPrompt = conversation.systemPrompt {
            messages.append(LLMMessage(role: "system", content: systemPrompt, name: nil, toolCallId: nil))
        }
        
        // Add conversation messages (limit to last N for context window)
        let recentMessages = Array(conversation.messages.suffix(AppSettings.shared.maxConversationHistory))
        
        for message in recentMessages {
            messages.append(LLMMessage(
                role: message.role.rawValue,
                content: message.content,
                name: nil,
                toolCallId: nil
            ))
            
            // Add tool results if present
            if let toolResults = message.toolResults {
                for result in toolResults {
                    messages.append(LLMMessage(
                        role: "tool",
                        content: result.content,
                        name: nil,
                        toolCallId: result.toolCallId
                    ))
                }
            }
        }
        
        return messages
    }
    
    private func executeToolCalls(_ toolCalls: [ToolCall], in conversation: Conversation) async {
        var results: [ToolResult] = []
        
        for toolCall in toolCalls {
            do {
                let result = try await tools.execute(
                    name: toolCall.name,
                    arguments: toolCall.decodedArguments ?? [:]
                )
                
                results.append(ToolResult(
                    id: UUID().uuidString,
                    toolCallId: toolCall.id,
                    content: result,
                    error: nil
                ))
            } catch {
                results.append(ToolResult(
                    id: UUID().uuidString,
                    toolCallId: toolCall.id,
                    content: "",
                    error: error.localizedDescription
                ))
            }
        }
        
        // Create a tool message with results
        let toolMessage = Message(
            role: .tool,
            content: "", // Content is in toolResults
            toolResults: results
        )
        conversation.addMessage(toolMessage)
        try? modelContext.save()
        
        // Continue conversation with tool results
        await continueAfterTools(in: conversation)
    }
    
    private func continueAfterTools(in conversation: Conversation) async {
        // Build messages including tool results
        let llmMessages = await buildLLMMessages(from: conversation)
        let llmTools = await tools.getLLMToolDefinitions()
        
        var accumulatedContent = ""
        
        do {
            let stream = await llm.chat(
                messages: llmMessages,
                model: conversation.model,
                tools: llmTools,
                stream: true
            )
            
            for try await event in stream {
                switch event {
                case .delta(let content):
                    accumulatedContent += content
                case .done:
                    let assistantMessage = Message(role: .assistant, content: accumulatedContent)
                    conversation.addMessage(assistantMessage)
                    try? modelContext.save()
                case .toolCall, .error:
                    break // Handle if needed
                }
            }
        } catch {
            print("Continue after tools error: \(error)")
        }
    }
    
    private func registerDefaultTools() async {
        // Memory tools
        await tools.register(MemorySearchTool(memory: memory))
        await tools.register(MemoryGetTool(memory: memory))
        
        // Web tools
        await tools.register(WebSearchTool())
        await tools.register(WebFetchTool())
        
        // TODO: Messaging tools
        // await tools.register(iMessageTool())
        // await tools.register(TelegramTool())
    }
}
