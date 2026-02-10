//
//  ChatView.swift
//  OpenClaw
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(AgentRuntime.self) private var runtime
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @State private var inputText = ""
    @State private var isThinking = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ClawBot")
                        .font(.headline)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(runtime.state == .running ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(runtime.state == .running ? "Online" : "Connecting...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button(action: { runtime.startNewConversation() }) {
                    Image(systemName: "plus.square.fill")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            // Messages
            ScrollViewReader { proxy in
                List {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    
                    if isThinking {
                        ThinkingIndicator()
                            .id("thinking")
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .onChange(of: messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
                .onChange(of: isThinking) { _, _ in
                    scrollToBottom(proxy)
                }
            }
            
            // Input
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    TextField("Message ClawBot...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .focused($isInputFocused)
                        .disabled(isThinking)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(inputText.isEmpty || isThinking ? .gray : .accentColor)
                    }
                    .disabled(inputText.isEmpty || isThinking)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        inputText = ""
        isThinking = true
        
        Task {
            await runtime.sendMessage(text)
            isThinking = false
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let last = messages.last {
            withAnimation(.smooth) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        } else if isThinking {
            withAnimation(.smooth) {
                proxy.scrollTo("thinking", anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView()
}