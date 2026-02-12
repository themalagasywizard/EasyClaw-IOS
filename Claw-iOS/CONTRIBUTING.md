# Contributing to EasyClaw iOS

Thank you for your interest in contributing to EasyClaw iOS! This document provides guidelines and instructions for contributing.

## 🎯 Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ SDK
- Swift 5.9+
- Git

### Development Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/easyclaw-ios.git
   cd easyclaw-ios
   ```
3. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Open `EasyClaw.xcodeproj` in Xcode
5. Install dependencies via Swift Package Manager

## 📝 Development Workflow

### Branch Naming Convention
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical production fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring

### Commit Messages
Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semi-colons, etc.
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Pull Request Process
1. Ensure your code follows the project's coding standards
2. Add or update tests as needed
3. Update documentation if required
4. Ensure all tests pass
5. Submit a pull request with a clear description

## 🏗️ Project Structure

```
EasyClaw-iOS/
├── EasyClaw/                    # Main app target
│   ├── App/                    # App entry point
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

## 💻 Coding Standards

### Swift Style Guide
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for code consistency
- Maximum line length: 120 characters
- Use `final` for classes not meant to be subclassed
- Prefer value types (structs, enums) over reference types

### Architecture
- Use MVVM pattern with Combine
- Dependency injection for services
- Protocol-oriented programming
- Clean separation of concerns

### Testing
- Write unit tests for business logic
- Write UI tests for critical user flows
- Aim for >80% code coverage
- Use descriptive test names

## 🧪 Testing

### Running Tests
```bash
# Unit tests
xcodebuild test -scheme EasyClaw -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme EasyClawUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Structure
```swift
class FeatureTests: XCTestCase {
    func testFeature_WhenCondition_ShouldResult() {
        // Arrange
        // Act
        // Assert
    }
}
```

## 📚 Documentation

### Code Documentation
- Document public APIs using Swift's documentation syntax
- Add inline comments for complex logic
- Keep README and other docs up to date

### Generating Documentation
```bash
# Install jazzy
gem install jazzy

# Generate documentation
jazzy --module EasyClawCore --output docs
```

## 🔧 Tools

### Required Tools
- [SwiftLint](https://github.com/realm/SwiftLint) - Code style enforcement
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) - Code formatting
- [Jazzy](https://github.com/realm/jazzy) - Documentation generation

### Development Tools
- [Proxyman](https://proxyman.io/) - Network debugging
- [InjectionIII](https://github.com/johnno1962/InjectionIII) - Hot reloading
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) - Project generation

## 🐛 Issue Reporting

### Bug Reports
When reporting bugs, please include:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior
4. Screenshots or videos if applicable
5. Device and iOS version
6. Xcode version

### Feature Requests
When requesting features, please include:
1. Use case description
2. Expected benefits
3. Potential implementation ideas
4. Any relevant references

## 🏆 Recognition

Contributors will be:
- Listed in the README.md
- Acknowledged in release notes
- Given credit in the app's about section

## ❓ Questions?

- Check the [documentation](docs/)
- Join our [Discord community](https://discord.gg/easyclaw)
- Open a [discussion](https://github.com/themalagasywizard/easyclaw-ios/discussions)
- Email: contributors@easyclaw.app

---

Thank you for contributing to EasyClaw iOS! 🚀