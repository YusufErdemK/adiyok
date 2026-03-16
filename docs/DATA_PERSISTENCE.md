# Data Persistence

Adiyok stores all data locally on the device using `shared_preferences`. No internet connection or account required.

---

## What Gets Saved

| Data | Key | Provider |
|------|-----|----------|
| Tree nodes | `tree_data` | `TreeProvider` |
| Transactions | `transactions` | `TransactionProvider` |
| Bills & payments | `bills_data` | `BillProvider` |
| Cards | `wallet_cards` | `WalletProvider` |
| Accounts | `wallet_accounts` | `WalletProvider` |
| Piggy banks | `wallet_piggy_banks` | `WalletProvider` |
| Manual balance | `wallet_manual_balance` | `WalletProvider` |
| Theme setting | `theme_mode` | `SettingsProvider` |

---

## How It Works

Every provider loads its data from `SharedPreferences` on startup and saves automatically after every mutation.

```
App launch
  └─ StorageService.init()
  └─ Each provider calls _load() in constructor
        └─ JSON → model objects → in-memory list

User action (add / edit / delete)
  └─ Provider updates in-memory list
  └─ notifyListeners()
  └─ _save() → model objects → JSON → SharedPreferences
```

---

## Storage Service

`lib/services/storage_service.dart` is a thin wrapper around `SharedPreferences` that handles initialization and raw JSON read/write for tree and transaction data.

All other providers (Wallet, Bill, Settings) manage their own persistence directly.

---

## Models & Serialization

Every model implements `toJson()` and `fromJson()`:

- `TreeNode` — recursive serialization (children included)
- `Transaction` — includes `TransactionCategory.fromString()` for enum parsing
- `Bill` + `BillPayment` — payment history per month
- `Account` — includes `parentId` for tree structure
- `CardModel`, `PiggyBank` — straightforward flat serialization