//
//  ToolRegistry.swift
//  OpenClaw
//

import Foundation

actor ToolRegistry {
    private var tools: [String: any Tool] = [:]
    
    func register(_ tool: any Tool) {
        tools[tool.name] = tool
    }
    
    func unregister(name: String) {
        tools.removeValue(forKey: name)
    }
    
    func execute(name: String, arguments: [String: Any]) async throws -> String {
        guard let tool = tools[name] else {
            throw ToolError.toolNotFound(name)
        }
        
        return try await tool.execute(arguments: arguments)
    }
    
    func getLLMToolDefinitions() -> [LLMTool] {
        tools.values.map { tool in
            LLMTool(function: LLMTool.Function(
                name: tool.name,
                description: tool.description,
                parameters: tool.parameters
            ))
        }
    }
}

// MARK: - Tool Protocol

protocol Tool {
    var name: String { get }
    var description: String { get }
    var parameters: [String: Any] { get } // JSON Schema
    
    func execute(arguments: [String: Any]) async throws -> String
}

enum ToolError: LocalizedError {
    case toolNotFound(String)
    case invalidArguments(String)
    case executionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .toolNotFound(let name):
            return "Tool '\(name)' not found"
        case .invalidArguments(let message):
            return "Invalid arguments: \(message)"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        }
    }
}

// MARK: - Helper for JSON Schema

extension Tool {
    func buildParameters(
        properties: [String: [String: Any]],
        required: [String] = []
    ) -> [String: Any] {
        [
            "type": "object",
            "properties": properties,
            "required": required
        ]
    }
    
    func stringProperty(description: String) -> [String: Any] {
        ["type": "string", "description": description]
    }
    
    func numberProperty(description: String) -> [String: Any] {
        ["type": "number", "description": description]
    }
    
    func booleanProperty(description: String) -> [String: Any] {
        ["type": "boolean", "description": description]
    }
    
    func arrayProperty(description: String, itemType: String = "string") -> [String: Any] {
        [
            "type": "array",
            "description": description,
            "items": ["type": itemType]
        ]
    }
}
