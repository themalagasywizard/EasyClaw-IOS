# iOS OpenClaw Implementation Plan

## Phase 1: Foundation (Weeks 1-2)

### Sprint 1: Project Setup & Shell

**Day 1-2: Xcode Project**
```bash
# Create SwiftUI project with required entitlements
- Bundle ID: com.openclaw.ios
- Target: iOS 17.0+ (SwiftData, improved BG fetch)
- Swift 6.0 strict concurrency
- Required capabilities:
  • Background Fetch
  • Push Notifications
  • CloudKit (optional sync)
  • MessageUI (iMessage)
```

**Day 3-4: Python Integration**
```swift
// PythonKit setup for embedded Python runtime
- Evaluate: PythonKit vs PySwiftObject vs CPython direct
- Test: Basic Python execution from Swift
- Embed: Minimal Python 3.11+ distribution (~30MB)
- Strip: Remove unnecessary stdlib modules
```

**Day 5-7: Core UI**
```swift
// Chat interface
- ChatView with message bubbles
- Text input with "thinking" indicator
- Settings modal
- Logs viewer for debugging
```

### Sprint 2: Agent Runtime

**Week 2 Goals**: Basic agent execution

**Tasks**:
1. **LLM Service** (`Services/LLMService.swift`)
   - OpenRouter API client
   - Streaming response handling
   - Model selection UI
   - API key secure storage (Keychain)

2. **Agent Loop** (`Services/AgentRuntime.swift`)
   - Minimal agent implementation in Swift
   - OR: PythonKit bridge to OpenClaw core
   - Conversation state management
   - Tool call parsing & execution

3. **Memory Service** (`Services/MemoryService.swift`)
   - SwiftData models for Memory/Messages
   - Semantic search (embedding-based)
   - Daily log files (compatible with desktop OpenClaw)

## Phase 2: Tools (Weeks 3-4)

### MVP Tools

1. **Memory Tools**
   - `memory_search`: Semantic search via embeddings
   - `memory_get`: Direct record access
   - `memory_write`: Add new memories

2. **Web Tools**
   - `web_search`: Brave API integration
   - `web_fetch`: Lightweight HTML→text extraction

3. **Messaging Tools**
   - `message_send`: iMessage via MessageUI
   - `message_telegram`: Telegram Bot API
   - `message_email`: SMTP send

### Implementation Strategy

**Option A: PythonKit Bridge** (Recommended for speed)
- Reuse existing OpenClaw Python tool implementations
- Swift → PythonKit → Python functions → Swift callback

**Option B: Native Swift Rewrite**
- Better performance, tighter iOS integration
- More work, maintenance burden

## Phase 3: Background & Integration (Weeks 5-6)

### Background Execution

**Challenge**: iOS kills background apps within seconds.

**Solutions** (in order of preference):

1. **Push Notification Wakeup**
   - Agent sleeps, push triggers wake
   - User notification: "New message" 
   - App launches → processes → responds

2. **Background Fetch** (Limited)
   - iOS decides when to run (every 15min - few hours)
   - Good for: periodic checks, heartbeat tasks

3. **VoIP Background Mode**
   - More permissive, requires real VOIP features
   - Risk: App Store rejection if misused

4. **Accessory Mode** (iOS 18+)
   - New in iOS 18 for always-on apps
   - Strict requirements

### Integration Targets

**iMessage** (via MessageUI):
- Can SEND messages (User confirms in UI)
- Cannot RECEIVE (no API) → Use relay server workaround

**Telegram Bot**:
- Webhook → Push Notification
- Bot API for responses
- Requires: Optional relay server for webhooks

**Email**:
- SMTP for sending
- IMAP idle for receiving (challenging on iOS)

## Phase 4: Polish & Distribution (Weeks 7-8)

### Security

- API keys in Keychain (not UserDefaults)
- Sandbox enforcement
- Camera/mic/photos permissions with clear prompts
- Privacy-preserving defaults (opt-in to cloud)

### Performance

- Lazy tool loading
- Embedding cache
- Conversation truncation (context window management)
- Background task limits

### Distribution

**App Store**: Full guidelines compliance
**TestFlight**: Beta testing (easier)
**AltStore/Sideload**: For power users, no review

## Technical Decisions Log

### Decision: Python vs Native Agent

| Criteria | PythonKit | Native Swift |
|----------|-----------|--------------|
| Dev Speed | ⭐⭐⭐ Fast | ⭐⭐ Medium |
| Performance | ⭐⭐ Medium | ⭐⭐⭐ Fast |
| Binary Size | ⭐⭐ ~40MB | ⭐⭐⭐ ~8MB |
| Maintenance | ⭐⭐ Sync with OpenClaw | ⭐⭐⭐ Isolated |
| Tool Reuse | ⭐⭐⭐ Full | ⭐⭐ Rewrite needed |

**Decision**: Start with PythonKit for MVP, port critical paths to Swift in v2.

### Decision: Background Strategy

**Primary**: Push Notifications + Manual Open
**Secondary**: Background Fetch for heartbeats
**Future**: Consider VOIP mode if needed

### Decision: Storage

- **Chat history**: SwiftData (SQLite)
- **Memory**: SwiftData + embedding vector index
- **Daily logs**: Files in app Documents
- **Sync**: iCloud Drive (optional, user's choice)

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| PythonKit app rejection | Medium | Vendor Python, no JIT, documentation |
| Background exec limits | High | Design for manual-open primary use |
| Binary size limits | Low | Strip Python stdlib aggressively |
| Performance on old devices | Medium | Test on iPhone 12, require iOS 17+ |

## Milestones

- [ ] **M1** (Week 2): Chat UI + Python execution
- [ ] **M2** (Week 4): Basic toolset, memory works
- [ ] **M3** (Week 6): iMessage integration, background handling
- [ ] **M4** (Week 8): MVP complete, TestFlight ready

## Resource Requirements

**Development**:
- iPhone/iPad for testing (Simulator insufficient for messaging)
- Apple Developer account ($99/year for TestFlight/App Store)
- OpenRouter API key ($5-10 for testing)

**Runtime** (per user):
- iOS 17+ device
- OpenRouter API key (free tier: $5 credit)
- ~50MB storage for app + Python runtime

## Open Questions

1. Should we include a lightweight relay server option for users who want 24/7 agent?
2. How to handle iMessage receiving (technical impossibility with public APIs)?
3. Should we support Shortcuts/Actions extension for Siri integration?
4. Gemini Nano on-device as fallback when offline?

---

*Plan version: 0.1*
*Last updated: 2026-02-10*
