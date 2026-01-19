# 🚀 Adiyok Uygulaması - Başlama ve Geliştirme Rehberi

## İçindekiler
1. [Kurulum](#kurulum)
2. [Çalıştırma](#çalıştırma)
3. [Proje Yapısı](#proje-yapısı)
4. [Ana Bileşenler](#ana-bileşenler)
5. [State Management](#state-management)
6. [Özelleştirme](#özelleştirme)
7. [Sorun Giderme](#sorun-giderme)

---

## Kurulum

### Ön Koşullar
```bash
# Flutter versiyonunuzu kontrol edin
flutter --version
# Çıkış: Flutter 3.10.4 veya daha yeni

# Dart versiyonunuzu kontrol edin  
dart --version
# Çıkış: Dart 3.0 veya daha yeni
```

### Adımlar
1. **Repository'i klonlayın veya açın**
```bash
cd /home/erdem/adiyok
```

2. **Paketleri yükleyin**
```bash
flutter pub get
```

3. **Eğer iOS için çalıştıracaksanız**
```bash
cd ios
pod install
cd ..
```

---

## Çalıştırma

### Android
```bash
flutter run
# veya
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d web
```

### Release Mode
```bash
flutter run --release
```

### Emülatör/Simulator Seçme
```bash
# Mevcut cihazları listele
flutter devices

# Spesifik cihazda çalıştır
flutter run -d <device_id>
```

---

## Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası
│   └── MultiProvider ile state setup
│
├── models/                            # Veri modelleri
│   ├── tree_node.dart                # Ağaç nodu modeli
│   │   ├── TreeNode class
│   │   ├── ID, name, description, children
│   │   ├── Helper methods (findNodeById, getDepth, vb)
│   │   └── copyWith for immutability
│   │
│   └── transaction.dart              # İşlem ve kategori
│       ├── TransactionCategory enum (14 kategori)
│       └── Transaction class
│
├── providers/                         # State Management (Provider)
│   ├── tree_provider.dart            # Ağaç state'i yönet
│   │   ├── CRUD operasyonları (Create, Read, Update, Delete)
│   │   ├── Node expansion/collapse
│   │   ├── Selection management
│   │   └── Statistics (depth, count)
│   │
│   └── transaction_provider.dart     # İşlem state'i yönet
│       ├── Transaction CRUD
│       ├── Income/Expense filtering
│       ├── Category breakdown
│       ├── Date range queries
│       └── Financial calculations
│
├── screens/                           # Tam ekranlar
│   ├── home_screen.dart              # Ana sayfa (Navigation)
│   ├── tree_screen.dart              # Ağaç yönetimi
│   └── transaction_screen.dart       # Gelir/Gider takibi
│
├── widgets/                           # Tekrar kullanılabilir bileşenler
│   ├── glass_card.dart               # Şeffaf kart widget
│   ├── tree_node_widget.dart         # Ağaç nodu görüntüleme
│   ├── transaction_card.dart         # İşlem kartı
│   ├── stats_summary.dart            # İstatistik özetleme
│   └── add_transaction_dialog.dart   # İşlem dialog'u
│
└── demo_data.dart                    # Demo veri oluşturma
```

---

## Ana Bileşenler

### TreeNode Model
```dart
class TreeNode {
  final String id;                    // UUID v4
  final String name;                  // Eleman adı
  final String? description;          // Opsiyonel açıklama
  final List<TreeNode> children;      // Alt elemanlar
  final DateTime createdAt;           // Oluşturma tarihi
  bool isExpanded;                    // Genişletilmiş mi?
}
```

**Önemli Metodlar:**
- `addChild(TreeNode)` - Alt eleman ekle
- `removeChild(String)` - Alt eleman sil
- `findNodeById(String)` - Recursive arama
- `getDepth()` - Ağaç derinliği
- `getTotalNodeCount()` - Toplam nod sayısı

### Transaction Model
```dart
class Transaction {
  final String id;                    // Timestamp-based ID
  final String title;                 // İşlem başlığı
  final double amount;                // Para miktarı
  final TransactionCategory category; // Kategori (enum)
  final DateTime date;                // İşlem tarihi
  final String? description;          // Opsiyonel açıklama
  final String? notes;                // Opsiyonel notlar
}
```

**Kategori Özellikleri:**
- `TransactionCategory.isIncome` - Gelir mi?
- `TransactionCategory.isExpense` - Gider mi?
- `TransactionCategory.emoji` - Kategori emoji'si
- `TransactionCategory.label` - Kategori adı

### TreeProvider
```dart
// Temel işlemler
addRoot(String name, {String? description})
addChild(String parentId, String childName, {String? description})
deleteNode(String nodeId)
updateNode(String nodeId, String newName, {String? newDescription})
selectNode(String nodeId)
toggleNodeExpansion(String nodeId)

// Sorgular
getTotalNodeCount()
getMaxTreeDepth()
```

### TransactionProvider
```dart
// İşlem yönetimi
addTransaction(Transaction)
deleteTransaction(String id)
updateTransaction(String id, Transaction)

// Hesaplamalar
get totalIncome           // Toplam gelir
get totalExpense          // Toplam gider
get netIncome             // Net gelir
getCategoryTotal(category) // Kategori toplamı

// Filtreleme
getTransactionsByDateRange(start, end)
getCurrentMonthTransactions()
getTransactionsByCategory(category)
```

---

## State Management

### Provider Pattern Kullanımı

**1. Provider Wrap (main.dart)**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TreeProvider()),
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
  ],
  child: MaterialApp(...)
)
```

**2. Consumer ile Dinleme**
```dart
Consumer<TreeProvider>(
  builder: (context, treeProvider, _) {
    // treeProvider.roots, selectedNode, vb erişebilirsin
    return ListView(...)
  }
)
```

**3. Direct Erişim**
```dart
context.read<TreeProvider>().addRoot('Yeni Kök');
context.watch<TransactionProvider>().totalIncome;
```

**4. Değişiklik Bildirme**
```dart
// Provider'da
notifyListeners();  // Tüm listeners'a bildir
```

---

## Özelleştirme

### Renkleri Değiştir

**main.dart'ta ColorScheme'i değiştir:**
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF2D6A4F),  // ← Burası
  brightness: Brightness.light,
)
```

### Kategoriler Ekle/Sil

**lib/models/transaction.dart**
```dart
enum TransactionCategory {
  // Yeni kategori ekle
  freelance('Serbest Çalışma', '💻'),
  // veya var olanı sil
  
  // Gerisi otomatik olarak isIncome/isExpense olacak
}
```

### Tema Değiştir

**main.dart'ta ThemeData'yı özelleştir:**
```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ...,
  textTheme: GoogleFonts.poppinsTextTheme(...),
  // Diğer ayarlar
)
```

### Dil Desteği Ekle

**pubspec.yaml'a ekle:**
```yaml
dependencies:
  intl: ^0.19.0  # Zaten var
  flutter_localizations:
    sdk: flutter
```

---

## Sorun Giderme

### "Provider not found" Hatası
**Sebep:** Widget'ın MultiProvider'ın dışında
**Çözüm:**
```dart
// ❌ Yanlış
MultiProvider(providers: [...], child: MyApp())
// App build etmiş

// ✅ Doğru
MultiProvider(providers: [...], child: MaterialApp(...))
```

### Ağaç güncellenmiyor
**Sebep:** Node reference'ı değişti ama list güncellenmiyor
**Çözüm:**
```dart
// ❌ Yanlış
node.name = 'Yeni Ad';
notifyListeners();

// ✅ Doğru
_roots[index] = node.copyWith(name: 'Yeni Ad');
notifyListeners();
```

### Performance Problemi
- Büyük listelerde `ListView.builder` kullan
- Gereksiz rebuild'den kaçın → `selector` veya `Consumer` kullan
- Image caching kontrol et

### Build Hatası
```bash
# Clean et
flutter clean

# Pub get
flutter pub get

# Build tekrar dene
flutter run
```

### iOS Pod Hatası
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter run
```

---

## İleri Konular

### Custom Ağaç Traversal

```dart
void traverseTree(TreeNode root, Function(TreeNode) callback) {
  callback(root);
  for (var child in root.children) {
    traverseTree(child, callback);
  }
}

// Kullanım
traverseTree(treeRoot, (node) {
  print('Ziyaret edilen: ${node.name}');
});
```

### Ağaç Serilize Etme (Future)

```dart
// JSON'a çevir
String serializeTree(TreeNode root) {
  return jsonEncode({
    'id': root.id,
    'name': root.name,
    'children': root.children.map(serializeTree).toList(),
  });
}
```

### Veri Kalıcılaştırma (SharedPreferences)

```dart
// pubspec.yaml'a ekle
shared_preferences: ^2.0.0

// Provider'da
Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('trees', jsonEncode(_roots));
}
```

---

## Performans İpuçları

1. **Lazy Loading**: Büyük ağaçlarda sadece görünür kısım render et
2. **Image Caching**: Network image'leri cache'le
3. **Memoization**: Sık hesaplamalar için sonuçları cache'le
4. **Debouncing**: TextEdit gibi sık input'ta debounce koy

---

## Test Yazma

```dart
testWidgets('Kök eleman ekle', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  // FAB'ı tıkla
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  // Input'a yaz
  await tester.enterText(find.byType(TextField), 'Test Kök');
  
  // Ekle buttonuna tıkla
  await tester.tap(find.byWidgetPredicate(
    (w) => w is ElevatedButton && w.child is Text
  ));
  await tester.pumpAndSettle();
  
  // Doğrula
  expect(find.text('Test Kök'), findsOneWidget);
});
```

---

## Kaynaklar

- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
- [Dart Docs](https://dart.dev/guides)

---

**Son Güncelleme:** Ocak 2026  
**Sürüm:** 1.0.0
