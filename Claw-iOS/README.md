# EasyClaw iOS

**AI-Powered Productivity Assistant for Apple Ecosystem**

EasyClaw is a native iOS application that brings powerful AI agent capabilities to your Apple devices with seamless integration into Notes, Reminders, Calendar, and more.

## 🚀 Features

### 🤖 **AI Assistant Core**
- **Claude API Integration**: Powered by Anthropic's Claude models
- **Conversation Memory**: Persistent context across sessions
- **Tool Calling**: Access to device capabilities and APIs
- **Multi-Model Support**: Switch between different AI models

### 📱 **Apple Ecosystem Integration**
- **Apple Notes Sync**: Bidirectional sync with your Notes app
- **Reminders Integration**: Create and manage reminders via AI
- **Calendar Access**: Schedule events and check availability
- **iCloud Sync**: Seamless data synchronization across devices
- **Apple Sign In**: Secure authentication with your Apple ID

### 🎨 **Clean Chat Interface**
- **Minimalist Design**: Focus on conversation, not clutter
- **Markdown Support**: Rich text rendering for AI responses
- **Dark/Light Mode**: Automatic theme switching
- **File Attachments**: Support for images, PDFs, and documents
- **Search & Filter**: Find conversations quickly

### 🔧 **Advanced Features**
- **Prompt Templates**: Save and reuse effective prompts
- **Conversation Export**: Export chats as PDF or Markdown
- **Context Management**: Smart handling of long conversations
- **Custom Tools**: Extend functionality with custom integrations
- **API Access**: Developer-friendly REST API

## 🏗️ Architecture

### Tech Stack
- **Frontend**: SwiftUI with Combine
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **AI Integration**: Claude API + OpenRouter
- **Sync Engine**: CloudKit + iCloud
- **Database**: SQLite (local) + PostgreSQL (cloud)

### Project Structure
```
EasyClaw-iOS/
├── EasyClaw/                    # Main app target
│   ├── Models/                 # Data models
│   ├── Views/                  # SwiftUI views
│   ├── ViewModels/            # Combine view models
│   ├── Services/              # Business logic
│   └── Utilities/             # Helpers & extensions
├── EasyClawCore/              # Shared framework
│   ├── AI/                    # AI integration
│   ├── Sync/                  # CloudKit/Supabase sync
│   └── Tools/                 # Tool implementations
└── EasyClawWidgets/          # Widget extensions
```

## 📦 Installation

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Claude API key (or OpenRouter key)

### Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/easyclaw-ios.git
   cd easyclaw-ios
   ```

2. **Install dependencies**
   ```bash
   # Using Swift Package Manager (included)
   # Open in Xcode and wait for packages to resolve
   ```

3. **Configure API keys**
   Create `Config.xcconfig` with:
   ```
   CLAUDE_API_KEY = your_claude_api_key_here
   SUPABASE_URL = your_supabase_url
   SUPABASE_ANON_KEY = your_supabase_anon_key
   ```

4. **Build and run**
   ```bash
   open EasyClaw.xcodeproj
   # Select your device/simulator and press Cmd+R
   ```

## 🚢 Deployment

### App Store Submission
1. **Configure App ID and certificates** in Apple Developer Portal
2. **Set up App Store Connect** record
3. **Archive and upload** via Xcode
4. **Submit for review** with appropriate metadata

### Supabase Backend Setup
See [Supabase Setup Guide](./docs/Supabase-Setup.md) for detailed instructions on deploying the backend.

## 🔌 API Integration

### Claude API
```swift
import ClaudeKit

let claude = Claude(apiKey: Config.claudeApiKey)
let response = try await claude.sendMessage(
    "Hello, Claude!",
    model: .claude3Haiku,
    maxTokens: 1024
)
```

### Supabase Client
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: Config.supabaseURL,
    supabaseKey: Config.supabaseAnonKey
)
```

## 📱 Screenshots

| Chat Interface | Notes Integration | Settings |
|----------------|-------------------|----------|
| ![Chat](screenshots/chat.png) | ![Notes](screenshots/notes.png) | ![Settings](screenshots/settings.png) |

## 🛠️ Development

### Running Tests
```bash
# Unit tests
xcodebuild test -scheme EasyClaw -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme EasyClawUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Style
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for code consistency
- Write comprehensive documentation

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Documentation**: [docs.easyclaw.app](https://docs.easyclaw.app)
- **Issues**: [GitHub Issues](https://github.com/yourusername/easyclaw-ios/issues)
- **Discord**: [Join our community](https://discord.gg/easyclaw)
- **Email**: support@easyclaw.app

## 🙏 Acknowledgments

- [Anthropic](https://anthropic.com) for Claude API
- [Supabase](https://supabase.com) for backend infrastructure
- [Apple](https://developer.apple.com) for iOS frameworks
- All our contributors and beta testers

---

**Made with ❤️ for the Apple ecosystem**

*EasyClaw iOS - Your AI productivity companion*