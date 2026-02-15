# Veri Kalıcılığı - Kod Örnekleri

## 1. StorageService Kullanımı

### Veri Kaydetme

```dart
// Otomatik - providers tarafından çağrılır
await StorageService.saveTreeData(_roots);
await StorageService.saveTransactionData(_transactions);
```

### Veri Yükleme

```dart
// Otomatik - app başlangıcında çağrılır
List<TreeNode> roots = await StorageService.loadTreeData();
List<Transaction> transactions = await StorageService.loadTransactionData();
```

### Veri Silme

```dart
await StorageService.clearAllData();
```

## 2. Transaction Serialization Örneği

### Kaydetmek

```dart
Transaction transaction = Transaction(
  title: 'Maaş',
  amount: 5000,
  category: TransactionCategory.salary,
  description: 'Aylık maaş',
);

// Otomatik olarak JSON'a dönüştürülür ve kaydedilir
transactionProvider.addTransaction(transaction);
```

### Geri Yüklemek

```dart
// StorageService otomatik olarak JSON'dan deserialize eder
Map<String, dynamic> json = {
  'id': '1707928800000',
  'title': 'Maaş',
  'amount': 5000.0,
  'category': 'salary',
  'date': '2026-02-15T10:30:00.000Z',
  'description': 'Aylık maaş',
  'notes': null,
};

Transaction transaction = Transaction.fromJson(json);
```

## 3. TreeNode Serialization Örneği

### Kaydı (Recursive)

```dart
TreeNode root = TreeNode(
  name: 'Bahçem',
  description: 'Arka bahçe ağaçları',
);

TreeNode child1 = TreeNode(name: 'Elma Ağacı');
TreeNode child2 = TreeNode(name: 'Mango Ağacı');

root.addChild(child1);
root.addChild(child2);

// Otomatik olarak tüm ağaç recursive olarak kaydedilir
treeProvider.addRoot('Bahçem', description: 'Arka bahçe ağaçları');
```

### Geri Yüklemek

```dart
// Nested JSON örneği
Map<String, dynamic> rootJson = {
  'id': 'uuid-123',
  'name': 'Bahçem',
  'description': 'Arka bahçe ağaçları',
  'category': null,
  'createdAt': '2026-02-15T10:30:00.000Z',
  'isExpanded': true,
  'children': [
    {
      'id': 'uuid-456',
      'name': 'Elma Ağacı',
      'description': null,
      'category': null,
      'createdAt': '2026-02-15T10:31:00.000Z',
      'isExpanded': false,
      'children': [],
    },
  ],
};

// Recursive olarak deserialize edilir
TreeNode root = TreeNode.fromJson(rootJson);
// root.children[0] automatically populated
```

## 4. Provider Kullanımı

### TreeProvider Örneği

```dart
// UI'de
class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TreeProvider>(
      builder: (context, treeProvider, child) {
        // Loading state
        if (treeProvider.isLoading) {
          return const CircularProgressIndicator();
        }

        // Ağaç verileri kullan
        return ListView(
          children: treeProvider.roots.map((root) {
            return TreeNodeWidget(root);
          }).toList(),
        );
      },
    );
  }
}

// Veri ekle
treeProvider.addRoot(
  'Yeni Ağaç',
  description: 'Açıklama',
  category: 'Kategori',
); // Otomatik kaydedilir

// Veri sil
treeProvider.deleteNode(nodeId); // Otomatik kaydedilir

// Veri güncelle
treeProvider.updateNode(
  nodeId,
  'Yeni Ad',
  newDescription: 'Yeni açıklama',
); // Otomatik kaydedilir
```

### TransactionProvider Örneği

```dart
// UI'de
class TransactionListWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        // Loading state
        if (transactionProvider.isLoading) {
          return const CircularProgressIndicator();
        }

        // Tüm işlemler
        final transactions = transactionProvider.transactions;
        
        // Sadece gelirler
        final incomes = transactionProvider.incomes;
        
        // Sadece giderler
        final expenses = transactionProvider.expenses;

        return ListView(
          children: transactions.map((t) {
            return TransactionCard(transaction: t);
          }).toList(),
        );
      },
    );
  }
}

// Veri ekle
transactionProvider.addTransaction(Transaction(
  title: 'Proje Geliri',
  amount: 5000,
  category: TransactionCategory.freelance,
)); // Otomatik kaydedilir

// Veri sil
transactionProvider.deleteTransaction(transactionId); // Otomatik kaydedilir

// Veri güncelle
transactionProvider.updateTransaction(
  transactionId,
  updatedTransaction,
); // Otomatik kaydedilir
```

## 5. Main Fonksiyonu

```dart
void main() async {
  // UI bindings başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // Storage service başlat
  await StorageService.init();
  
  // Locale formatting başlat
  await initializeDateFormatting('tr_TR');
  
  // App başlat
  runApp(const MyApp());
}
```

## 6. Error Handling Örneği

```dart
// StorageService otomatik olarak hataları ele alır
Future<List<TreeNode>> loadTreeData() async {
  final jsonString = _prefs.getString(_treeDataKey);
  if (jsonString == null) return []; // Boş liste dön
  
  try {
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => TreeNode.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Error loading tree data: $e');
    return []; // Boş liste dön (fallback)
  }
}
```

## 7. Loading State UI Örneği

```dart
// Providers init sırasında
class TransactionProvider extends ChangeNotifier {
  bool _isLoading = true;
  
  TransactionProvider({TreeProvider? treeProvider}) : _treeProvider = treeProvider {
    _initializeTransactions();
  }

  Future<void> _initializeTransactions() async {
    _transactions.clear();
    _transactions.addAll(await StorageService.loadTransactionData());
    _isLoading = false;
    notifyListeners(); // UI güncellenir
  }
}

// UI'de loading kontrolü
Consumer<TransactionProvider>(
  builder: (context, transactionProvider, child) {
    if (transactionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Veriler yüklenmiş, göster
    return TransactionList(transactions: transactionProvider.transactions);
  },
)
```

## 8. Veri Silme Örneği

```dart
// Tüm verileri sil
class SettingsScreen extends StatelessWidget {
  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text('Bu işlem geri alınamaz!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<TreeProvider>().clearAllTrees();
              context.read<TransactionProvider>().clearAllTransactions();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm veriler silindi')),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _clearAllData(context),
      child: const Text('Tüm Verileri Sil'),
    );
  }
}
```

## 9. Veri İstatistikleri Görüntüleme

```dart
// Kaydedilen veri boyutunu kontrol et
Future<void> checkStorageSize() async {
  final prefs = await SharedPreferences.getInstance();
  
  final treeJson = prefs.getString('tree_data');
  final transactionJson = prefs.getString('transaction_data');
  
  print('Tree data size: ${treeJson?.length} bytes');
  print('Transaction data size: ${transactionJson?.length} bytes');
}
```
