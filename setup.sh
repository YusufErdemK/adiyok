#!/bin/bash
# 🎉 Adiyok - Kurulum ve Çalıştırma Script'i

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         🌳 Adiyok - Ağaç & Gelir/Gider Yönetimi            ║"
echo "║                   Kurulum Script'i                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Renk tanımları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flutter check
echo -e "${BLUE}📋 Sistem Kontrolleri Yapılıyor...${NC}"
echo ""

# Flutter version
echo -n "✓ Flutter versiyonu: "
FLUTTER_VERSION=$(flutter --version 2>/dev/null | head -1)
if [ -z "$FLUTTER_VERSION" ]; then
    echo -e "${RED}❌ Flutter bulunamadı!${NC}"
    exit 1
else
    echo -e "${GREEN}$FLUTTER_VERSION${NC}"
fi

# Dart version
echo -n "✓ Dart versiyonu: "
DART_VERSION=$(dart --version 2>&1)
echo -e "${GREEN}$DART_VERSION${NC}"
echo ""

# Setup
echo -e "${BLUE}📦 Paketler Yükleniyor...${NC}"
flutter pub get

echo ""
echo -e "${BLUE}🔍 Analiz Yapılıyor...${NC}"
flutter analyze

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo -e "${GREEN}║                 ✅ Kurulum Tamamlandı!                    ║${NC}"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${YELLOW}📖 Sonraki Adımlar:${NC}"
echo ""
echo "1. 📖 Hızlı Başlama (5 dakika):"
echo "   cat QUICKSTART.md"
echo ""
echo "2. 🚀 Uygulamayı Çalıştır:"
echo "   flutter run"
echo ""
echo "3. 📱 Spesifik Cihazda Çalıştır:"
echo "   flutter devices          # Cihazları listele"
echo "   flutter run -d <id>      # Cihazda çalıştır"
echo ""
echo "4. 🏗️ Build Et:"
echo "   flutter build apk --release      # Android"
echo "   flutter build ios --release      # iOS"
echo "   flutter build web --release      # Web"
echo ""
echo "5. 📚 Dokümantasyon:"
echo "   - QUICKSTART.md  → 5 dakikada başla"
echo "   - REHBER.md      → Detaylı kullanım"
echo "   - DEVELOPING.md  → Geliştirme rehberi"
echo "   - CODE_STRUCTURE.md → Kod yapısı"
echo ""

echo -e "${GREEN}🎉 Adiyok'u kullanmaya hoş geldiniz!${NC}"
echo ""
