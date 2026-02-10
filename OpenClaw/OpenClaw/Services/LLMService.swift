//
//  LLMService.swift
//  OpenClaw
//

import Foundation

actor LLMService {
    private let baseURL = "https://openrouter.ai/api/v1"
    private var apiKey: String?
    
    enum LLMEvent {
        case delta(String)
        case toolCall(ToolCall)
        case done
        case error(Error)
    }
    
    enum LLMError: LocalizedError {
        case noAPIKey
        case invalidResponse
        case apiError(String)
        case networkError(Error)
        
        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No OpenRouter API key configured"
            case .invalidResponse:
                return "Invalid response from API"
            case .apiError(let message):
                return "API error: \(message)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    init() {
        self.apiKey = KeychainService.shared.retrieve(for: .openRouter)
    }
    
    func updateAPIKey(_ key: String?) {
        self.apiKey = key
    }
    
    func chat(
        messages: [LLMMessage],
        model: String,
        tools: [LLMTool]? = nil,
        temperature: Double = 0.7,
        maxTokens: Int = 4096,
        stream: Bool = true
    ) -> AsyncThrowingStream<LLMEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let apiKey = self.apiKey else {
                        throw LLMError.noAPIKey
                    }
                    
                    var request = URLRequest(url: URL(string: "\(baseURL)/chat/completions")!)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("OpenClaw-iOS/1.0", forHTTPHeaderField: "HTTP-Referer")
                    
                    var body: [String: Any] = [
                        "model": model,
                        "messages": messages.map { $0.toDictionary() },
                        "temperature": temperature,
                        "max_tokens": maxTokens,
                        "stream": stream
                    ]
                    
                    if let tools = tools {
                        body["tools"] = tools.map { $0.toDictionary() }
                    }
                    
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    if stream {
                        try await self.handleStreamingResponse(request: request, continuation: continuation)
                    } else {
                        try await self.handleNonStreamingResponse(request: request, continuation: continuation)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func handleStreamingResponse(
        request: URLRequest,
        continuation: AsyncThrowingStream<LLMEvent, Error>.Continuation
    ) async throws {
        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LLMError.invalidResponse
        }
        
        var buffer = ""
        
        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }
            
            let data = String(line.dropFirst(6))
            if data == "[DONE]" { break }
            
            guard let jsonData = data.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let choice = choices.first,
                  let delta = choice["delta"] as? [String: Any] else {
                continue
            }
            
            // Handle content delta
            if let content = delta["content"] as? String {
                buffer += content
                continuation.yield(.delta(content))
            }
            
            // Handle tool calls
            if let toolCalls = delta["tool_calls"] as? [[String: Any]] {
                for toolCall in toolCalls {
                    if let id = toolCall["id"] as? String,
                       let function = toolCall["function"] as? [String: Any],
                       let name = function["name"] as? String,
                       let arguments = function["arguments"] as? String {
                        continuation.yield(.toolCall(ToolCall(id: id, name: name, arguments: arguments)))
                    }
                }
            }
        }
        
        continuation.yield(.done)
    }
    
    private func handleNonStreamingResponse(
        request: URLRequest,
        continuation: AsyncThrowingStream<LLMEvent, Error>.Continuation
    ) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LLMError.invalidResponse
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let choice = choices.first,
              let message = choice["message"] as? [String: Any] else {
            throw LLMError.invalidResponse
        }
        
        if let content = message["content"] as? String {
            continuation.yield(.delta(content))
        }
        
        if let toolCalls = message["tool_calls"] as? [[String: Any]] {
            for toolCall in toolCalls {
                if let id = toolCall["id"] as? String,
                   let function = toolCall["function"] as? [String: Any],
                   let name = function["name"] as? String,
                   let arguments = function["arguments"] as? String {
                    continuation.yield(.toolCall(ToolCall(id: id, name: name, arguments: arguments)))
                }
            }
        }
        
        continuation.yield(.done)
    }
}

// MARK: - Supporting Types

struct LLMMessage {
    let role: String
    let content: String
    let name: String?
    let toolCallId: String?
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "role": role,
            "content": content
        ]
        if let name = name {
            dict["name"] = name
        }
        if let toolCallId = toolCallId {
            dict["tool_call_id"] = toolCallId
        }
        return dict
    }
}

struct LLMTool {
    let type: String = "function"
    let function: Function
    
    struct Function {
        let name: String
        let description: String
        let parameters: [String: Any]
    }
    
    func toDictionary() -> [String: Any] {
        [
            "type": type,
            "function": [
                "name": function.name,
                "description": function.description,
                "parameters": function.parameters
            ]
        ]
    }
}
