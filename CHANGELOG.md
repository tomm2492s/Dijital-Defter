# Changelog

Tüm önemli değişiklikler bu dosyada belgelenecektir.  
Format, [Keep a Changelog](https://keepachangelog.com/tr/) standartlarına dayanmaktadır ve bu proje [Semantik Sürümleme](https://semver.org/) kullanır.

## [Unreleased]

### Added (Eklendi)
- Uygulama logosu: assets/images/logo.png; ana ekran AppBar’da başlık yanında gösterilir.
- Uygulama ikonu (launcher): flutter_launcher_icons ile logo.png’den Android/iOS launcher ikonları; komut: dart run flutter_launcher_icons.
- Ayarlar ekranında "Neler yeni" bölümü: Kaydet butonunun altında (aşağı kaydırınca); "Yapılan işler ve güncellemeler" kartı ile uygulama özellikleri ve son güncellemeler listesi.
- Hata loglama: hataların cihaz hafızasında saklanması (ErrorLogService, Documents/DijitalDefter/HataKayitlari).
- Hata raporu paylaşımı: Ayarlar > Hata kayıtları > "Hata raporunu paylaş" ile tüm hata verilerini içeren .txt dosyasının WhatsApp/e-posta vb. ile paylaşılması.
- Global hata yakalama: FlutterError.onError ve runZonedGuarded ile yakalanmamış hataların loglanması; ekranlardaki try-catch bloklarında bağlam bilgisi ile loglama.
- Uygulama iskeleti ve temel Material tasarım yönergeleri.
- SQLite entegrasyonu ve `sheet_pages`, `maintenance_records` tabloları.
- Ana ekranda defter sayfaları listesi.
- Sayfa detayı (satır satır tablo) görünümü.
- Yeni kayıt ekleme formu (durum switch'i, tarih seçici içerir).
- Ardışık kayıt ekleyebilme (Kaydet ve Yeni Kayıt Ekle).
- Ayarlar sayfası (Kurum Adı, Birim, Sorumlu, Rapor Başlığı vs.).
- Tablo formatında tam özellikli PDF üretim motoru (Noto Sans Türkçe karakter desteği ile).
- Tam ekran PDF önizleme yeteneği (InteractiveViewer destekli).
- DOCX üretim motoru (`docx_creator` ile).
- WhatsApp, E-posta ve cihaz üzerine PDF/DOCX paylaşımları.
- Kapsamlı PRD, TRD, ADR, SRS dokümantasyonu; Mermaid diyagramları eklendi.
- Eksiksiz test planları, UI/UX kılavuzları, backlog dosyası.

### Changed (Değiştirildi)
- Başlangıç dokümantasyonu geliştirildi (README güncellendi, yeni markdown rehberleri eklendi).

### Fixed (Düzeltildi)
- PDF önizleme ekranında önizleme alanındaki gri arka plan kaldırıldı; scrollViewDecoration ve pdfPreviewPageDecoration ile beyaz arka plan kullanılıyor.
- runZonedGuarded kullanımında "Zone mismatch" hatası giderildi; ensureInitialized ve runApp aynı zone içinde çağrılıyor.

---
*Not: Henüz yayına alınmış bitmiş bir v1.0.x sürümü mevcut olmadığından her özellik [Unreleased] altındadır. İlk yayın ile birlikte bu yapı taşınacaktır.*

## [1.0.1] - 2026-03-09

### Added
- Global bakım periyodu (3, 6, 12 ay) ve hatırlatma eşiği (0, 7, 30, 60 gün önce) için Ayarlar ekranında yeni bölüm.
- Dashboard ana ekranında "Yaklaşan / geciken bakımlar" kartı; yaklaşan veya geciken bakımların listelenmesi ve ilgili sayfaya hızlı geçiş.
- Tablo sütun başlıkları ve Durum (true/false) metinlerinin Ayarlar ekranından özelleştirilebilmesi; bu etiketlerin tablo, form ve PDF/DOCX raporlarda tutarlı kullanılması.

### Changed
- Tablo görünümünü düzenle ekranında (`Tablo görünümünü düzenle`), sütun başlıkları artık Ayarlar'da tanımlanan özelleştirilmiş etiketleri gösteriyor.

### Fixed
- Dashboard üzerinde hatırlatma kartı eklenirken oluşan parantez/ternary kaynaklı derleme hataları giderildi.
