# Contributing to UniCheck

Thank you for your interest in contributing to UniCheck! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone. We expect all contributors to:

- Be respectful and considerate
- Accept constructive criticism gracefully
- Focus on what's best for the project
- Show empathy towards other contributors

### Unacceptable Behavior

- Harassment or discriminatory comments
- Personal attacks
- Publishing others' private information
- Unprofessional conduct

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Flutter SDK** (3.9.2 or higher) installed
2. **Git** configured with your GitHub account
3. **Android Studio** or **VS Code** with Flutter plugins
4. Read the [Setup Guide](SETUP.md)
5. Familiarized yourself with the [Architecture](ARCHITECTURE.md)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/UniCheck.git
   cd UniCheck
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/ZippoLord/UniCheck.git
   ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

### Create a Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number-description
```

**Branch naming conventions:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Adding or updating tests

## Development Workflow

### 1. Sync with Upstream

Before starting work, sync with the main repository:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

### 2. Make Changes

- Write clean, readable code
- Follow existing code style
- Comment complex logic
- Keep changes focused and minimal

### 3. Test Your Changes

```bash
# Run all tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run on device
flutter run
```

### 4. Commit Changes

```bash
git add .
git commit -m "feat: add user profile page"
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Coding Standards

### Dart Style Guide

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

**File naming:**
```
✅ user_profile_page.dart
❌ UserProfilePage.dart
❌ userProfilePage.dart
```

**Class naming:**
```dart
✅ class UserProfilePage extends StatelessWidget { }
❌ class userProfilePage extends StatelessWidget { }
```

**Variable naming:**
```dart
✅ final String userName;
❌ final String UserName;
❌ final String user_name;
```

**Private members:**
```dart
✅ String _privateVariable;
✅ void _privateMethod() { }
```

### Code Formatting

Use `flutter format`:

```bash
# Format all files
flutter format lib/

# Format specific file
flutter format lib/main.dart
```

**Line length:** Maximum 120 characters

### Code Organization

**Import order:**
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Local imports

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:prog24/constants.dart';
import 'package:prog24/models/user.dart';
```

### Widget Structure

```dart
class MyWidget extends StatelessWidget {
  // 1. Final fields
  final String title;
  final VoidCallback? onPressed;

  // 2. Constructor
  const MyWidget({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  // 3. Private methods
  void _handleTap() {
    // Implementation
  }

  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title),
    );
  }
}
```

### State Management with GetX

**Controller pattern:**

```dart
class UserController extends GetxController {
  // 1. Observable state
  final _user = Rx<User?>(null);
  User? get user => _user.value;

  // 2. Loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // 3. Public methods
  Future<void> fetchUser() async {
    _isLoading.value = true;
    try {
      // API call
    } finally {
      _isLoading.value = false;
    }
  }

  // 4. Cleanup
  @override
  void onClose() {
    // Dispose resources
    super.onClose();
  }
}
```

**Using controllers in widgets:**

```dart
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    
    return Obx(() {
      if (controller.isLoading) {
        return CircularProgressIndicator();
      }
      return Text(controller.user?.name ?? 'No user');
    });
  }
}
```

### Error Handling

Always handle errors gracefully:

```dart
Future<void> loginUser() async {
  try {
    final response = await http.post(url, body: data);
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle HTTP error
      final error = apiErrorFromJson(response.body);
      _showError(error.details);
    }
  } on SocketException {
    _showError('No internet connection');
  } on TimeoutException {
    _showError('Request timeout');
  } catch (e) {
    _showError('Unexpected error: $e');
  }
}
```

## Commit Guidelines

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or tool changes

**Examples:**

```
feat(auth): add password reset functionality

Implement password reset flow with email verification.
Users can now request password reset link via email.

Closes #123
```

```
fix(nfc): resolve HCE service crash on Android 13

Fixed null pointer exception when reading SharedPreferences
in HCE service. Added null checks and default values.

Fixes #456
```

```
docs: update API documentation with new endpoints

Added documentation for user profile endpoints.
Updated examples with latest response format.
```

### Commit Best Practices

- Write in present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor" not "moves cursor")
- Keep first line under 72 characters
- Separate subject from body with blank line
- Reference issues and PRs in footer

## Pull Request Process

### Before Creating PR

1. **Update from main:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests:**
   ```bash
   flutter test
   flutter analyze
   ```

3. **Format code:**
   ```bash
   flutter format lib/
   ```

4. **Update documentation** if needed

### Creating a Pull Request

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub** with:
   - Clear title describing the change
   - Detailed description of what and why
   - Screenshots for UI changes
   - Reference related issues

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Related Issues
Closes #123

## Testing
- [ ] Tested on Android device
- [ ] Tested on emulator
- [ ] Unit tests added/updated
- [ ] All tests passing

## Screenshots (if applicable)
[Add screenshots]

## Checklist
- [ ] Code follows project style
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
```

### PR Review Process

1. **Automated checks** must pass:
   - Code analysis
   - Tests
   - Build

2. **Code review** by maintainers
   - Address feedback
   - Make requested changes

3. **Approval and merge**
   - PR will be merged by maintainer
   - Your branch will be deleted

### After PR is Merged

1. **Update local repo:**
   ```bash
   git checkout main
   git pull upstream main
   ```

2. **Delete feature branch:**
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

## Testing

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

**Widget tests:**

```dart
testWidgets('Login button submits form', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Find widgets
  final loginButton = find.text('Login');
  
  // Interact
  await tester.tap(loginButton);
  await tester.pump();
  
  // Verify
  expect(find.text('Welcome'), findsOneWidget);
});
```

**Unit tests:**

```dart
test('User model serialization', () {
  final user = User(name: 'John', id: 1);
  final json = user.toJson();
  
  expect(json['name'], 'John');
  expect(json['id'], 1);
});
```

### Test Coverage

Aim for:
- **Controllers:** 80%+ coverage
- **Models:** 100% coverage
- **Widgets:** 60%+ coverage

## Documentation

### When to Update Documentation

Update documentation when:
- Adding new features
- Changing APIs
- Modifying architecture
- Fixing bugs that affect usage
- Adding configuration options

### Documentation Files

- **README.md** - Overview and quick start
- **docs/API.md** - API reference
- **docs/NFC_HCE.md** - NFC implementation
- **docs/ARCHITECTURE.md** - Architecture details
- **docs/SETUP.md** - Installation guide
- **docs/CONTRIBUTING.md** - This file

### Code Comments

Add comments for:
- Complex algorithms
- Non-obvious business logic
- Workarounds or hacks
- Public APIs

```dart
/// Authenticates user with backend API.
///
/// Throws [ApiException] if request fails.
/// Returns [User] object on success.
///
/// Example:
/// ```dart
/// final user = await authService.login('username', 'password');
/// ```
Future<User> login(String username, String password) async {
  // Implementation
}
```

## Issue Reporting

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Update to latest version** and test again
3. **Gather information:**
   - Flutter version
   - Device/emulator details
   - Steps to reproduce
   - Expected vs actual behavior

### Creating an Issue

Use appropriate template:

**Bug Report:**
```markdown
## Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Flutter version: 3.9.2
- Device: Pixel 6 (Android 13)
- App version: 1.0.0

## Screenshots
[Add if applicable]

## Additional Context
Any other relevant information
```

**Feature Request:**
```markdown
## Feature Description
Clear description of proposed feature

## Use Case
Why is this feature needed?

## Proposed Solution
How should it work?

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other relevant information
```

## Development Tips

### Hot Reload

Use hot reload for faster development:
```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

### Debugging

```dart
// Print debugging
debugPrint('Value: $value');

// Breakpoints in IDE
// Use Flutter DevTools for advanced debugging
```

### Performance

- Use `const` constructors where possible
- Avoid rebuilding entire widget tree
- Profile with `flutter run --profile`
- Use DevTools for performance analysis

### Best Practices

1. **Keep widgets small and focused**
2. **Extract repeated code into reusable components**
3. **Dispose controllers and resources**
4. **Handle errors gracefully**
5. **Write self-documenting code**
6. **Test on real devices**

## Recognition

Contributors will be:
- Listed in project credits
- Mentioned in release notes
- Recognized in the community

Thank you for contributing to UniCheck! 🎉

## Questions?

If you have questions:
- Check existing documentation
- Search closed issues
- Ask in issue comments
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
