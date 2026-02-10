//
//  OpenClawApp.swift
//  OpenClaw
//
//  iOS OpenClaw - Run your AI agent directly on your iPhone
//

import SwiftUI
import SwiftData

@main
struct OpenClawApp: App {
    @State private var runtime: AgentRuntime?
    
    var body: some Scene {
        WindowGroup {
            if let runtime = runtime {
                ContentView()
                    .environment(runtime)
            } else {
                ProgressView("Initializing...")
                    .task {
                        await initializeApp()
                    }
            }
        }
        .modelContainer(for: [Message.self, Conversation.self, MemoryEntry.self]) { result in
            switch result {
            case .success(let container):
                print("✅ SwiftData container initialized")
                Task { @MainActor in
                    runtime = AgentRuntime(modelContext: container.mainContext)
                }
            case .failure(let error):
                print("❌ Failed to initialize SwiftData: \(error)")
            }
        }
    }
    
    @MainActor
    private func initializeApp() async {
        // Any additional app initialization
        print("📱 OpenClaw iOS starting...")
    }
}
