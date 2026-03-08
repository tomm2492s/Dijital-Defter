# Dijital Defter

Fiziksel "Envanter Bakım Defteri"ni dijital ortama taşıyan Flutter mobil uygulaması. Saha teknik personeli bakım kayıtlarını girebilir, sayfa bazlı düzenleyebilir ve PDF/DOCX raporları oluşturup paylaşabilir.

## Özellikler

- **Sayfa yapısı:** Kayıtlar "defter sayfaları" altında gruplanır; ana ekranda sayfa listesi, sayfa detayında satır satır tablo görünümü.
- **Sayfa yönetimi:** Ana ekranda sayfaları adlandırma, sürükleyerek sıralama ve silme; menü karta uzun basarak veya üç nokta ile açılır.
- **Tablo görünümü:** Sayfa detayında hangi sütunların görüneceği ve sırası kullanıcıya göre düzenlenebilir; ayarlar veritabanında saklanır (uygulama yeniden başlayınca korunur).
- **Veri girişi:** Demirbaş No, Asansör No, Malzeme Adı, Bulunduğu Birim, Bakım Tarihi, Yapılan İşlem, Bakım Yapan, Durum (Yapıldı/Yapılmadı). Formda ardışık kayıt: "Kaydet ve yeni kayıt ekle" ile çık-gir yapmadan çok satır eklenebilir.
- **Raporlama:** Ayarlarda kullanıcı tanımlı rapor başlığı; kurum bilgileriyle PDF ve DOCX üretimi. Türkçe karakter desteği (Noto Sans); çok satırlı metin desteği.
- **Rapor menüsü:** Sayfa detayından "Rapor al" ile: PDF ile görüntüle, PDF kaydet/paylaş, DOCX ile görüntüle, DOCX kaydet/paylaş.
- **PDF önizleme:** Tam ekran; sayfa açılışta ortada ve ekrana sığacak şekilde, beyaz arka plan; parmakla yakınlaştırma/uzaklaştırma ve sürükleyerek gezinti (InteractiveViewer).
- **Ayarlar:** Kurum adı, birim, sorumlu, dönem ve rapor başlığı; yerel saklama (SharedPreferences). Ayarlar ekranında "Neler yeni" (Kaydet’in altında, aşağı kaydırınca) ile uygulama özellikleri ve güncellemeler listesi.
- **Logo ve ikon:** Uygulama logosu (assets/images/logo.png) ana ekran AppBar’da; launcher ikonu flutter_launcher_icons ile aynı logodan üretilir (`dart run flutter_launcher_icons`).
- **Offline:** Veriler SQLite ile cihazda tutulur; internet gerekmez.

## Teknoloji

- Flutter (Android öncelikli, minSdk 21)
- SQLite (sqflite), path_provider, intl, shared_preferences
- PDF: pdf + printing; DOCX: docx_creator
- Paylaşım: share_plus; DOCX açma: open_filex

## Dokümanlar

- **Kullanıcı Kılavuzu:** [docs/USER_GUIDE.md](docs/USER_GUIDE.md)
- **Kullanıcı Arayüzü/Deneyimi (UI/UX) Rehberi:** [docs/UI_UX_GUIDELINES.md](docs/UI_UX_GUIDELINES.md)
- **Sürüm Notları:** [CHANGELOG.md](CHANGELOG.md)
- **Test Planı:** [docs/TEST_PLAN.md](docs/TEST_PLAN.md)
- **Gelecek Geliştirmeler (Backlog):** [docs/BACKLOG.md](docs/BACKLOG.md)
- **Sprint planı ve tamamlanan işler:** [docs/dijital_defter_sprints.md](docs/dijital_defter_sprints.md)
- **Ürün Gereksinimleri (PRD):** [docs/PRD.md](docs/PRD.md)
- **Yazılım Gereksinim Spesifikasyonu (SRS):** [docs/SRS.md](docs/SRS.md)
- **Teknik Gereksinimler (TRD):** [docs/TRD.md](docs/TRD.md)
- **Mimari Kararlar (ADR):** [docs/ADR.md](docs/ADR.md)

## Başlangıç

```bash
flutter pub get
flutter run
```

Bu proje Flutter ile oluşturulmuştur. Geliştirme rehberi: [Flutter documentation](https://docs.flutter.dev/).
