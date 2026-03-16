# Developing Adiyok

## Prerequisites

- Flutter 3.10.4+
- Dart 3.0+

```bash
flutter --version
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── main.dart
├── demo_data.dart
├── models/
│   ├── card_model.dart        # BankName enum, CardModel
│   ├── transaction.dart       # Transaction, TransactionCategory
│   └── tree_node.dart         # TreeNode (recursive)
├── providers/
│   ├── bill_provider.dart     # Bill, BillPayment, BillType
│   ├── settings_provider.dart # Theme mode
│   ├── transaction_provider.dart
│   ├── tree_provider.dart
│   └── wallet_provider.dart   # Account, PiggyBank, CardModel state
├── screens/
│   ├── about_screen.dart
│   ├── bills_tab.dart
│   ├── home_screen.dart
│   ├── settings.dart
│   ├── summary_screen.dart
│   ├── transaction_screen.dart
│   ├── tree_screen.dart
│   └── wallet_screen.dart
├── services/
│   ├── sound_service.dart
│   └── storage_service.dart   # SharedPreferences wrapper
└── widgets/
    ├── add_transaction_dialog.dart
    ├── glass_card.dart
    ├── options_menu.dart
    ├── stats_summary.dart
    ├── transaction_card.dart
    └── tree_node_widget.dart
```

---

## State Management

5 providers, all `ChangeNotifier`, registered in `main.dart` via `MultiProvider`:

| Provider | Owns |
|----------|------|
| `TreeProvider` | Tree nodes (recursive) |
| `TransactionProvider` | Income/expense transactions |
| `BillProvider` | Bills + monthly payment records |
| `WalletProvider` | Cards, accounts, piggy banks, balance |
| `SettingsProvider` | Theme mode |

Every provider loads from `SharedPreferences` on construction and saves after every mutation.

---

## Data Persistence

All data is stored locally via `SharedPreferences` as JSON. See [DATA_PERSISTENCE.md](DATA_PERSISTENCE.md) for the full breakdown.

---

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Linux
flutter build linux --release
```

---

## Troubleshooting

```bash
# Clean build
flutter clean && flutter pub get && flutter run

# Analyze
flutter analyze
```

**GStreamer audio error on Linux** — wrap the audio player call in a try/catch. Missing GStreamer plugins won't crash the app.