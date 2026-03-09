# ADR 007: Proje Dizin Yapısı (Project Directory Structure)

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 09.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)
Flutter projelerinde standart bir klasör mimarisi yoktur. Projenin `lib/` klasörü altındaki dosyaların nasıl organize edileceği; yeni bir özellik (Örn: Raporlama) eklendiğinde dosyaların (UI, Logic, DB) nereye konulacağı konusunda bir standart belirlenmelidir ki spagetti kod oluşmasın.

## 2. Karar (Decision)
**Özellik Bazlı Klasörleme (Feature-based Folder Structure)** ile **Katman Bazlı Klasörleme (Layer-based)** yapılarının hibrit bir versiyonunun kullanılmasına karar verilmiştir. Küçük uygulama yapısı nedeniyle başlangıçta Ana Katmanlar etrafında gruplama (Layer-first) yapılacaktır.

Yapı şu şekildedir:
```text
lib/
├── models/         # Tüm veri modelleri (Data Classes)
├── screens/        # Ana UI ekranları (Dashboard, Form vb.)
├── widgets/        # Tekrar kullanılabilen küçük UI parçaları (Kartlar, Butonlar)
├── services/       # İş mantığı, Veritabanı (DB), API ve cihaz servisleri
├── utils/          # Sabitler, temalar, formater'lar (Tarih çevirici vb.)
└── main.dart       # Başlangıç noktası
```

## 3. Mimari Gerekçeler
- **Uygulama Ölçeği:** Mevcut modüller birbirinden tamamen bağımsız özellikler (Feature) değillerdir. (Örn: Ayarlar ekranı, Listeyi doğrudan etkiler). Bu nedenle "Everything is a feature" yapısı (Her özelliği UI/Data/Domain diye kendi içinde klasörleme) küçük projelerde dosyaları bulmayı zorlaştırır.
- **Ayrıştırma (Separation of Concerns):** Widget'lar (`widgets/`) state-less veya basit state'li UI parçaları iken, kompleks iş mantıkları ve veritabanı erişimleri (`services/`) ayrılmıştır.
- **Kolay Başlangıç:** Clean Architecture'ın katı yapısı (Domain, Presentation, Data klasörleri) MVP için yorucu bulunmuş, Layer-first gruplama ile pratiklik hedeflenmiştir.

## 4. Sonuçlar (Consequences)
**Olumlu:** Yeni bir UI bileşeni veya model eklemek/bulmak saniyeler sürer. Geliştirici nereye bakacağını (Ekran mı? Servis mi?) hemen bilebilir.
**Olumsuz:** Dosya sayıları arttığında `screens/` veya `services/` klasörü aşırı şişebilir.

## 5. Reddedilen Seçenekler
- **Feature-First (Özellik Bazlı tam ayrım):** (Örn: `lib/features/auth/`, `lib/features/reports/`) Projede özellikler birbirine çok kenetlenmiş durumda olduğundan (Bakım formu ile Rapor motoru aynı modeli kullanır), kod tekrarına veya özellikler arası import karmaşasına yol açacağı için reddedildi.
- **Clean Architecture (Strict Katı Klasörleme):** MVP geliştirme hızını yavaşlatacağı için şimdilik reddedildi.
