# Yazılım Gereksinim Spesifikasyonu (SRS): Dijital Defter

Bu doküman, projenin geliştirilme aşamasında "tek gerçek kaynak" (single source of truth) olarak kullanılacaktır.

**Proje:** Dijital Defter (Bakım Kayıt ve Raporlama Sistemi)  
**Versiyon:** 1.0 | **Tarih:** 07.03.2026 | **Geliştirici:** Serhan Şeftalioğlu  

**Hedef platformlar:** İlk sürüm **Android** odaklıdır. **iOS** sonraki fazda (Flutter cross-platform ile) planlanmaktadır.

---

## 1. Giriş (Introduction)

### 1.1. Amaç

Bu doküman, fiziksel "Envanter Bakım Defteri"nin dijital bir mobil uygulamaya dönüştürülmesi için gerekli tüm fonksiyonel ve fonksiyonel olmayan gereksinimleri tanımlar.

### 1.2. Kapsam

Uygulama; bakım verilerinin kaydedilmesi, yerel veritabanında saklanması, listelenmesi ve bu verilerin profesyonel PDF/DOCX formatlarında çıktı olarak sunulmasını kapsar.

### 1.3. Tanımlar ve Kısaltmalar

- **CRUD:** Oluşturma, Okuma, Güncelleme, Silme
- **MVP:** Minimum Uygulanabilir Ürün (ilk çalışan sürüm)
- **Export:** Verilerin dosya formatına dönüştürülüp dışa aktarılması
- **Offline-first:** İnternet olmadan çalışma öncelikli tasarım

### 1.4. Platform Gereksinimleri

- **Android:** Minimum SDK 21 (Android 5.0); önerilen API 24+
- **Depolama:** Veritabanı ve PDF’ler için yeterli yerel alan; minimum 50 MB önerilir
- **Ekran:** Küçük ekranlarda form alanları kaydırılabilir ve okunaklı olmalı

## 2. Genel Açıklama (Overall Description)

### 2.1. Ürün Perspektifi

Dijital Defter bağımsız bir mobil uygulamadır. Bulut sunucusuna bağımlı kalmadan (offline-first) çalışır.

### 2.2. Ürün Fonksiyonları

- Bakım kayıtlarının form ile girilmesi; ardışık kayıt ekleme (çık-gir yapmadan çok satır)
- Kayıtların “defter sayfası” altında gruplanması; ana ekranda sayfa listesi, sayfa detayında tablo görünümü
- Ana ekranda sayfa yönetimi: adlandırma, sürükleyerek sıralama, silme; menü karta uzun basma veya üç nokta ile
- Sayfa bazlı tablo görünümü: sütun seçimi ve sırası kullanıcıya göre düzenlenebilir; ayarlar veritabanında kalıcı (uygulama yeniden başlayınca korunur)
- Kayıtların asansör numarasına göre filtrelenmesi (rapor ekranında)
- Görseldeki tablo yapısına uygun PDF/DOCX rapor üretimi; kullanıcı tanımlı rapor başlığı
- Durum bilgisinin "Yapıldı" / "Yapılmadı" olarak metinle gösterilmesi (PDF’de Türkçe karakter uyumu)
- PDF/DOCX için hem görüntüleme hem kaydetme/paylaşma seçenekleri; PDF önizlemede sayfa ortada/sığacak şekilde, beyaz arka plan, zoom/pan
- Gelecek sürümler için: Uygulama ayarlarında tanımlanan global bakım periyodu üzerinden (örn. 3 ay, 6 ay) bakım tarihlerini takip ederek sonraki bakım tarihi yaklaştığında veya geçtiğinde kullanıcıyı uygulama içi listeli uyarılarla bilgilendirme (kayıt formuna ek alan eklemeden).
- Global sütun gizleme: Ayarlar ekranındaki "Gizlenecek sütunlar" bölümünde işaretlenen sütunlar tüm tablo görünümlerinde ve PDF/DOCX raporlarında gizlenir; sayfa bazlı tablo görünümü bu global gizleme tercihine uyar.

### 2.3. Kullanıcı Özellikleri

Teknik terminolojiye hakim, hızlı aksiyon alması gereken saha personeli hedeflenir. Arayüz "tek el kullanımına" uygun ve sade tasarlanacaktır.

## 3. Sistem Özellikleri (System Features)

### 3.1. Veri Girişi ve Yönetimi

- **[REQ-1]** Her bakım için benzersiz Sıra No atanmalı
- **[REQ-2]** Asansör No için manuel giriş veya kayıtlı asansörlerden seçim
- **[REQ-3]** Durum alanı ikili seçim (binary toggle) olarak sunulmalı

### 3.2. Çıktı Üretim Sistemi

- **[REQ-4]** PDF dikey (portrait) veya yatay (landscape) sayfa yapısında; tablo mizanpajı korunmalı
- **[REQ-5]** Çıktıların en üstünde kullanıcı tanımlı rapor başlığı; "Kurum Adı", "Birim", "Sorumlu" ve "Dönem" bilgileri yer almalı
- **[REQ-6]** PDF/DOCX’te çok satırlı metin alanları satır sonları korunarak gösterilmeli
- **[REQ-7]** Rapor menüsü: PDF ile görüntüle, PDF kaydet/paylaş, DOCX ile görüntüle, DOCX kaydet/paylaş
- **[REQ-8]** PDF önizleme tam ekranda; açılışta sayfa ortada ve ekrana sığacak şekilde, beyaz arka plan; kullanıcı yakınlaştırma/uzaklaştırma ve sürükleyerek gezinebilmeli
- **[REQ-9]** Sayfa tablo görünümü (sütun seçimi/sırası) veritabanında saklanmalı; uygulama kapatılıp açılsa da korunmalı
- **[REQ-10]** Ana ekranda sayfalar adlandırılabilmeli, sürükleyerek sıralanabilmeli ve (onay ile) silinebilmeli; menü karta uzun basma veya üç nokta ile açılabilmeli

## 4. Dış Arayüz Gereksinimleri

### 4.1. Kullanıcı Arayüzü (UI)

- **Tema:** Göz yormayan, yüksek kontrastlı (saha kullanımı için)
- **Kontroller:** Büyük butonlar ve tarih seçiciler (DatePicker)

### 4.2. Yazılım Arayüzleri

- **SQLite:** Yerel veri depolama
- **Path Provider:** Dosya yönetimi ve PDF kaydetme
- **Share API:** PDF/DOCX’i WhatsApp vb. ile paylaşma

## 5. Fonksiyonel Olmayan Gereksinimler

### 5.1. Performans

- Uygulama açılış süresi 2 saniyenin altında
- 1000 kayıtlık listenin PDF’e dönüşümü 5 saniyeyi geçmemeli

### 5.2. Güvenilirlik ve Güvenlik

- Uygulama kapansa bile veriler anlık kaydedilmeli (Auto-save)
- Veritabanı dosyası kullanıcı tarafından yedeklenebilmeli

### 5.3. Kullanılabilirlik

- Form doldurma en fazla 1 dakika sürmeli

### 5.4. Kullanım Senaryoları (Use Case Özeti)

- **Kayıt ekleme:** Teknisyen formu açar, doldurur, kaydeder; sistem listeye ekler
- **Rapor oluşturma:** Tarih aralığı/filtre seçilir, "Rapor Al"a basılır; PDF/DOCX oluşur ve paylaşım açılır
- **Filtreleme:** Asansör No veya Malzeme Adı yazılır; liste anında filtrelenir

### 5.5. Hata Davranışı

- **Zorunlu alan boş:** Kayıt butonu devre dışı veya "Zorunlu alanları doldurun" (Snackbar)
- **Veritabanı hatası:** "Veri kaydedilemedi, tekrar deneyin" mesajı; hata loglanır
- **PDF/dosya yazma hatası:** "Rapor oluşturulamadı" mesajı ve depolama izni kontrolü

## 6. Veri Sözlüğü ve Tablo Yapısı

**sheet_pages:** id, title, created_at (defter sayfası).

**maintenance_records:** Her kayıt isteğe bağlı olarak bir sayfaya (page_id) bağlanır.

| Alan           | Tip     | Zorunluluk  |
|----------------|---------|-------------|
| Sıra No (id)   | Integer | Otomatik    |
| Sayfa No       | Integer | Opsiyonel (page_id) |
| Demirbaş No    | String  | Opsiyonel   |
| Asansör No     | String  | Zorunlu     |
| Malzeme Adı    | String  | Zorunlu     |
| Bulunduğu Birim| String  | Zorunlu     |
| Bakım Tarihi   | Date    | Zorunlu     |
| Yapılan İşlem  | Text    | Zorunlu     |
| Bakım Yapan    | String  | Zorunlu     |
| Durum          | Boolean | Zorunlu     |
