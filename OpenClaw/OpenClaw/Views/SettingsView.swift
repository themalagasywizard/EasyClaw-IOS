//
//  SettingsView.swift
//  OpenClaw
//

import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var openRouterKey = ""
    @State private var braveSearchKey = ""
    @State private var showingKeyAlert = false
    @State private var keyAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // API Keys Section
                Section("API Keys") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("OpenRouter")
                            Spacer()
                            if settings.hasOpenRouterKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        SecureField("API Key", text: $openRouterKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button(settings.hasOpenRouterKey ? "Update Key" : "Save Key") {
                            saveOpenRouterKey()
                        }
                        .disabled(openRouterKey.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Brave Search (Optional)")
                            Spacer()
                            if settings.hasBraveSearchKey {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        SecureField("API Key", text: $braveSearchKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button(settings.hasBraveSearchKey ? "Update Key" : "Save Key") {
                            saveBraveSearchKey()
                        }
                        .disabled(braveSearchKey.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    
                    Link("Get OpenRouter API Key →", destination: URL(string: "https://openrouter.ai/keys")!)
                        .font(.caption)
                }
                
                // Model Selection
                Section("Model") {
                    Picker("LLM Model", selection: $settings.selectedModel) {
                        ForEach(LLMModel.defaults) { model in
                            Text(model.name).tag(model.id)
                        }
                    }
                    
                    Slider(value: $settings.temperature, in: 0...1, step: 0.1) {
                        Text("Temperature: \(settings.temperature, specifier: "%.1f")")
                    }
                    
                    Stepper("Max Tokens: \(settings.maxTokens)", 
                           value: $settings.maxTokens, 
                           in: 1000...8000, 
                           step: 1000)
                }
                
                // Agent Settings
                Section("Agent") {
                    TextField("Agent Name", text: $settings.agentName)
                    
                    NavigationLink("System Prompt") {
                        TextEditor(text: $settings.systemPrompt)
                            .font(.body)
                            .padding()
                            .navigationTitle("System Prompt")
                    }
                }
                
                // UI Preferences
                Section("Interface") {
                    Toggle("Haptic Feedback", isOn: $settings.hapticFeedback)
                    Toggle("Show Timestamps", isOn: $settings.showTimestamps)
                    Toggle("Compact Mode", isOn: $settings.compactMode)
                }
                
                // Background & Notifications
                Section("Background") {
                    Toggle("Push Notifications", isOn: $settings.enablePushNotifications)
                    Toggle("Background Fetch", isOn: $settings.enableBackgroundFetch)
                    Toggle("Battery Optimization", isOn: $settings.batteryOptimization)
                }
                
                // Messaging
                Section("Messaging") {
                    Toggle("iMessage Integration", isOn: $settings.enableIMessage)
                    Toggle("Telegram Bot", isOn: $settings.enableTelegram)
                    Toggle("Email", isOn: $settings.enableEmail)
                }
                
                // Storage
                Section("Storage") {
                    Toggle("iCloud Sync", isOn: $settings.enableICloudSync)
                    Stepper("Conversation History: \(settings.maxConversationHistory)", 
                           value: $settings.maxConversationHistory, 
                           in: 10...200, 
                           step: 10)
                }
                
                // Privacy
                Section("Privacy") {
                    Toggle("Share Analytics", isOn: $settings.shareAnalytics)
                    Toggle("Local Processing Only", isOn: $settings.localProcessingOnly)
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/themalagasywizard/EasyClaw")!)
                    Link("OpenClaw Documentation", destination: URL(string: "https://docs.openclaw.ai")!)
                }
            }
            .navigationTitle("Settings")
            .alert("API Key", isPresented: $showingKeyAlert) {
                Button("OK") { }
            } message: {
                Text(keyAlertMessage)
            }
        }
    }
    
    private func saveOpenRouterKey() {
        do {
            try KeychainService.shared.save(openRouterKey, for: .openRouter)
            keyAlertMessage = "OpenRouter API key saved successfully"
            showingKeyAlert = true
            openRouterKey = ""
        } catch {
            keyAlertMessage = "Failed to save API key: \(error.localizedDescription)"
            showingKeyAlert = true
        }
    }
    
    private func saveBraveSearchKey() {
        do {
            try KeychainService.shared.save(braveSearchKey, for: .braveSearch)
            keyAlertMessage = "Brave Search API key saved successfully"
            showingKeyAlert = true
            braveSearchKey = ""
        } catch {
            keyAlertMessage = "Failed to save API key: \(error.localizedDescription)"
            showingKeyAlert = true
        }
    }
}

#Preview {
    SettingsView()
}
