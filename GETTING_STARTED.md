# Getting Started with iOS OpenClaw

## Quick Start (5 Minutes)

### Prerequisites

1. **Mac with Xcode 15+** (macOS Ventura or later)
2. **iPhone running iOS 17+** (or iPad)
3. **Apple Developer Account** (free tier works for device testing)
4. **OpenRouter API Key** (get $5 free credit at [openrouter.ai](https://openrouter.ai))

### Setup Steps

#### 1. Clone the Repository

```bash
git clone https://github.com/themalagasywizard/EasyClaw.git
cd EasyClaw
```

#### 2. Open in Xcode

```bash
open OpenClaw/OpenClaw.xcodeproj
```

If you don't have an Xcode project file yet, you'll need to create one:

1. Open Xcode
2. File → New → Project
3. Choose "iOS → App"
4. Product Name: `OpenClaw`
5. Organization Identifier: `com.openclaw`
6. Interface: SwiftUI
7. Language: Swift
8. Storage: SwiftData
9. Save in the `OpenClaw/` directory

#### 3. Configure Signing

1. In Xcode, select the project in the navigator
2. Select the "OpenClaw" target
3. Go to "Signing & Capabilities"
4. Select your Team (Apple Developer Account)
5. Xcode will automatically generate a bundle identifier

#### 4. Add Required Capabilities

In "Signing & Capabilities", click "+ Capability" and add:

- ✅ **Background Modes**: Enable "Background fetch"
- ✅ **Push Notifications**: For message alerts
- ✅ **iCloud**: Select "CloudKit" if you want sync
- ✅ **Keychain Sharing**: For secure API key storage

#### 5. Build & Run

1. Connect your iPhone via USB
2. Select your device in the Xcode toolbar
3. Click the Play button (⌘R)
4. Trust the developer certificate on your iPhone:
   - Settings → General → VPN & Device Management → Trust

#### 6. First Launch Configuration

When the app opens:

1. Go to **Settings** tab
2. Tap "API Keys" section
3. Paste your OpenRouter API key
4. (Optional) Add Brave Search API key for web search
5. Return to **Chat** tab
6. Start chatting!

---

## Project Structure

```
OpenClaw/
├── OpenClaw/
│   ├── OpenClawApp.swift         # Main app entry point
│   ├── Views/
│   │   ├── ContentView.swift     # Tab navigation
│   │   ├── ChatView.swift        # Main chat interface
│   │   ├── SettingsView.swift    # Configuration
│   │   ├── LogsView.swift        # Debugging/history
│   │   └── Components/
│   │       └── MessageBubble.swift
│   ├── Models/
│   │   ├── Message.swift         # SwiftData models
│   │   ├── Conversation.swift
│   │   ├── MemoryEntry.swift
│   │   └── Settings.swift
│   ├── Services/
│   │   ├── AgentRuntime.swift    # Core agent loop
│   │   ├── LLMService.swift      # OpenRouter integration
│   │   ├── MemoryService.swift   # Memory storage
│   │   ├── ToolRegistry.swift    # Tool management
│   │   └── Tools/
│   │       └── WebTools.swift    # web_search, web_fetch
│   └── Utils/
│       └── KeychainService.swift # Secure storage
└── Resources/
    └── Assets.xcassets/          # App icons, images
```

---

## Development Workflow

### Running on Simulator

The app works in the iOS Simulator, but some features are limited:

- ✅ Chat interface
- ✅ LLM conversations
- ✅ Memory storage
- ⚠️ Push notifications (won't work)
- ⚠️ iMessage sending (requires device)
- ❌ Background fetch (requires device)

### Testing on Device

For full functionality, always test on a real iPhone/iPad:

```bash
# Build and run on connected device
xcode-select --print-path  # Verify Xcode CLI tools
xcodebuild -scheme OpenClaw -destination 'platform=iOS,name=YOUR_DEVICE'
```

### Debugging

#### Enable Verbose Logging

In `OpenClawApp.swift`:

```swift
// Add this to see detailed logs
init() {
    print("🐛 Debug mode enabled")
    UserDefaults.standard.set(true, forKey: "DebugMode")
}
```

#### View SwiftData Database

```swift
// In AgentRuntime.swift, add:
func debugPrintDatabase() async {
    let conversations = try? modelContext.fetch(FetchDescriptor<Conversation>())
    print("📊 Conversations: \(conversations?.count ?? 0)")
}
```

#### Check API Calls

LLMService logs all requests. Look for:

```
🔄 Sending request to OpenRouter...
✅ Received response: 200 OK
📥 Streaming delta: "Hello! How can..."
```

---

## Configuration

### Changing the Default Model

Edit `Models/Settings.swift`:

```swift
@AppStorage("selectedModel") var selectedModel: String = "anthropic/claude-sonnet-4-5"
```

Options:
- `anthropic/claude-sonnet-4-5` - Best quality (recommended)
- `anthropic/claude-3-haiku` - Fastest, cheapest
- `google/gemini-flash-1.5` - Good balance
- `openai/gpt-4o-mini` - OpenAI option

### Custom System Prompt

In Settings → Agent → System Prompt, add:

```
You are ClawBot, a helpful AI assistant running natively on iOS.
You have access to web search, memory, and messaging tools.
Be concise and mobile-friendly in your responses.
```

### Memory Configuration

In `Services/MemoryService.swift`:

```swift
// Adjust search limits
func search(query: String, limit: Int = 10) async throws -> [MemoryEntry]

// Change embedding model (when implemented)
func generateEmbedding(for text: String) async throws -> [Float] {
    // TODO: Call OpenAI embeddings API
}
```

---

## API Keys Setup

### OpenRouter (Required)

1. Go to [openrouter.ai/keys](https://openrouter.ai/keys)
2. Sign in (GitHub or email)
3. Click "Create Key"
4. Copy the key (starts with `sk-or-...`)
5. Paste in app Settings

**Free tier**: $5 credit, enough for ~1000 messages with Haiku

### Brave Search (Optional)

1. Go to [brave.com/search/api](https://brave.com/search/api)
2. Sign up for API access
3. Generate API key
4. Paste in app Settings

**Free tier**: 2,000 queries/month

---

## Building for TestFlight

### 1. Archive the App

```bash
# In Xcode:
Product → Archive
```

### 2. Distribute to TestFlight

1. Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Choose "TestFlight & App Store"
5. Upload
6. Wait for processing (~10-30 minutes)

### 3. Invite Testers

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps → OpenClaw → TestFlight
3. Add internal testers (up to 100)
4. Or create external testing group (up to 10,000)

---

## Troubleshooting

### "No OpenRouter API key configured"

**Solution**: Go to Settings → API Keys → paste your key

### "Failed to initialize SwiftData"

**Solution**: 
1. Delete app from device
2. Clean build folder (⇧⌘K)
3. Rebuild

### Messages not sending

**Check**:
1. Internet connection
2. API key is valid
3. Check Logs tab for errors
4. Model is available (some models have waitlists)

### App crashes on launch

**Debug**:
1. View crash logs: Xcode → Window → Devices and Simulators
2. Select device → View Device Logs
3. Look for OpenClaw crashes
4. Check SwiftData initialization

### Tool calls failing

**Common issues**:
- Brave Search: Key not configured or invalid
- Web Fetch: URL is unreachable or blocked
- Memory: Database not initialized

---

## Next Steps

1. ✅ **Test basic chat** - Send a simple message
2. ✅ **Try web search** - "Search for latest iPhone news"
3. ✅ **Test memory** - "Remember I like coffee"
4. ✅ **Check logs** - View conversation history
5. ✅ **Customize settings** - Change model, tweak temperature

Then explore:
- Adding new tools (see `ARCHITECTURE.md`)
- Implementing background fetch
- Setting up push notifications
- Contributing to the project

---

## Getting Help

- **GitHub Issues**: [github.com/themalagasywizard/EasyClaw/issues](https://github.com/themalagasywizard/EasyClaw/issues)
- **OpenClaw Docs**: [docs.openclaw.ai](https://docs.openclaw.ai)
- **Discord**: [discord.gg/clawd](https://discord.gg/clawd)

---

**Ready to build?** Open Xcode and start hacking! 🚀
