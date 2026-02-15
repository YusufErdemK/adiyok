# Veri Kalıcılığı Uygulaması - Özet

## Problem
Adiyok uygulaması kapandığında tüm kullanıcı verileri (ağaç nodu ve işlem kayıtları) siliniyordu çünkü veriler sadece RAM'de tutuluyordu.

## Çözüm
`shared_preferences` paketi kullanarak tüm verileri cihaz depolamasına kaydediyoruz.

## Yapılan Değişiklikler

### 1. **pubspec.yaml**
   - `shared_preferences: ^2.2.0` bağımlılığı eklendi

### 2. **Yeni Dosya: lib/services/storage_service.dart**
   - Verileri kaydetmek ve yüklemek için merkezi hizmet
   - Yöntemler:
     - `init()` - SharedPreferences başlat
     - `saveTreeData()` - Ağaç verisini kaydet
     - `loadTreeData()` - Ağaç verisini yükle
     - `saveTransactionData()` - İşlem verisini kaydet
     - `loadTransactionData()` - İşlem verisini yükle
     - `clearAllData()` - Tüm verileri sil

### 3. **lib/models/transaction.dart**
   - Serialization yöntemleri eklendi:
     - `toJson()` - JSON'a dönüştür
     - `fromJson()` - JSON'dan yükle
   - `TransactionCategory.fromString()` - Kategori stringi parse et

### 4. **lib/models/tree_node.dart**
   - Serialization yöntemleri eklendi:
     - `toJson()` - JSON'a dönüştür (recursive)
     - `fromJson()` - JSON'dan yükle (recursive)

### 5. **lib/providers/tree_provider.dart**
   - `_isLoading` boolean eklendi
   - Constructor'da async veri yükleme işlemi
   - Tüm veri değiştirme işlemlerinde otomatik kayıt:
     - `addRoot()` → `_saveTreeData()`
     - `addChild()` → `_saveTreeData()`
     - `deleteNode()` → `_saveTreeData()`
     - `updateNode()` → `_saveTreeData()`
     - `toggleNodeExpansion()` → `_saveTreeData()`

### 6. **lib/providers/transaction_provider.dart**
   - `_isLoading` boolean eklendi
   - Constructor'da async veri yükleme işlemi
   - Tüm veri değiştirme işlemlerinde otomatik kayıt:
     - `addTransaction()` → `_saveTransactionData()`
     - `deleteTransaction()` → `_saveTransactionData()`
     - `updateTransaction()` → `_saveTransactionData()`
     - `clearAllTransactions()` → `_saveTransactionData()`

### 7. **lib/main.dart**
   - `WidgetsFlutterBinding.ensureInitialized()` eklendi
   - `StorageService.init()` çağrıldı (app başlatmadan önce)

## Nasıl Çalışır

1. **Uygulama Başlangıcı:**
   - `StorageService.init()` SharedPreferences başlatır
   - `TreeProvider` ve `TransactionProvider` localStorage'dan verileri yüklenir
   - Veriler RAM'e yüklenir

2. **Veri Girişi:**
   - Kullanıcı yeni ağaç/işlem eklediğinde
   - Provider otomatik olarak `_saveTreeData()` veya `_saveTransactionData()` çağırır
   - Veriler JSON formatında localStorage'a kaydedilir

3. **Uygulama Kapatılması & Yeniden Açılması:**
   - Veriler localStorage'dan otomatik olarak yüklenir
   - Kullanıcının yaptığı tüm değişiklikler korunur

## Avantajlar

✅ **Otomatik Kayıt** - Her veri değişikliği otomatik kaydedilir  
✅ **Veri Güvenliği** - Veriler cihaz depolamasında güvenli şekilde saklanır  
✅ **Performans** - JSON serialization hızlı ve efficient  
✅ **Offline Çalışma** - İnternet bağlantısı gerekmez  
✅ **Backward Compatible** - Mevcut UI/UX değişikliği yok  

## Test Etme

Uygulamayı test etmek için:

```bash
cd /home/erdem/adiyok
flutter pub get
flutter run
```

1. Ağaç düğümü ekle
2. İşlem kaydı ekle
3. Uygulamayı kapat (Ctrl+C)
4. Uygulamayı tekrar açt (flutter run)
5. Veriler korunmuş olmalı ✓
