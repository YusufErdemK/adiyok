# 🌳 Adiyok - Ağaç & Gelir/Gider Yönetim Uygulaması

Adiyok, kullanıcıların ağaç yapısı oluşturması ve yönetmesi ile birlikte gelir ve gider takibi yapabileceği, modern ve güzel bir Flutter uygulamasıdır.

## ✨ Temel Özellikler

### 🌳 Ağaç Yapısı (Tree Management)
- ✅ **Kök Eleman Ekleme**: Kolayca yeni ağaç kökü oluşturun
- ✅ **Hiyerarşik Yapı**: Her eleman içine sınırsız alt eleman ekleyebilirsiniz
- ✅ **Genişlet/Daralt**: ExpansionTile animasyonları ile hiyerarşiyi yönetin
- ✅ **Düzenleme ve Silme**: Herhangi bir nodu silip/düzenleyebilirsiniz
- ✅ **Detaylı Bilgiler**: Her nod için açıklama ve istatistik gösterir
- ✅ **Smooth Animasyonlar**: 300ms smooth rotasyon ve boyut geçişleri

### 💰 Gelir ve Gider Takibi
- ✅ **Gelir Ekleme**: 5 farklı gelir kategorisi (Maaş, Serbest Çalışma, İş, Yatırım, Diğer)
- ✅ **Gider Ekleme**: 8 farklı gider kategorisi (Kira, Yemek, Ulaşım, Faturalar, Eğlence, Alışveriş, Sağlık, Eğitim)
- ✅ **Renk Kodlaması**: Yeşil (Gelir), Kırmızı (Gider)
- ✅ **Emoji İkonlar**: Her kategori için benzersiz emoji gösterimi
- ✅ **Net Gelir Hesaplaması**: Otomatik gelir/gider hesaplaması
- ✅ **Tarih Seçimi**: Her işlem için özel tarih seçebilirsiniz
- ✅ **Kategori Bazında İstatistik**: Kategoriler bazında toplam tutarları görün
- ✅ **Filtreleme**: Tüm işlemler, sadece gelirler, sadece giderler sekmelerine göre filtreleme

## 📱 Ekranlar

### Ana Sayfa (Home Screen)
- Alt navigasyon bar'ı ile iki ana bölüm arasında gezinme
- Smooth geçişler

### 🌳 Ağaç Yapısı Ekranı (Tree Screen)
- Kök elemanlar ve hiyerarşik yapısını görüntüle
- Her elemanda:
  - Ad ve açıklama
  - Toplam nod sayısı ve derinlik göstergesi
  - Menü butonları (Alt eleman ekle, Sil)
- Ağaç istatistikleri: Toplam kök sayısı, Toplam nod sayısı, Max derinlik
- Floating Action Button ile yeni kök eleman ekleme

### 💰 Gelir/Gider Ekranı (Transaction Screen)
- 3 sekme ile organize:
  1. **Tümü**: Tüm işlemler (gelir + gider)
  2. **💰 Gelir**: Sadece gelir işlemleri
  3. **💸 Gider**: Sadece gider işlemleri
  
- İstatistikler:
  - Net Gelir (Yeşil/Kırmızı ile gösterilen)
  - Toplam Gelir
  - Toplam Gider
  
- İşlem Kartları:
  - Kategori emoji'si
  - Başlık ve kategori adı
  - Tutar (+/- ile gösterilen)
  - Tarih
  - Açıklama (opsiyonel)
  - Düzenle/Sil seçenekleri
  
- Kategori Özeti: Her kategori için toplam tutarlar
- Floating Action Button ile yeni işlem ekleme

## 🛠️ Teknik Detaylar

### Kullanılan Teknolojiler
- **Framework**: Flutter 3.10.4+
- **State Management**: Provider (ChangeNotifier)
- **UI Framework**: Material Design 3
- **Tarih Formatı**: intl package (Türkçe)
- **Font**: Google Fonts (Poppins)
- **ID Oluşturma**: UUID v4

### Paket Bağımlılıkları
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.0.0
  provider: ^6.0.0
  intl: ^0.19.0
  uuid: ^4.0.0
```

### Proje Yapısı
```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/
│   ├── tree_node.dart          # Ağaç nodu modeli
│   └── transaction.dart        # İşlem modeli ve kategori enum'u
├── providers/
│   ├── tree_provider.dart      # Ağaç state yönetimi
│   └── transaction_provider.dart # İşlem state yönetimi
├── screens/
│   ├── home_screen.dart        # Ana sayfa (navigasyon)
│   ├── tree_screen.dart        # Ağaç yapısı ekranı
│   └── transaction_screen.dart # Gelir/Gider ekranı
└── widgets/
    ├── glass_card.dart         # Şeffaf kartlar bileşeni
    ├── tree_node_widget.dart   # Ağaç nodu widget'ı
    ├── transaction_card.dart   # İşlem kartı widget'ı
    ├── stats_summary.dart      # İstatistik özeti widget'ı
    └── add_transaction_dialog.dart # İşlem ekleme dialog'u
```

## 🎨 Tasarım Özellikleri

### Renkler
- **Primary**: #2D6A4F (Yeşil - Doğal tema)
- **Gelir**: Yeşil tonları
- **Gider**: Kırmızı tonları
- **Vurgu**: Orange tonları

### Animasyonlar
- **Genişlet/Daralt**: 300ms smooth rotasyon
- **Boyut Geçişi**: SizeTransition ile smooth çoktoplama
- **Temel Geçişler**: Material geçişleri

### Glass Morphism
- Hafif şeffaflık (alpha: 230/255)
- Yumuşak gölgeler
- Yuvarlatılmış köşeler (16px)
- Seçili durumlarda border vurgusu

## 📖 Kullanım Rehberi

### Ağaç Oluşturma
1. "Ağaç" sekmesine gidin
2. "Kök Eleman" butonuna tıklayın
3. Ad ve açıklamayı girin
4. "Ekle" butonuna tıklayın
5. Kök elemanın menüsünden "Alt Eleman Ekle"ye tıklayıp alt eleman ekleyin

### İşlem Ekleme
1. "Finans" sekmesine gidin
2. "İşlem Ekle" butonuna tıklayın
3. Gelir veya Gider seçin
4. Başlık, tutar, kategori seçin
5. Tarih seçebilirsiniz (varsayılan: bugün)
6. Opsiyonel açıklama/notlar ekleyin
7. "Kaydet" butonuna tıklayın

### İşlem Yönetimi
- **Düzenleme**: İşlem kartındaki menu butonundan "Düzenle"yi seçin
- **Silme**: İşlem kartındaki menu butonundan "Sil"i seçin
- **Filtreleme**: Sekmeleri kullanarak Gelir/Gider/Tümü görüntüleyin

## 🚀 Başlama

### Gereksinimler
- Flutter SDK: 3.10.4 veya daha yeni
- Dart: 3.0 veya daha yeni

### Kurulum ve Çalıştırma

```bash
# Paketleri yükle
flutter pub get

# Uygulamayı çalıştır (Android)
flutter run -d android

# Uygulamayı çalıştır (iOS)
flutter run -d ios

# Uygulamayı çalıştır (Web)
flutter run -d web

# Uygulamayı çalıştır (Release modu)
flutter run --release
```

## 🔥 İleri Özellikler (Potansiyel Eklemeler)

- 📊 Grafik analitiği (Bar chart, Pie chart)
- 🔄 Veri dışa aktarma (CSV, PDF)
- 📌 Açıklama ve notlar
- 🏷️ Etiketleme sistemi
- 🌐 Çoklu dil desteği
- 🎨 Tema özelleştirmesi
- 📱 Responsive tasarım
- 🔐 Veri şifreleme ve yedeğe alma

## 📝 Notlar

- Tüm veriler sessionda tutulur (restart'ta silinir)
- Gelecekteki geliştirmeler için SharedPreferences veya SQLite entegrasyonu yapılabilir
- Paketler oldukça hafiftir ve performansı etkilemez

## 🎯 Sonuç

Adiyok, modern Flutter uygulaması geliştirmenin en iyi uygulamalarını gösterir:
- ✅ Provider pattern ile temiz state management
- ✅ Modüler ve ölçeklenebilir yapı
- ✅ TypeScript gibi type safety
- ✅ Professional UI/UX tasarımı
- ✅ Responsive ve hızlı performans
- ✅ Türkçe dil desteği

---

**Geliştirici**: Adiyok Team  
**Versiyon**: 1.0.0  
**Son Güncelleme**: Ocak 2026
