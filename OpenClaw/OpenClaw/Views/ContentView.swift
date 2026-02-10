//
//  ContentView.swift
//  OpenClaw
//
//  Created by Ryan's Agent on 2026-02-10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AgentRuntime.self) private var runtime
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
            
            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "doc.text")
                }
                .tag(2)
        }
        .task {
            await runtime.initialize()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Message.self, MemoryEntry.self, Conversation.self]) { result in
            // Runtime injected in env
        }
}