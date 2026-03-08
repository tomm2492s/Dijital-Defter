# RFC 001: Dijital Defter — Mobil Bakım Takip ve Raporlama Sistemi

**Durum:** Tartışmaya Açık (Draft)  
**Yazar:** Serhan Şeftalioğlu | **Tarih:** 07.03.2026  

**Platform planı:** Önce **Android**; sonrasında **iOS** (Flutter ile tek codebase).

---

## 1. Özet (Abstract)

Bu RFC, fiziksel "Envanter Bakım Defteri"nin dijital bir mobil uygulamaya dönüştürülmesini teklif eder. Temel odak: çevrimdışı veri girişi ve bu verilerin önceden tanımlı şablon üzerinden PDF/DOCX formatında dışa aktarılması.

## 2. Teknik Teklif (Technical Proposal)

### 2.1. Uygulama Mimarisi

Clean Architecture prensiplerine uygun Flutter ile geliştirme önerilir.

- **Data Layer:** SQLite (sqflite veya drift) ile yerel veritabanı yönetimi
- **Domain Layer:** Bakım kayıtlarının iş mantığı ve validasyonları
- **Presentation Layer:** BLoC veya Provider ile state management

### 2.2. Veri Şeması (Data Schema)

`maintenance_records` tablosu:

```sql
CREATE TABLE maintenance_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    inventory_no TEXT,
    elevator_no TEXT NOT NULL,
    material_name TEXT,
    department TEXT,
    maintenance_date DATE,
    action_taken TEXT,
    technician_name TEXT,
    is_completed BOOLEAN  -- True: ✅, False: ❌
);
```

### 2.3. Raporlama Motoru (Reporting Engine)

- **PDF:** pdf paketi ile Table widget; görseldeki orijinal mizanpajın birebir simülasyonu
- **DOCX:** docx kütüphanesi veya HTML-to-DOCX ile düzenlenebilir dosya

## 3. UI/UX Tasarım Standartları

- **Giriş kolaylığı:** Asansör numarası için Autocomplete veya Dropdown (daha önce girilen numaralardan)
- **Görsel durum:** Ana ekranda renkli kartlar (Yeşil/Kırmızı); PDF’te Unicode ✅/❌

## 4. Güvenlik ve Veri Bütünlüğü

- **Zorunlu alanlar:** Asansör No ve Bakım Tarihi boş bırakılamaz
- **Veri yedekleme:** .db veya .json Export; cihaz değişiminde Import

## 5. Tartışmaya Açık Konular (Open Questions)

- **Resim ekleme:** Bakım anına dair fotoğraf rapora eklenecek mi? (PDF boyutunu artırır)
- **İmza:** Dijital imza alanı (ekrana çizim) eklenmeli mi?
- **Bulut senkronizasyonu:** v1 %100 offline mı kalmalı, yoksa opsiyonel Google Drive yedeklemesi mi?

## 6. Alternatifler Değerlendirildi

- **Flutter + SQLite:** Seçildi — tek codebase (Android/iOS), hızlı geliştirme, yerel DB ve PDF kütüphaneleri
- **React Native:** Benzer avantaj; ekosistem tercihi nedeniyle Flutter seçildi
- **PWA:** Offline ve dosya erişimi sınırlı; native paylaşım/depolama için uygun değil
- **Native (Kotlin/Swift):** En yüksek performans; maliyet ve süre nedeniyle v1’de tercih edilmedi

## 7. Tahmini Zaman Çizelgesi

- **MVP (Android):** Tahmini 6–8 hafta (veri girişi, liste, filtre, PDF/DOCX, paylaşım, yedekleme)
- **Milestone’lar:** Hafta 2 — DB + temel ekranlar; Hafta 4 — CRUD + PDF; Hafta 6 — DOCX + paylaşım + test; Hafta 8 — düzeltmeler ve yayına hazırlık
