# Contributing to Adiyok

Thanks for taking the time to contribute! This is a personal project built for my father, but improvements and suggestions are always welcome.

---

## 🐛 Reporting Bugs

Open a [GitHub Issue](https://github.com/YusufErdemK/adiyok/issues) and include:

- What you did
- What you expected to happen
- What actually happened
- Your platform (Android / Linux / etc.) and Flutter version

---

## 💡 Suggesting Features

Open an issue with the `enhancement` label. Describe the feature and why it would be useful.

---

## 🔧 Submitting a Pull Request

1. Fork the repo
2. Create a branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Commit with a clear message: `git commit -m "feat: add something useful"`
5. Push: `git push origin feat/your-feature`
6. Open a PR against `master`

### Commit Prefixes

| Prefix | When to use |
|--------|-------------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `refactor:` | Code restructure, no behavior change |
| `style:` | Formatting, UI tweaks |
| `chore:` | Maintenance, dependency updates |
| `docs:` | Documentation only |

---

## 🏗️ Project Structure

```
lib/
├── models/       # Data models
├── providers/    # State management (Provider)
├── screens/      # Full screens
├── services/     # Storage, sound
└── widgets/      # Reusable UI components
```

New files should follow the existing naming convention (`snake_case.dart`) and be placed in the appropriate folder.

---

## ✅ Code Style

- Follow standard Dart/Flutter conventions
- Run `flutter analyze` before submitting — no warnings allowed
- Use `colorScheme` for colors (no hardcoded `Colors.grey[x]`)
- Use `withValues(alpha:)` instead of `withOpacity()`

---

*This project is maintained by [YusufErdemK](https://github.com/YusufErdemK).*