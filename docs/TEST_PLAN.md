# Test Planı (Test Plan)

Dijital Defter projesi için test stratejisi (Birim, Ara Birim ve Manuel Testler) bu belgede tanımlanmıştır.

## 1. Birim Testleri (Unit Testing)

Tüm iş mantığı, veritabanı CRUD operasyonları ve PDF üretim algoritmaları bu kapsama girer.

- **TC-U01: SQLite DatabaseService Initialization**
  - **Adım:** \`DatabaseService.initDb()\` çağrılır.
  - **Beklenen Sonuç:** Veritabanı başlatılmalı ve \`sheet_pages\`, \`maintenance_records\` tabloları mevcut olmalıdır.
- **TC-U02: Record Creation and Retrieval**
  - **Adım:** Mock veri ile \`insertRecord\` çalıştırılır, ardından ayni \`page_id\` ile \`getRecordsByPageId\` çağrılır.
  - **Beklenen Sonuç:** Gönderilen verilerle dönen verilerin alanları birebir örtüşmelidir.
- **TC-U03: Settings Storage**
  - **Adım:** \`SharedPreferencesService\` (veya Settings.save) üzerinden kurum adı kaydedilir ve okunur.
  - **Beklenen Sonuç:** Veri persist (kalıcı) olmalıdır.

## 2. Widget Testleri (Widget/Integration Testing)

UI bileşenlerinin ve sayfa akışlarının testi (test_driver / flutter_test).

- **TC-W01: Form Validasyonu**
  - **Adım:** Zorunlu alanlar (\`elevator_no\`, \`material_name\`) boş bırakılıp "Kaydet"e basılır.
  - **Beklenen Sonuç:** UI'da ilgili alanların altında hata mesajı gösterilir ve kayıt engellenir.
- **TC-W02: Durum Switch'inin Tepkisi**
  - **Adım:** Yeni kayıt ekranında Switch'e (Yapılmadı -> Yapıldı) dokunulur.
  - **Beklenen Sonuç:** "Yapılmadı" olan metin "Yapıldı"ya, kırmızı renk yeşile döner.
- **TC-W03: Liste Yüklenmesi**
  - **Adım:** Sayfa detay ekranı açılır.
  - **Beklenen Sonuç:** \`FutureBuilder\` tamamlanana kadar Loading (CircularProgressIndicator) görünür, bitince \`ListView\` / Tablo oluşturulur.

## 3. Manuel Test Senaryoları (Manual Testing)

Fiziksel cihazda saha koşulları simüle edilerek yapılacak testlerdir.

- **TC-M01: Tam Çevrimdışı Mod**
  - **Ortam:** Wi-Fi ve Mobil Veri kapalı (Uçak Modu).
  - **Adım:** Yeni defter sayfası oluşturun, 3 kayıt girin (1 Yapılmadı, 2 Yapıldı).
  - **Beklenen Sonuç:** Gecikme olmadan anında kaydedilmesi; verilerin cihazı yeniden başlatıp açıldığında bile (SQLite üzerinden) listede görülmesi.
- **TC-M02: PDF Rapor Formasyon Testi**
  - **Adım:** İlgili sayfadan "Rapor Al -> PDF Görüntüle" yapın.
  - **Beklenen Sonuç:** 
    - Sayfanın en üstünde ayarlardan girilmiş "Rapor Başlığı" / "Kurum Bilgileri" yer alır.
    - Tüm Türkçe karakterler (ç, ş, ğ, ü, ö, ı, İ) bozulmadan görüntülenir.
    - Metni uzun form hücreleri (Yapılan İşlem satırı vb.) kesilmez, bir alt satıra geçerek tablo hücresini aşağı doğru genişletir.
- **TC-M03: DOCX ve Paylaşım**
  - **Adım:** "Rapor Al -> DOCX Kaydet/Paylaş" yapılarak cihazın "Belgeler" veya "Karşıdan Yüklemeler" (Downloads) dizinine kayıt edilir.
  - **Beklenen Sonuç:** DOCX formatlı dosya cihazdaki Microsoft Word veya Google Dokümanlar gibi bir uygulamada tam bir tablo formunda açılır.
