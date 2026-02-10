//
//  Settings.swift
//  OpenClaw
//

import Foundation
import SwiftUI

@Observable
class AppSettings {
    // API Keys (stored in Keychain, these are just flags)
    var hasOpenRouterKey: Bool {
        KeychainService.shared.retrieve(for: .openRouter) != nil
    }
    
    var hasBraveSearchKey: Bool {
        KeychainService.shared.retrieve(for: .braveSearch) != nil
    }
    
    // Model Selection
    @AppStorage("selectedModel") var selectedModel: String = "anthropic/claude-sonnet-4-5"
    
    // Agent Behavior
    @AppStorage("agentName") var agentName: String = "ClawBot"
    @AppStorage("systemPrompt") var systemPrompt: String = ""
    @AppStorage("maxTokens") var maxTokens: Int = 4096
    @AppStorage("temperature") var temperature: Double = 0.7
    
    // UI Preferences
    @AppStorage("hapticFeedback") var hapticFeedback: Bool = true
    @AppStorage("showTimestamps") var showTimestamps: Bool = true
    @AppStorage("compactMode") var compactMode: Bool = false
    
    // Background & Notifications
    @AppStorage("enablePushNotifications") var enablePushNotifications: Bool = false
    @AppStorage("enableBackgroundFetch") var enableBackgroundFetch: Bool = false
    @AppStorage("batteryOptimization") var batteryOptimization: Bool = true
    
    // Messaging
    @AppStorage("enableIMessage") var enableIMessage: Bool = false
    @AppStorage("enableTelegram") var enableTelegram: Bool = false
    @AppStorage("enableEmail") var enableEmail: Bool = false
    
    // Storage
    @AppStorage("enableICloudSync") var enableICloudSync: Bool = false
    @AppStorage("maxConversationHistory") var maxConversationHistory: Int = 50
    
    // Privacy
    @AppStorage("shareAnalytics") var shareAnalytics: Bool = false
    @AppStorage("localProcessingOnly") var localProcessingOnly: Bool = false
    
    static let shared = AppSettings()
}

enum APIKeyService: String {
    case openRouter = "OpenRouter"
    case braveSearch = "BraveSearch"
    case telegram = "Telegram"
    case email = "Email"
}

// Available models - can be fetched from OpenRouter dynamically
struct LLMModel: Identifiable, Codable {
    let id: String
    let name: String
    let provider: String
    let contextWindow: Int
    let pricing: Pricing?
    
    struct Pricing: Codable {
        let prompt: Double // per 1M tokens
        let completion: Double
    }
    
    static let defaults: [LLMModel] = [
        LLMModel(id: "anthropic/claude-sonnet-4-5", name: "Claude Sonnet 4.5", provider: "Anthropic", contextWindow: 200000, pricing: nil),
        LLMModel(id: "anthropic/claude-3-haiku", name: "Claude 3 Haiku", provider: "Anthropic", contextWindow: 200000, pricing: nil),
        LLMModel(id: "google/gemini-flash-1.5", name: "Gemini Flash 1.5", provider: "Google", contextWindow: 1000000, pricing: nil),
        LLMModel(id: "openai/gpt-4o-mini", name: "GPT-4o Mini", provider: "OpenAI", contextWindow: 128000, pricing: nil),
        LLMModel(id: "openrouter/moonshotai/kimi-k2.5", name: "Kimi K2.5", provider: "Moonshot", contextWindow: 128000, pricing: nil),
    ]
}
