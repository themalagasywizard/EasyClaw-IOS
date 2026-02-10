# EasyClaw - iOS OpenClaw Wrapper 📱⚡

**Run your AI agent directly on your iPhone. No VPS. No server. Just chat.**

A native iOS app that brings OpenClaw's powerful agent capabilities to your pocket. Chat with AI, search the web, store memories—all running locally on your device.

## 🎯 Vision

**One-tap deployment**: Download → Open → Chat → Done.

No complex setup, no servers to maintain, no technical expertise required. Your personal AI assistant, always in your pocket.

## ✨ Features (MVP)

- 💬 **Natural Chat Interface** - Clean, responsive SwiftUI chat
- 🧠 **Persistent Memory** - Remembers context across conversations
- 🔍 **Web Search** - Brave Search integration for real-time info
- 🌐 **Web Scraping** - Fetch and read any URL
- 📊 **Multiple Models** - Claude, GPT-4o, Gemini, and more via OpenRouter
- 🔐 **Secure Storage** - API keys in iOS Keychain
- 📱 **Native iOS** - Fast, battery-efficient, works offline (with limitations)
- 🎨 **Beautiful UI** - Modern iOS design with dark mode support

## 🚀 Quick Start

```bash
git clone https://github.com/themalagasywizard/EasyClaw.git
cd EasyClaw
open OpenClaw/OpenClaw.xcodeproj
```

**Requirements**: Xcode 15+, iOS 17+, OpenRouter API key

See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed setup instructions.

## 📸 Screenshots

_Coming soon: Chat interface, Settings, Memory logs_

## Architecture Overview

```
┌─────────────────────────────────────────┐
│           iOS App (SwiftUI)             │
├─────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │  Chat   │  │ Settings│  │  Logs   │ │
│  │   UI    │  │         │  │         │ │
│  └────┬────┘  └─────────┘  └─────────┘ │
├───────┼─────────────────────────────────┤
│       ▼                                 │
│  ┌─────────────────────────────────┐    │
│  │     Embedded Agent Runtime      │    │
│  │  (Swift + PythonKit/embedded)  │    │
│  ├─────────────────────────────────┤    │
│  │ • Core agent loop               │    │
│  │ • LLM API client (OpenRouter)   │    │
│  │ • Tool registry (simplified)    │    │
│  │ • Memory manager (SQLite)       │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ iMessage│  │Telegram │  │  Email  │ │
│  │ (via    │  │  (Bot)  │  │(SMTP)   │ │
│  │MessageUI)│  │         │  │         │ │
│  └─────────┘  └─────────┘  └─────────┘ │
└─────────────────────────────────────────┘
```

## Key Design Decisions

### 1. Mobile-First Architecture
- **No persistent background process**: iOS kills background apps. Instead, we use:
  - Push notifications to wake the agent
  - Background fetch for periodic checks
  - VoIP background mode (if needed for real-time)
  - Foreground execution when app is open

### 2. Simplified Tooling
Full OpenClaw has 30+ tools. Mobile version starts with essentials:
- `memory_search` / `memory_get` (SQLite-based)
- `web_search` (Brave API)
- `web_fetch` (lightweight scraping)
- Messaging tools (iMessage, Telegram, Email)
- Basic file operations (sandboxed)

### 3. Embedded Runtime
Options evaluated:
- **PythonKit + embedded Python**: Most compatible with existing OpenClaw
- **Swift native rewrite**: Better performance, more work
- **JavaScriptCore + Node shim**: Compromise option

**Decision**: Start with PythonKit for rapid prototyping, migrate performance-critical paths to Swift.

### 4. Memory Strategy
- **SQLite** for structured data (conversations, facts, todos)
- **File-based** for daily logs (same format as desktop OpenClaw)
- **iCloud sync** for backup (optional, user-controlled)

## Project Structure

```
ios-openclaw/
├── README.md
├── PLAN.md                    # Detailed implementation roadmap
├── ARCHITECTURE.md            # Technical deep-dive
├── docs/
│   ├── SETUP.md              # User-facing setup guide
│   ├── FAQ.md                # Common issues
│   └── PRIVACY.md            # Data handling explanation
├── OpenClaw/
│   ├── OpenClaw.xcodeproj/
│   ├── OpenClaw/
│   │   ├── App/
│   │   │   ├── OpenClawApp.swift
│   │   │   └── AppDelegate.swift
│   │   ├── Views/
│   │   │   ├── ChatView.swift
│   │   │   ├── SettingsView.swift
│   │   │   ├── LogsView.swift
│   │   │   └── Components/
│   │   ├── Models/
│   │   │   ├── Message.swift
│   │   │   ├── Agent.swift
│   │   │   └── Settings.swift
│   │   ├── Services/
│   │   │   ├── AgentRuntime.swift
│   │   │   ├── LLMService.swift
│   │   │   ├── MemoryService.swift
│   │   │   ├── ToolRegistry.swift
│   │   │   └── Messaging/
│   │   │       ├── iMessageService.swift
│   │   │       ├── TelegramService.swift
│   │   │       └── EmailService.swift
│   │   └── Utils/
│   │       ├── PythonBridge.swift
│   │       ├── Crypto.swift
│   │       └── Logger.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       └── Python/
│           ├── requirements.txt
│           └── openclaw_core/         # Embedded Python runtime
├── server/                    # Optional: lightweight relay server
│   └── README.md
└── tests/
    └── README.md
```

## MVP Scope (Phase 1)

**Goal**: Working chat with agent on-device

**Features**:
- [ ] Basic SwiftUI chat interface
- [ ] Embedded Python runtime (PythonKit)
- [ ] Core agent loop (simplified)
- [ ] OpenRouter LLM integration
- [ ] SQLite memory storage
- [ ] Basic tools: memory, web_search, web_fetch
- [ ] iMessage integration (send/receive)

**Non-Goals for MVP**:
- Background execution (app must be open)
- Complex tool ecosystem
- Multi-agent support
- Cloud sync
- App Store distribution

## Success Criteria

1. **Setup time**: < 5 minutes from download to first chat
2. **Friction**: Zero configuration required (sane defaults)
3. **Performance**: Response time < 3 seconds for simple queries
4. **Reliability**: Agent remembers context across sessions
5. **Privacy**: All data stays on device (except LLM API calls)

## Next Steps

See `PLAN.md` for detailed implementation roadmap.

---

*Created: 2026-02-10*
*Status: Planning phase*
