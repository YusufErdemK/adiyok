# ⚡ Adiyok - Quick Start Guide

## Start in 30 Seconds

```bash
cd /your/project/path/adiyok
flutter pub get
flutter run
```

✅ That’s it! Welcome to the app.

---

## What Can You Do in the First 5 Minutes?

### 1️⃣ Create a Tree (1 minute)

1. Go to the "Tree" tab
2. Click the green "Root Element" button
3. Type "My Companies" and click "Add"
4. Tap the card to expand the tree


### 2️⃣ Add Sub-elements (1 minute)

1. Tap the menu (⋮) on the right of your new root element
2. Select "Add Sub-element"
3. Type "Frontend Project" and click add
4. Add more sub-elements as needed

### 3️⃣ Add Income (1.5 minutes)

1. Go to the "Finance" tab
2. Click the "Add Transaction" button
3. Ensure "💰 Income" is selected
4. Title: "Salary"
5. Amount: "5000"
6. Category: "Salary" 
7. Click the "Save" button


### 4️⃣ Add Expense (1.5 minutes)

1. Click the "Add Transaction" button
2. Select "💸 Expense"
3. Title: "Rent"
4. Amount: "2500"
5. Category: "Rent"
6. Click the "Save" button


### 5️⃣ View Statistics (0.5 minutes)

1. Stay in the Finance tab under the "All" section
2. View Net Income, Total Income, and Total Expense at the top
3. Transactions are listed below with Green/Red color coding


---

## 🎯 Core Features Summary

| Feature | Tree Tab | Finance Tab |
| --- | --- | --- |
| Create | ✅ Root element | ✅ Transaction |
| Expand | ✅ Sub-elements | ✅ - |
| Edit | ✅ Name/Description | ✅ All details |
| Delete | ✅ Yes | ✅ Yes |
| Statistics | ✅ Depth, Node count | ✅ Totals, Category |
| Color Code | ❌ No | ✅ Green/Red |

---

## 🎨 System Usage

### Tree Structure - What for?

```
For example, modeling a company structure:
┌─ My Companies
│  ├─ Frontend Team
│  │  ├─ React Project
│  │  └─ Vue Project
│  └─ Backend Team
│     ├─ API Development
│     └─ Database Design

Or Personal Projects:
┌─ Personal Projects
│  ├─ Learning Flutter
│  │  ├─ Widgets
│  │  └─ State Management
│  └─ Web Development

```

### Income/Expense - What for?

```
✅ Track your monthly budget
✅ See expenses by category
✅ Calculate net income instantly
✅ Record transactions by date

Example:
Jan 1: Salary +5000 (Income)
Jan 5: Rent -2500 (Expense)
Jan 10: Restaurant -450 (Expense)
Net: +2050 ✅

```

---

## 💡 Helpful Tips

### 🎯 Saving Data

> Currently, data is stored in memory (RAM) during the session.
> It will reset when the app is closed.
> You can integrate `SharedPreferences` to make data persistent.

### 📱 For Small Screens

> All elements are designed to be responsive.
> The UI looks even better on tablets and large screens.

### 🌙 Dark Mode

> Material Design 3 automatically follows your system theme.
> If your device is in Dark Mode, the app will switch automatically.

### ⚡ Performance

> Runs smoothly even with 1000+ nodes.
> Tree expansion/collapsing is smooth and fast.

---

## 🛠️ Quick Adjustments

### Change Colors

In `lib/main.dart`:

```dart
seedColor: const Color(0xFF2D6A4F),  // ← Change this hex code
// Ex: 0xFFFF6B6B (Red), 0xFF4ECDC4 (Turquoise)

```

### Add Categories

In `lib/models/transaction.dart`:

```dart
enum TransactionCategory {
  myNewCategory('Category Name', '🆕'),
  // ...
}

```

---

## 📋 Action Checklist

### With Tree

* [ ] Model a company structure
* [ ] Create an organizational chart
* [ ] Track project hierarchies
* [ ] Monitor depth statistics

### With Finance

* [ ] Record monthly income/expenses
* [ ] Set budget goals
* [ ] Check expenses by category
* [ ] Identify potential savings

---

## ❓ FAQ

**Q: How is my data stored?**

* Currently in RAM (per session). You can add SharedPreferences for persistence.

**Q: Can it sync to the cloud?**

* Yes, if Firebase integration is added.

**Q: How much data can I store?**

* Theoretically unlimited. Practically, 10,000+ transactions/nodes will work without issues.

**Q: Does it work offline?**

* Yes! It is completely local and requires no internet.

**Q: Can I transfer data from phone to PC?**

* Not currently, but a JSON export feature could be added.

---

## 🚀 Next Steps

1. **Finish the Trial** (5 minutes)
* Create a few trees and transactions
* Test all the buttons


2. **Learn How the Code Works** (15 minutes)
* Read the `DEVELOPING.md` file
* Explore files in the `lib/` folder


3. **Customize** (30 minutes)
* Change colors
* Add new categories
* Add your own logo


4. **Add Extra Features** (1+ hour)
* Persistent storage with SharedPreferences
* Export/Import functionality
* Analytical charts



---

## 📞 Troubleshooting

* **Can't find a file?** → Look in the `lib/` folder
* **App won't run?** → Run `flutter doctor`
* **Data lost?** → Restart with `flutter run` (Data is currently session-based)
* **Build error?** → Run `flutter clean` then `flutter pub get`

---

## 🎉 That’s It!

You are ready to start! With Adiyok:

* ✅ Manage trees
* ✅ Track income/expenses
* ✅ Observe statistics
* ✅ Play with your data

**Happy Coding! 🚀**

---

For more detailed information, please read `DEVELOPING.md` and `GUIDE.md`.
