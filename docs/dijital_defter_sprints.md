# Dijital Defter – Sprints

# Sprint 1 - Altyapı ve proje iskeleti

- [x] Flutter projesi oluşturma (Android öncelikli, minSdk 21)
- [x] Klasör yapısı (lib/screens, widgets, models, services, utils)
- [x] State yönetimi için Provider veya BLoC kurulumu
- [x] Tema ve temel Material tasarım (yüksek kontrast, saha kullanımı)
- [x] path_provider ve intl bağımlılıklarının eklenmesi

# Sprint 2 - Veri katmanı ve modeller

- [x] SQLite (sqflite) entegrasyonu
- [x] maintenance_records tablosu ve migration
- [x] sheet_pages tablosu ve page_id ile kayıt–sayfa ilişkisi (v2 migration)
- [x] DatabaseService singleton (CRUD, transaction, commit)
- [x] Bakım kaydı model sınıfı (alanlar: id, page_id, inventory_no, elevator_no, material_name, unit_location, maintenance_date, action_done, technician, status)
- [x] SheetPage modeli (id, title, created_at)
- [x] Veritabanı dosyasının databases klasöründe saklanması

# Sprint 3 - Ana ekran ve kayıt listesi

- [x] Ana ekran (Dashboard) iskeleti; sayfa listesi (defter sayfaları kartları)
- [x] Sayfa detay ekranı: ilgili sayfadaki kayıtlar tablo görünümünde (RecordTableSheet)
- [x] Kayıt listesi sayfa bazlı (en yeniden en eskiye); FutureBuilder ile asenkron yükleme
- [x] Asansör No ve Malzeme Adı ile arama/filtre (rapor ekranında)
- [x] "Yeni sayfa" (+), sayfa içinde "Yeni satır ekle" ve "Rapor Al" butonları
- [x] Liste öğesinde durum göstergesi (Yapıldı / Yapılmadı metni)

# Sprint 4 - Veri giriş formu ve CRUD

- [x] Veri giriş ekranı (form) ve navigasyon
- [x] Tüm dinamik alanlar (Demirbaş No, Asansör No, Malzeme Adı, Bulunduğu Birim, Bakım Tarihi, Yapılan İşlem, Bakım Yapan, Durum)
- [ ] Asansör No için Dropdown/Autocomplete (kayıtlı numaralardan seçim veya manuel)
- [x] Bakım Tarihi DatePicker (varsayılan bugün)
- [x] Durum alanı Switch (Yapıldı / Yapılmadı)
- [x] Zorunlu alan validasyonu ve hata mesajları (Snackbar)
- [x] Kayıt ekleme ve listeye geri dönüş
- [x] Listeden kayda dokununca düzenleme (güncelleme) akışı

# Sprint 5 - Ayarlar ve rapor üst bilgileri

- [x] Ayarlar ekranı (Kurum/İşletme Adı, Birim, Sorumlu Kişi, Dönem)
- [x] Ayarların yerel saklanması ve formda statik alan olarak kullanılması
- [x] PDF/DOCX için üst bilgi bağımlılığının karşılanması

# Sprint 6 - PDF ve DOCX rapor üretimi

- [x] pdf ve printing paketleri entegrasyonu
- [x] PDF şablonu: "ENVANTER BAKIM DEĞERİ" başlığı ve kurum bilgileri (pw.Header)
- [x] Tarih aralığına göre veri çekme ve List<TableRow> oluşturma
- [x] status değerine göre metin: "Yapıldı" / "Yapılmadı" (PDF’de sembol yerine)
- [x] Portrait veya landscape sayfa yapısı
- [x] DOCX üretimi (docx_creator) düzenlenebilir tablo
- [x] Rapor önizleme veya doğrudan paylaşım akışı
- [x] Ayarlarda kullanıcı tanımlı rapor başlığı
- [x] PDF’de Türkçe karakter desteği (Noto Sans font, assets veya PdfGoogleFonts)
- [x] PDF/DOCX’te çok satırlı metin desteği (satır sonu korunur)
- [x] Rapor menüsü: PDF ile görüntüle, PDF kaydet/paylaş, DOCX ile görüntüle, DOCX kaydet/paylaş
- [x] PDF önizleme: tam ekran sayfa; yakınlaştırma/uzaklaştırma ve pan (InteractiveViewer)

# Ek geliştirmeler (UI/UX ve veri yapısı)

- [x] Defter sayfası (SheetPage) kavramı: kayıtlar sayfa bazlı gruplanır
- [x] Ana ekran: sayfa listesi (kartlar); sayfa detay ekranında satır satır kayıt tablosu
- [x] Sayfa detayında "Yeni satır ekle" ve "Rapor al" (PDF/DOCX menüsü)
- [x] Formda ardışık kayıt: "Kaydet ve yeni kayıt ekle", "Başka kayıt ekle" ile çık-gir yapmadan çok satır ekleme
- [x] Oturumda kaydedilen tüm satırların tek PDF/DOCX’te toplanması (formdan rapor alırken)
- [x] open_filex ile DOCX’i harici uygulamada görüntüleme

- [x] Ana ekranda sayfa yönetimi: sayfayı adlandırma (dialog), sıralama (ReorderableListView / sürükle-bırak), silme (onay ile); menü kartta üç nokta veya karta uzun basma ile açılır
- [x] Tablo görünümü ayarları (sütun seçimi ve sırası) veritabanında kalıcı (page_view_config tablosu); uygulama kapatılıp açılsa da korunur
- [x] PDF önizleme: sayfa açılışta ortada ve ekrana sığacak şekilde (Center + FittedBox), beyaz arka plan; zoom/pan aynı şekilde çalışır
- [x] Geçişler: sayfa/form/rapor/ayarlar için kısa slide animasyonu (PageRouteBuilder, 220 ms); geri dönüşte yenileme animasyon sonrası (addPostFrameCallback)
- [x] Performans: ana listede sayfa + kayıt sayıları paralel yükleme (Future.wait); sayfa detayında kayıt listesi tek Future ile önbelleklenir

# Sprint 7 - Paylaşım ve yedekleme

- [x] share_plus ile PDF/DOCX paylaşımı (WhatsApp, E-posta, Kaydet)
- [x] PDF/DOCX çıktılarının Belgeler (Documents/DijitalDefter/Raporlar) klasöründe oluşturulması; paylaşım öncesi buraya kaydedilip paylaşım
- [x] Veritabanını yedekleme: Ayarlar > Yedekleme > "Veritabanını yedekle (.db)" ve "Veriyi JSON olarak dışa aktar" (Yedekler klasörüne + paylaşım)
- [x] Depolama dolu ve dosya yazma hatalarında kullanıcı mesajı (StorageService.messageForStorageError)

# Sprint 8 - Silme, hata durumları ve UI iyileştirmeleri

- [x] Kayıt silme (sola kaydırma veya uzun basma)
- [x] Silme onay dialog'u
- [x] Veritabanı ve PDF hatalarında try-catch ve anlamlı Snackbar mesajları
- [x] Ana ekran kart görünümü ve renk kodları (Yapıldı/Yapılmadı)
- [x] Form alanları max uzunluk ve validasyon kurallarının uygulanması
- [x] Hata loglama: hataların cihaz hafızasında saklanması (ErrorLogService, Documents/DijitalDefter/HataKayitlari)
- [x] Hata raporu: tüm hata verileri (zaman, mesaj, tür, stack trace, bağlam) okunabilir .txt dosyasına yazılıp WhatsApp/e-posta ile paylaşılabilir
- [x] Global hata yakalama: FlutterError.onError ve runZonedGuarded ile yakalanmamış hataların loglanması
- [x] Ayarlar ekranında "Hata kayıtları" bölümü ve "Hata raporunu paylaş" butonu
- [x] PDF önizleme ekranında gri arka planın beyaz yapılması (scrollViewDecoration, pdfPreviewPageDecoration)
- [x] Ayarlar ekranında "Neler yeni" bölümü (Kaydet butonunun altında; aşağı kaydırınca görünür); "Yapılan işler ve güncellemeler" kartına dokununca uygulama özellikleri ve son güncellemeler listesi açılır
- [x] Uygulama logosu: assets/images/logo.png; ana ekran (Dashboard) AppBar’da başlık yanında gösterilir
- [x] Uygulama ikonu (launcher): flutter_launcher_icons ile logo.png’den Android/iOS ikonları üretilir; komut: dart run flutter_launcher_icons
- [x] runZonedGuarded zone uyumu: ensureInitialized ve runApp aynı zone içinde çağrılarak "Zone mismatch" hatası giderildi
- [x] Hakkında bölümü: Ayarlar ekranında uygulama adı, sürüm ve geliştiren kişi (yapan kişi) bilgisi; AppInfo ile tek yerden yönetim

# Sprint 9 - Test ve Android yayın hazırlığı

- [ ] DatabaseService ve CRUD için birim testler
- [ ] PDF oluşturma mantığı için birim test (mock veri)
- [ ] Kritik widget testleri (form, liste)
- [ ] Manuel test senaryoları (kayıt ekleme, düzenleme, silme, filtre, PDF/DOCX, paylaşım)
- [ ] Android release build ve imzalama
- [ ] Google Play Store liste metni ve ekran görüntüleri hazırlığı

# Sprint 10 - Dokümantasyon ve İyileştirmeler

- [x] README.md oluşturulması (Geliştirici rehberi)
- [x] CHANGELOG.md oluşturulması (Sürüm geçmişi)
- [x] USER_GUIDE.md oluşturulması (Son kullanıcı kullanım kılavuzu)
- [x] UI_UX_GUIDELINES.md oluşturulması (Görsel ve UX standartları)
- [x] TEST_PLAN.md oluşturulması (Birim, ara birim ve manuel test senaryoları)
- [x] BACKLOG.md oluşturulması (Gelecek planlamaları ve eklentiler)
- [x] TRD.md içerisine Mermaid ile ER Diyagramı eklenmesi
- [x] PRD.md içerisine Mermaid ile Durum Akış Diyagramı eklenmesi
- [x] MkDocs yapılandırmasının (mkdocs.yml) kurularak statik site üretimi entegrasyonu
