# iOS OpenClaw Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS APP                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     SwiftUI Layer                          │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │  │
│  │  │ ChatView │  │ Settings │  │  Logs    │  │ Models   │   │  │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │  │
│  │       └──────────────┴─────────────┴─────────────┘         │  │
│  │                         │                                  │  │
│  └─────────────────────────┼──────────────────────────────────┘  │
│                            │                                      │
│  ┌─────────────────────────┼──────────────────────────────────┐  │
│  │                      Services Layer                         │  │
│  │  ┌──────────────────────┴────────────────────────────────┐ │  │
│  │  │                 Agent Runtime                          │ │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │ │  │
│  │  │  │  Conversation│  │   Tool      │  │   Memory    │   │ │  │
│  │  │  │  Manager     │  │  Registry   │  │   Service   │   │ │  │
│  │  │  └──────┬───────┘  └──────┬──────┘  └──────┬──────┘   │ │  │
│  │  │         └────────────────┼────────────────┘          │ │  │
│  │  │                          │                           │ │  │
│  │  │  ┌───────────────────────┴──────────────────────────┐│ │  │
│  │  │  │              LLM Service (OpenRouter)             ││ │  │
│  │  │  │  • Streaming responses                          ││ │  │
│  │  │  │  • Model management                             ││ │  │
│  │  │  │  • Request/response logging                     ││ │  │
│  │  │  └─────────────────────────────────────────────────┘│ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │              Messaging Bridge                        │ │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐            │ │  │
│  │  │  │ iMessage│  │Telegram │  │  Email  │            │ │  │
│  │  │  └─────────┘  └─────────┘  └─────────┘            │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                      │
│  ┌─────────────────────────┼──────────────────────────────────┐  │
│  │                   Data Layer                              │  │
│  │  ┌───────────┐  ┌──────────┐  ┌─────────────────────┐    │  │
│  │  │  SwiftData│  │  Keychain│  │     File System     │    │  │
│  │  │  (SQLite) │  │  (Secrets)│  │  (Documents/Logs)   │    │  │
│  │  └───────────┘  └──────────┘  └─────────────────────┘    │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Runtime Modes

### Mode 1: Foreground (Active)
```
User opens app → AgentRuntime.start() → Listen for messages
                    ↓
        ┌───────────┴───────────┐
   User sends msg           Push received
        ↓                        ↓
   Process immediately     Wake → Process → Notify
```

### Mode 2: Background (Limited)
```
App backgrounded → Save state → Pause agent
        ↓
   Push notification received
        ↓
   App wakes (limited time: ~30s)
        ↓
   Process → Response → Back to sleep
```

### Mode 3: Terminated (Push-Driven)
```
App not running → Push arrives
        ↓
   iOS wakes app in background
        ↓
   Process → Show notification with response
```

## Core Components

### 1. AgentRuntime (`Services/AgentRuntime.swift`)

**Responsibilities**:
- Manage agent lifecycle (start/pause/resume/stop)
- Coordinate between LLM and tools
- Maintain conversation state

```swift
actor AgentRuntime {
    enum State { case idle, thinking, waiting }
    
    private let llm: LLMService
    private let tools: ToolRegistry
    private let memory: MemoryService
    
    func process(message: UserMessage) async -> AgentResponse
    func handleToolCall(_ call: ToolCall) async -> ToolResult
    func persistConversation() async
}
```

### 2. LLMService (`Services/LLMService.swift`)

**Responsibilities**:
- OpenRouter API communication
- Streaming response handling
- Model selection & context management
- Token usage tracking

```swift
protocol LLMService {
    func send(messages: [Message], 
              model: ModelID, 
              tools: [Tool], 
              stream: Bool) -> AsyncThrowingStream<LLMEvent, Error>
    
    func validate(apiKey: String) async throws -> Bool
    func fetchAvailableModels() async throws -> [Model]
}
```

**Supported Models** (Mobile-optimized):
- `anthropic/claude-3-haiku` - Fast, cheap
- `google/gemini-flash` - Fast, vision-capable
- `openai/gpt-4o-mini` - JSON mode reliable
- Custom endpoint support

### 3. MemoryService (`Services/MemoryService.swift`)

**Storage Strategy**:

| Data Type | Storage | Sync |
|-----------|---------|------|
| Conversation history | SwiftData | iCloud |
| Semantic memory | SQLite + vectors | iCloud |
| Daily logs | Files | iCloud Drive |
| Settings | UserDefaults | iCloud KV |
| API keys | Keychain | No |

```swift
actor MemoryService {
    // SwiftData models
    @Model class Conversation: Identifiable { ... }
    @Model class Message: Identifiable { ... }
    @Model class MemoryEntry: Identifiable { ... }
    
    // Operations
    func search(query: String, limit: Int) async -> [MemoryEntry]
    func save(entry: MemoryEntry) async
    func exportDailyLog() async
}
```

**Semantic Search**:
- Generate embeddings via local OR embedding API
- SQLite with `sqlite-vec` extension for vector storage
- Cosine similarity search

### 4. ToolRegistry (`Services/ToolRegistry.swift`)

**Tool Registration**:
```swift
protocol Tool {
    var name: String { get }
    var description: String { get }
    var parameters: JSONSchema { get }
    func execute(arguments: JSONObject) async throws -> ToolResult
}

class ToolRegistry {
    private var tools: [String: Tool] = [:]
    
    func register(_ tool: Tool)
    func unregister(_ tool: Tool)
    func execute(name: String, arguments: JSONObject) async throws -> ToolResult
    func schemaForLLM() -> [ToolSchema]
}
```

**MVP Tools**:
1. `memory_search` - Semantic memory retrieval
2. `memory_get` - Direct memory access
3. `web_search` - Brave Search API
4. `web_fetch` - URL content extraction
5. `message_send` - Send iMessage/SMS
6. `message_telegram` - Telegram Bot API
7. `message_email` - SMTP email

### 5. Messaging Bridge (`Services/Messaging/`)

**iMessage Integration**:
```swift
// SENDING (Supported)
import MessageUI

class iMessageService: NSObject, MFMessageComposeViewControllerDelegate {
    func send(message: String, to recipients: [String])
    
    // Note: iOS shows compose UI, user must tap Send
    // No headless sending for privacy
}

// RECEIVING (NOT supported via public API)
// Workaround: Use plain cell number + message forwarding
// OR: Use Telegram/Email as primary inbound channel
```

**Telegram Bot Integration**:
```swift
// RECEIVING requires webhook
// Problem: Webhook needs server
// Solutions:
// 1. Polling (battery intensive, not recommended)
// 2. Optional relay server (we provide, user opts-in)
// 3. Push notification via APNs

class TelegramService {
    func send(message: String, chatId: String) async throws
    func setupPolling() async // Fallback, disabled by default
}
```

## Python Bridge Architecture

### PythonKit Integration

```swift
import PythonKit

class PythonBridge {
    private let sys = Python.import("sys")
    private let os = Python.import("os")
    
    init() {
        // Set Python paths to embedded stdlib
        let pythonPath = Bundle.main.path(forResource: "python311", ofType: nil)!
        sys.path.append(pythonPath)
    }
    
    func executeTool(name: String, arguments: [String: Any]) async throws -> Any {
        let tool = Python.import("openclaw.tools").get_tool(name)
        return try await tool.execute(arguments.pythonObject)
    }
}
```

**Embedded Python Distribution**:
```
Resources/Python/
├── python3.11/           # ~25MB stripped
│   ├── lib-dynload/      # Required extensions only
│   ├── lib/              # Stripped stdlib
│   └── site-packages/    # OpenClaw deps
└── openclaw_core/        # ~5MB
    ├── __init__.py
    ├── agent.py          # Simplified agent
    ├── tools/            # Tool implementations
    └── memory/           # Python memory bridge
```

## Security Model

### Sandboxing
- App runs in iOS standard sandbox
- No access to files outside container
- Network requests only via NSURLSession
- Keychain for secrets with accessibility guard

### API Key Security
```swift
enum SecureEnclave {
    static func save(apiKey: String, for service: Service) throws
    static func retrieve(for service: Service) throws -> String
    static func delete(for service: Service) throws
}

// Keys marked with accessibility: .afterFirstUnlockThisDeviceOnly
```

### Content Security
- HTML sanitization for web_fetch results
- URL validation (no local IPs, private ranges)
- Prompt injection mitigation (instruction boundaries)
- Rate limiting on outgoing messages

## Performance Optimization

### Startup Optimization
```
Cold Start Target: < 2 seconds

Optimization strategies:
1. Lazy-load Python runtime (on first tool use)
2. Pre-warm LLM connection
3. Defer embedding model load
4. Batch SwiftData operations
5. Snapshot conversation state on background
```

### Memory Management
```
Target Memory: < 150MB while running

Strategies:
1. Automatic conversation pruning (keep last 50 messages)
2. Clear tool result cache after 5min
3. Lazy tool loading
4. Python GC after each conversation
5. Image compression (max 1920px width)
```

### Battery Efficiency
```swift
class BatteryAwareScheduler {
    func shouldAllowBackgroundTask() -> Bool {
        let battery = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        return battery > 0.2 || state == .charging
    }
}
```

## Data Flow

### Sending a Message (User → Agent)
```
┌──────────┐     ┌─────────────┐     ┌─────────────┐     ┌──────────┐
│ User     │────▶│ ChatView    │────▶│ AgentRuntime│────▶│ Memory   │
│ types    │     │ captures    │     │ queue +     │     │ saves    │
│ message  │     │ input       │     │ persists    │     │ to Swift │
└──────────┘     └─────────────┘     └─────────────┘     │ Data     │
                              │                         └────┬─────┘
                              ▼                              │
                       ┌─────────────┐                       │
                       │ LLMService  │◀───────────────────────┘
                       │ streams     │  (context retrieval)
                       │ response    │
                       └──────┬──────┘
                              │
            ┌─────────────────┴─────────────────┐
            ▼                                     ▼
      ┌──────────┐                         ┌──────────┐
      │ Tool     │                         │ Response │
      │ Call     │                         │ complete │
      │ detected │                         │          │
      └────┬─────┘                         └────┬─────┘
           │                                   │
           ▼                                   ▼
      ┌──────────┐                         ┌──────────┐
      │ Tool     │                         │ ChatView │
      │ executes │                         │ updates  │
      └──────────┘                         └──────────┘
```

### Receiving a Message (External → Agent)
```
Push Notification Received
        │
        ▼
iOS wakes app in background
        │
        ▼
NotificationServiceExtension processes
        │
        ▼
Main app launches (if needed)
        │
        ▼
AgentRuntime processes message
        │
        ▼
Notification sent with response
        │
        ▼
User taps notification → App opens
```

## Push Notification Strategy

### APNs Proxy (Recommended for now)

Since we can't maintain persistent background connection:

```
External Message (Telegram/Email)
        │
        ▼
Optional: Lightweight relay server
(Or: Direct webhook to APNs if supported)
        │
        ▼
Apple Push Notification Service
        │
        ▼
iOS Device
        │
        ▼
Our NotificationExtension
        │
        ▼
Wake Agent → Process → Show notification
```

### Self-Hosted Relay

For users who want inbound messaging, provide a simple relay:

```python
# relay_server.py (optional, runs on user's VPS if they have one)
# Or: We run a gateway service (privacy considerations)

"""
POST /webhook/telegram → Validate → APNs push to device
POST /webhook/email    → Validate → APNs push to device
"""
```

**Privacy-first option**: Device polling (disabled by default, battery impact)

## Migration Path from Desktop OpenClaw

### Memory Compatibility
```
Desktop OpenClaw memory format:
- MEMORY.md (markdown)
- memory/YYYY-MM-DD.md (daily logs)
- .openclaw.json (config)

iOS OpenClaw can:
1. Import from iCloud Drive sync
2. Export compatible format
3. Read-only view of desktop files
```

### Config Compatibility
```
// Shared fields
{
  "model": "openrouter/moonshotai/kimi-k2.5",
  "apiKeys": {
    "openrouter": "..."
  },
  "tools": ["memory", "web_search", "web_fetch"],
  "preferences": { ... }
}

// iOS-specific
{
  "backgroundMode": "push",
  "messageChannels": ["imessage", "telegram_bot"],
  "batteryOptimization": true,
  "icloudSync": true
}
```

## Testing Strategy

### Unit Tests
- ToolRegistry mocking
- LLMService with stub responses
- MemoryService with in-memory SwiftData

### Integration Tests
- Full conversation flow
- Push notification handling
- iMessage send flow

### Device Testing
- iPhone 12 (minimum spec)
- iPhone 15 Pro (latest)
- iPad Pro (tablet layout)

### Beta Testing
- TestFlight for invited users
- Crash logging via TelemetryDeck or Sentry
- Performance metrics

## Future Enhancements

### Short-Term (v1.x)
- [ ] Siri Shortcuts integration
- [ ] Share extension ("Open in OpenClaw")
- [ ] Widget for quick status
- [ ] Live Activities for active conversations

### Medium-Term (v2.0)
- [ ] On-device LLM (Llama/Gemma quantized)
- [ ] Photographs → Vision model
- [ ] Voice input (Speech → LLM)
- [ ] Native Swift migration (drop PythonKit)

### Long-Term
- [ ] VisionOS support
- [ ] Watch companion app
- [ ] Collaborative agents (multi-device)
- [ ] App Clips for quick access

---

*Architecture version: 0.1*
*Platform: iOS 17.0+*
*Language: Swift 6.0*
