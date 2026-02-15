# Veri Kalıcılığı İçin Detaylı Açıklama

## Mimari

```
UI (Screens)
    ↓
Providers (TreeProvider, TransactionProvider)
    ↓ (veri değişiklikleri)
StorageService
    ↓
SharedPreferences (cihaz depolaması)
```

## Veri Akışı

### Yazma (Saving)

```
Kullanıcı İşlem → addTransaction() → notifyListeners() 
                                    → _saveTransactionData()
                                    → StorageService.saveTransactionData()
                                    → JSON Serialize
                                    → SharedPreferences.setString()
```

### Okuma (Loading)

```
App Start → main() → StorageService.init()
                  → TransactionProvider constructor
                  → _initializeTransactions()
                  → StorageService.loadTransactionData()
                  → JSON Deserialize
                  → List<Transaction> populated
                  → notifyListeners() → UI güncellenir
```

## JSON Serialization Örneği

### Transaction

```json
{
  "id": "1707928800000",
  "title": "Maaş",
  "amount": 5000.0,
  "category": "salary",
  "date": "2026-02-15T10:30:00.000Z",
  "description": "Aylık maaş",
  "notes": null
}
```

### TreeNode (Nested)

```json
{
  "id": "uuid-here",
  "name": "Bahçem",
  "description": "Arka bahçe",
  "category": "Meyve Ağaçları",
  "createdAt": "2026-02-15T10:30:00.000Z",
  "isExpanded": true,
  "children": [
    {
      "id": "uuid-here",
      "name": "Elma Ağacı",
      "description": null,
      "category": null,
      "createdAt": "2026-02-15T10:30:00.000Z",
      "isExpanded": false,
      "children": []
    }
  ]
}
```

## SharedPreferences Storage Keys

- `tree_data` - Tüm ağaç verileri (JSON array)
- `transaction_data` - Tüm işlem kayıtları (JSON array)

## Hata Handling

StorageService try-catch blokları ile hataları yakalar:

```dart
try {
  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  return jsonList.map((json) => TreeNode.fromJson(json)).toList();
} catch (e) {
  print('Error loading tree data: $e');
  return [];  // Boş liste döndür
}
```

## Performance Considerations

### Avantajlar
- **Yerel Depolama** - Server iletişimi yok
- **Hızlı Erişim** - RAM'de tutuluyordu zaten
- **Küçük Veri Boyutu** - JSON formatında kompakt

### Sınırlamalar
- **SharedPreferences Boyutu** - Cihaza bağlı (genelde 5-10MB)
- **Async Operations** - Init işlemi async, UI'de yükleniyor gösterebilir
- **Serialization Zeit** - Çok büyük veri setleri için dikkat gerekir

## Future Improvements

1. **Database Migration** - SQLite/Hive için daha iyi performans
2. **Cloud Sync** - Firebase gibi cloud depolaması
3. **Backup & Restore** - Veri yedekleme özelliği
4. **Encryption** - Hassas verilerin şifrelenmesi
5. **Compression** - Büyük veri setleri için sıkıştırma
