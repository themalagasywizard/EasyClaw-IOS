//
//  MessageBubble.swift
//  OpenClaw
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 20)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleColor)
                    .foregroundStyle(textColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                if let timestamp = message.timestamp {
                    Text(formatTime(timestamp))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer(minLength: 20)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var bubbleColor: Color {
        switch message.role {
        case .user:
            return .accentColor
        case .assistant:
            return Color(.secondarySystemBackground)
        case .system:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch message.role {
        case .user:
            return .white
        case .assistant:
            return .primary
        case .system:
            return .secondary
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ThinkingIndicator: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack {
            Spacer(minLength: 20)
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 6, height: 6)
                        .offset(y: offset)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .delay(Double(i) * 0.15)
                            .repeatForever(autoreverses: true),
                            value: offset
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.vertical, 2)
        .onAppear { offset = -4 }
    }
}

#Preview {
    List {
        MessageBubble(message: Message(role: .user, content: "Hello!", timestamp: Date()))
        MessageBubble(message: Message(role: .assistant, content: "Hi there! Ready to chat.", timestamp: Date()))
        ThinkingIndicator()
    }
    .listStyle(.plain)
}