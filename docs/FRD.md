# Fonksiyonel Gereksinimler Dokümanı (FRD): Dijital Defter

Bu doküman, yazılımın "nasıl" çalışacağını adım adım açıklar.

**Proje:** Dijital Defter v1.0 | **Kapsam:** Bakım Kayıt Yönetimi ve Raporlama  

**Platform:** İlk sürüm **Android**; **iOS** sonraki aşamada. Tüm fonksiyonlar her iki platformda aynı şekilde çalışacak şekilde tasarlanmalıdır.

---

## 0. Ekran / Sayfa Listesi

1. **Ana ekran** — Kayıt listesi, arama, filtre, "Yeni Kayıt", "Rapor Al"
2. **Veri giriş ekranı** — Form
3. **Ayarlar** — Kurum bilgileri, birim, sorumlu, dönem
4. **Rapor önizleme / paylaşım** — PDF/DOCX oluşturulduktan sonra

---

## 1. Kullanıcı Arayüzü ve İş Akışı (UI/UX)

Uygulama "Hızlı Form" yapısını benimser; teknik personel sahada hızlı veri girişi yapabilir.

### 1.1. Ana Ekran (Dashboard)

- **Kayıt listesi:** Tüm bakımlar en yeniden en eskiye sıralı
- **Arama ve filtre:** Asansör No veya Malzeme Adı ile arama
- **Eylem butonları:** "Yeni Kayıt Ekle" (+), "Rapor Al" (Dışa Aktar)

### 1.2. Veri Giriş Ekranı

**Statik alanlar (ayarlardan gelir):** Kurum/İşletme Adı, Birim, Sorumlu Kişi, Dönem

**Dinamik alanlar:**

- Demirbaş No: Serbest metin
- Asansör No: Dropdown veya manuel giriş
- Malzeme Adı: Örn. Fren, Halat, Motor
- Durum seçici: "Yapıldı" (Yeşil/Tik) — "Yapılmadı" (Kırmızı/Çarpı) arasında Switch

---

## 2. Fonksiyonel Özellikler

### 2.1. Kayıt Yönetimi (CRUD)

- **[FR-01] Kayıt ekleme:** Form doldurularak yeni bakım satırı oluşturulur
- **[FR-02] Kayıt güncelleme:** Listeden kayda dokunularak düzenleme
- **[FR-03] Kayıt silme:** Sola kaydırma veya uzun basarak silme

### 2.2. PDF ve DOCX Üretim Modülü

- **[FR-04]** Kullanıcının seçtiği tarih aralığındaki veriler orijinal tablo formatında PDF’e yerleştirilir
- **[FR-05]** Veritabanındaki True/False, PDF’de ✅ veya ❌ simgesine dönüştürülür
- **[FR-06]** Veriler Word uyumlu tablo şablonuna basılır

### 2.3. Paylaşım ve Saklama

- **[FR-07]** Raporlar WhatsApp, E-posta veya Telegram ile paylaşılabilir
- **[FR-08]** Veriler cihazın yerel hafızasında (Internal Storage) saklanır

---

## 3. Sistem Gereksinimleri ve Mantıksal Kurallar

- **Tarih:** "Bakım Tarihi" varsayılan bugün; kullanıcı değiştirebilir
- **Asansör No:** Kayıt eklerken boş bırakılamaz
- **Sıra No:** Rapor çıktısında 1’den başlayarak ardışık verilir (ID’den bağımsız)

### 3.2. Hata ve Kenar Durumları

- **Ağ yok:** Uygulama offline çalışır; paylaşım "Dosyaya kaydet" veya sonradan
- **Depolama dolu:** "Yeterli depolama alanı yok" mesajı; PDF kaydetme iptal
- **PDF oluşturma hatası:** Snackbar ile bilgi; gerekirse log
- **Kayıt silme:** Onay dialog’u gösterilir

### 3.3. Validasyon Kuralları

- **Asansör No:** Boş olamaz; max 50 karakter
- **Bakım Tarihi:** Geçerli tarih (gelecek tarih kabul edilebilir)
- **Malzeme Adı, Bulunduğu Birim, Yapılan İşlem, Bakım Yapan:** Zorunlu; makul max uzunluk (örn. 200–500 karakter)
- **Demirbaş No:** Opsiyonel; format serbest

---

## 4. Veri Alanları Spesifikasyonu

| ID      | Alan Adı     | Veri Tipi | Kontrol Tipi        |
|---------|--------------|-----------|----------------------|
| REQ-01  | Demirbaş No  | String   | TextField            |
| REQ-02  | Asansör No   | String   | Searchable Dropdown  |
| REQ-03  | Malzeme Adı  | String   | TextField            |
| REQ-04  | Bakım Tarihi | Date     | DatePicker           |
| REQ-05  | Durum        | Boolean  | Switch (Toggle)      |
| REQ-06  | Yapılan İşlem| Long Text| TextArea             |
