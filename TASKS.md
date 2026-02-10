# Project Tracking

## Current Status: Planning Phase

**Started**: 2026-02-10  
**Phase**: Pre-MVP Design

---

## Master Task List

### Phase 1: Foundation (Weeks 1-2)

#### Sprint 1: Project Setup
- [ ] Create Xcode project with SwiftUI
- [ ] Configure entitlements (Push, Background fetch, iCloud)
- [ ] Set up SwiftData schema
- [ ] Integrate PythonKit
- [ ] Create basic chat UI
- [ ] Add settings screen
- [ ] Implement logs viewer

#### Sprint 2: Agent Runtime
- [ ] Build LLMService (OpenRouter)
- [ ] Implement core agent loop
- [ ] Create MemoryService (SwiftData)
- [ ] Add conversation persistence
- [ ] Build ToolRegistry
- [ ] Implement basic tools (memory, web_search)

### Phase 2: Tools (Weeks 3-4)
- [ ] memory_search implementation
- [ ] memory_get implementation
- [ ] web_search (Brave API)
- [ ] web_fetch implementation
- [ ] message_send (iMessage)
- [ ] message_telegram
- [ ] message_email
- [ ] Tool error handling

### Phase 3: Integration (Weeks 5-6)
- [ ] Push notification setup
- [ ] Background fetch implementation
- [ ] iMessage send flow
- [ ] Telegram bot integration
- [ ] Email send/receive
- [ ] Deletegate message receiving
- [ ] Test push wake functionality

### Phase 4: Polish (Weeks 7-8)
- [ ] Keychain API key storage
- [ ] iCloud sync for data
- [ ] Battery optimization
- [ ] Error logging
- [ ] Onboarding flow
- [ ] App icon and assets
- [ ] TestFlight preparation

---

## Decision Log

| Date | Decision | Context |
|------|----------|---------|
| 2026-02-10 | Use PythonKit | Faster MVP, tool reuse |
| 2026-02-10 | Target iOS 17+ | SwiftData, better BG fetch |
| | | |

---

## Blockers

| Issue | Impact | Mitigation |
|-------|--------|------------|
| iMessage receiving not possible | High | Use Telegram/Email inbound |
| Background execution limits | Medium | Design for manual-open |
| App Store PythonKit risk | Medium | Document, test thoroughly |

---

## Resources

- [PythonKit GitHub](https://github.com/pvieito/PythonKit)
- [iOS Background Execution Guide](https://developer.apple.com/documentation/backgroundtasks)
- [OpenRouter Docs](https://openrouter.ai/docs)

---

*Last updated: 2026-02-10*
