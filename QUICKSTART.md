# ⚡ Adiyok - Hızlı Başlama Rehberi

## 30 Saniyede Başla

```bash
cd /home/erdem/adiyok
flutter pub get
flutter run
```

✅ Hepsi bu kadar! Uygulamaya hoş geldiniz.

---

## İlk 5 Dakikada Neler Yapılabilir?

### 1️⃣ Ağaç Oluştur (1 dakika)
```
1. "Ağaç" sekmesine git
2. Yeşil "Kök Eleman" butonuna tıkla
3. "Şirketerim" yazıp "Ekle" butonuna tıkla
4. Ağacı genişletmek için kartı tıkla
```

### 2️⃣ Alt Eleman Ekle (1 dakika)
```
1. Yeni oluşturulan kök elemanın sağındaki menu (⋮)
2. "Alt Eleman Ekle" seç
3. "Frontend Projesi" yaz ve ekle
4. Daha fazla alt eleman ekle
```

### 3️⃣ Gelir Ekle (1.5 dakika)
```
1. "Finans" sekmesine git
2. "İşlem Ekle" butonuna tıkla
3. "💰 Gelir" seçili halde
4. Başlık: "Maaş"
5. Tutar: "5000"
6. Kategori: "Maaş" 
7. "Kaydet" butonuna tıkla
```

### 4️⃣ Gider Ekle (1.5 dakika)
```
1. "İşlem Ekle" butonuna tıkla
2. "💸 Gider" seçilir hale getir
3. Başlık: "Kira"
4. Tutar: "2500"
5. Kategori: "Kira"
6. "Kaydet" butonuna tıkla
```

### 5️⃣ İstatistikleri Gör (0.5 dakika)
```
1. Finans sekmesinde "Tümü" sekmesinde
2. En üstte Net Gelir, Toplam Gelir, Toplam Gider'i gör
3. İşlemler aşağıda yeşil/kırmızı renkleriyle gösterilir
```

---

## 🎯 Temel Özellikler Özeti

| Özellik | Ağaç Sekmesi | Finans Sekmesi |
|---------|------------|----------------|
| Oluştur | ✅ Kök eleman | ✅ İşlem |
| Genişlet | ✅ Alt elemanlar | ✅ - |
| Düzenle | ✅ Adı/Açıklamayı | ✅ Tüm detayları |
| Sil | ✅ | ✅ |
| İstatistik | ✅ Derinlik, nod sayısı | ✅ Toplam, kategori |
| Renk Kodu | ❌ | ✅ Yeşil/Kırmızı |

---

## 🎨 Sistem Kullanım

### Ağaç Yapısı - Ne İçin?
```
Örneğin bir şirket yapısını modelleyebilir:
┌─ Şirketerim
│  ├─ Frontend Takımı
│  │  ├─ React Projesi
│  │  └─ Vue Projesi
│  └─ Backend Takımı
│     ├─ API Geliştirme
│     └─ Database Tasarımı

Ya da Kişisel Projeler:
┌─ Kişisel Projeler
│  ├─ Flutter Öğrenme
│  │  ├─ Widgets
│  │  └─ State Management
│  └─ Web Geliştirme
```

### Gelir/Gider - Ne İçin?
```
✅ Aylık bütçenizi takip etmek
✅ Harcamaları kategorilere göre görmek
✅ Başlangıçtan sonra net geliri hesaplamak
✅ Tarih bazında işlemleri kaydetmek

Örnek:
Jan 1: Maaş +5000 (Gelir)
Jan 5: Kira -2500 (Gider)
Jan 10: Restorana -450 (Gider)
Net: +2050 ✅
```

---

## 💡 Yararlı İpuçları

### 🎯 Verileri Kaydetmek İçin
> Şu anda veriler uygulama çalıştığı sürece saklanır. 
> Uygulamayı kapatıp açtığınızda sıfırlanır.
> Kalıcı hale getirmek için `SharedPreferences` entegrasyonu yapılabilir.

### 📱 Küçük Ekranlar İçin
> Bütün öğeler responsive tasarlanmıştır. 
> Tablet ve büyük ekranlarda daha hoş görünür.

### 🌙 Dark Mode
> Material Design 3 otomatik olarak sistem temasını takip eder.
> Cihazınızda dark mode açıksa uygulama da dark olur.

### ⚡ Performans
> 1000+ nod ile bile sorunsuz çalışır.
> Ağaç genişletme/daraltma smooth ve hızlıdır.

---

## 🛠️ Hızlı Ayarlamalar

### Renkleri Değiştir
`lib/main.dart` dosyasında:
```dart
seedColor: const Color(0xFF2D6A4F),  // ← Buraya başka renk kodu yaz
// Örn: 0xFFFF6B6B (Kırmızı), 0xFF4ECDC4 (Turkuaz)
```

### Kategori Ekle
`lib/models/transaction.dart` dosyasında:
```dart
enum TransactionCategory {
  myNewCategory('Kategori Adı', '🆕'),
  // ...
}
```

---

## 📋 Yapılabilecek İşlemler Checklisti

### Ağaç ile
- [ ] Şirket yapısını modelleyin
- [ ] Organizasyon şeması oluşturun
- [ ] Proje hiyerarşisini takip edin
- [ ] Derinlik istatistiklerini izleyin

### Finans ile
- [ ] Aylık gelir/gider kaydedin
- [ ] Bütçe hedeflerini belirleyin
- [ ] Kategori bazında harcamaları kontrol edin
- [ ] Tasarruf potansiyeli belirleyin

---

## ❓ Sık Sorulan Sorular

**S: Verilerim nasıl saklanır?**
- Şu anda RAM'da saklanır (session boyunca). Kalıcı hale getirmek için SharedPreferences eklenebilir.

**S: Bulutta senkronize olabilir mi?**
- Firebase entegrasyonu yapılırsa senkronize edilebilir.

**S: Kaç veri saklayabilirim?**
- Teorik olarak sınırsız. Pratik olarak 10,000+ işlem ve ağaç sorunsuz çalışır.

**S: Çevrimdışı çalışır mı?**
- Evet! Tamamen yerel, internet gerektirmez.

**S: Telefondan bilgisayara veri taşıyabilir miyim?**
- Şu anda yok, ama JSON export eklenebilir.

---

## 🚀 Sonraki Adımlar

1. **Denemeyi Bitiriniz** (5 dakika)
   - Birkaç ağaç ve işlem oluşturun
   - Tüm butonları tıklayın

2. **Kodun Nasıl Çalıştığını Öğrenin** (15 dakika)
   - `DEVELOPING.md` dosyasını okuyun
   - `lib/` klasöründeki dosyaları keşfedin

3. **Özelleştirme Yapın** (30 dakika)
   - Renkleri değiştirin
   - Kategoriler ekleyin
   - Kendi logonuzu ekleyin

4. **Ekstra Özellikler Ekleyin** (1+ saat)
   - SharedPreferences ile kalıcı depolama
   - Export/Import fonksiyonalitesi
   - Grafik analitiği

---

## 📞 Yardım

- **Dosya bulamıyorum?** → `lib/` klasörüne bak
- **Uygulamayı çalıştıramıyorum?** → `flutter doctor` çalıştır
- **Veri kayboldu?** → `flutter run` ile yeniden başla
- **Build hatası?** → `flutter clean` sonra `flutter pub get`

---

## 🎉 Hepsi Bu!

Şimdi eğlenmeye başlamaya hazırsın! Adiyok ile:
- ✅ Ağaçları yönet
- ✅ Gelir/gideri takip et  
- ✅ İstatistikleri gözlemle
- ✅ Veriler ile oyunsa

**Happy Coding! 🚀**

---

Daha detaylı bilgi için `DEVELOPING.md` ve `REHBER.md` dosyalarını okuyunuz.
