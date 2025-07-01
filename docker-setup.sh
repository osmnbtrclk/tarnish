#!/bin/bash

# Tarnish RSPS Docker Setup Script

echo "🏰 Tarnish RSPS Docker Kurulum Scripti"
echo "======================================"

# Cache indirme fonksiyonu
download_cache() {
    echo "📦 Cache dosyası indiriliyor..."
    if [ ! -d "game-server/data/cache" ] || [ -z "$(ls -A game-server/data/cache)" ]; then
        echo "Cache klasörü boş, cache indiriliyor..."
        curl -L -o cache-tarnish-218.zip "https://files.jire.org/cache-tarnish-218.zip"
        unzip cache-tarnish-218.zip -d game-server/data/
        rm cache-tarnish-218.zip
        echo "✅ Cache başarıyla indirildi!"
    else
        echo "✅ Cache zaten mevcut!"
    fi
}

# Docker image build etme
build_docker() {
    echo "🐳 Docker image build ediliyor..."
    docker build -t tarnish-rsps .
    echo "✅ Docker image başarıyla build edildi!"
}

# Container çalıştırma
run_container() {
    echo "🚀 Container başlatılıyor..."
    docker-compose up -d
    echo "✅ Container başarıyla başlatıldı!"
    echo "🎮 Sunucu http://localhost:43594 adresinde çalışıyor"
}

# Logları görüntüleme
show_logs() {
    echo "📋 Container logları görüntüleniyor..."
    docker-compose logs -f tarnish-server
}

# Container durma
stop_container() {
    echo "⏹️  Container durduruluyor..."
    docker-compose down
    echo "✅ Container durduruldu!"
}

# Ana menü
show_menu() {
    echo ""
    echo "Seçenekler:"
    echo "1) Cache indir"
    echo "2) Docker build"
    echo "3) Container başlat"
    echo "4) Logları görüntüle"
    echo "5) Container durdur"
    echo "6) Tam kurulum (1+2+3)"
    echo "7) Çıkış"
    echo ""
    read -p "Seçiminizi yapın (1-7): " choice
}

# Ana döngü
while true; do
    show_menu
    case $choice in
        1)
            download_cache
            ;;
        2)
            build_docker
            ;;
        3)
            run_container
            ;;
        4)
            show_logs
            ;;
        5)
            stop_container
            ;;
        6)
            download_cache
            build_docker
            run_container
            ;;
        7)
            echo "👋 Çıkış yapılıyor..."
            exit 0
            ;;
        *)
            echo "❌ Geçersiz seçim! Lütfen 1-7 arası bir sayı girin."
            ;;
    esac
    echo ""
    read -p "Devam etmek için Enter tuşuna basın..."
done
