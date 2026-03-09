# İş Gereksinimleri Dokümanı (BRD): Dijital Defter

Bu doküman, uygulamanın iş mantığını, kapsamını ve paydaş beklentilerini netleştirmek için hazırlanmıştır.

**Proje:** Dijital Defter (Asansör ve Envanter Bakım Takip Sistemi)  
**Versiyon:** 1.0 | **Tarih:** 07.03.2026  

**Platform Yaklaşımı:** Önce **Android**; **iOS** sürümü daha sonra aynı teknik altyapı (Flutter) ile eklenecektir.

---

## 1. Giriş ve Amaç

Mevcut durumda fiziksel kağıtlar üzerinde tutulan "Envanter Bakım Defteri" kayıtlarının dijitalleştirilmesi amaçlanmaktadır. Bu dönüşüm ile veri kaybı önlenecek, raporlama hızlanacak ve geçmişe dönük verilere erişim kolaylaşacaktır.

## 2. İş Hedefleri

- **Hız:** Manuel rapor yazma süresini %90 azaltmak
- **Hata payı:** Okunaksız el yazısı veya eksik veri girişinden kaynaklanan hataları minimize etmek
- **Erişilebilirlik:** Geçmiş bir bakım kaydına saniyeler içinde ulaşabilmek
- **Standartlaşma:** Tüm bakım raporlarının aynı profesyonel formatta (PDF/DOCX) üretilmesi
- **Ekip İçi Veri Bütünlüğü:** Sahadaki birden fazla personelin girdiği verilerin merkezde veya kendi aralarında birleştirilebilir olması (Data Sync).

### 2.1. Yatırım Getirisi (ROI) ve Maliyet İstihbaratı
Uygulamanın v1 sürümü yerel depolama ve ücretsiz kullanım hedeflenerek geliştirilmektedir. Bulut sunucu maliyetleri (AWS/Firebase) v1'de sıfırdır. Tek seferlik Google Play Store lisans maliyeti ($25) dışında sabit gider yoktur. Uygulamanın kullanımıyla, her teknisyenin günlük ortalama 1 saatlik raporlama süresi tasarruf edilecek; bu da haftalık minimum 5 adam/saat (kişi başı) iş gücü kazanımı sağlayacaktır.

## 3. Paydaşlar (Stakeholders) ve RACI Matrisi

**Paydaş Listesi:**
- **Saha personeli:** Veri girişini yapan teknik personel
- **Yöneticiler / denetmenler:** Çıktıları kontrol eden ve onaylayan makamlar
- **BT geliştirme:** Uygulamanın teknik bakımından sorumlu (Serhan Şeftalioğlu)

**RACI Matrisi:**
| Görev / Süreç | Yapan (Responsible) | Onaylayan (Accountable) | Danışılan (Consulted) | Bilgilendirilen (Informed) |
|---------------|---------------------|-------------------------|-----------------------|----------------------------|
| Veri Girişi   | Saha Personeli      | Denetmen                | -                     | Yönetici                   |
| Rapor Üretimi | Saha Personeli      | Denetmen                | -                     | Yönetici, Müşteri          |
| Uyg. Geliştirme| BT Geliştirme       | Yönetici                | Saha Personeli        | Denetmen                   |
| Veri Birleştirme| Denetmen/Yönetici  | Yönetici                | BT Geliştirme         | -                          |

## 4. Fonksiyonel Gereksinimler

### 4.1. Veri Yönetimi

- **Kayıt oluşturma:** Demirbaş No, Asansör No, Malzeme Adı, Birim, Bakım Tarihi, İşlem ve Personel bilgileri girilebilmeli
- **Durum kontrolü:** Her işlem için "Yapıldı (✅)" veya "Yapılmadı (❌)" switch/checkbox ile seçilebilmeli
- **Listeleme:** Kayıtlar ana ekranda tarih sırasına göre listelenmeli

### 4.1.1. Bakım Periyodu ve Hatırlatma (Uygulama Bazında, Gelecek Sürüm)

- **Bakım periyodu takibi (global):** Kayıt formuna ek alan eklemeden, yalnızca uygulama ayarlarında tanımlanan global bir bakım periyodu (örneğin 3 ay veya 6 ay) üzerinden bakım tarihlerini takip etme.
- **Sonraki bakım tarihine göre bilgilendirme:** Kullanıcının girdiği bakım tarihine göre sonraki bakım tarihinin (bakım_tarihi + periyot) uygulama tarafından hesaplanması ve bu tarih yaklaştığında veya geçtiğinde kullanıcıya uygulama içinde listeli bir uyarı gösterilmesi.
- **Kullanıcı tarafından ayarlanabilir eşik:** Global periyot ve "X gün önce uyar" gibi eşiklerin Ayarlar ekranından tanımlanabilmesi; bu mekanizmanın sadece uygulama genelinde çalışması, tek tek kayıtlara ekstra alan eklenmemesi.

### 4.2. Raporlama ve Çıktı

- **PDF dışa aktar:** Orijinal defter formatına sadık PDF
- **DOCX dışa aktar:** Düzenlenebilir Word formatında çıktı
- **Asansör No filtresi:** Belirli bir asansöre ait bakımların dökümü alınabilmeli
- **Sütun özelleştirme ve gizleme:** Kullanıcı, tablo sütun başlıklarını ayarlardan özelleştirebilmeli ve ihtiyaç duymadığı sütunları global olarak gizleyebilmelidir; bu gizleme tablo görünümlerine ve PDF/DOCX rapor çıktısına aynı şekilde yansır.

### 4.3. Veri Paylaşımı ve Senkronizasyon (Data Exchange)

- **Veritabanı İçe/Dışa Aktarım (Import/Export):** Kullanıcı veritabanını `.ddb` formatında dışa aktarıp diğer kullanıcılara gönderebilir.
- **Veri Birleştirme (Merge):** Bir kullanıcıdan gelen veri dosyası, mevcut uygulamanın içindeki verilerle çakışmadan (unique ID veya timestamp kontrolü ile) birleştirilebilir (Offline Sync).

## 5. Fonksiyonel Olmayan Gereksinimler

- **Çevrimdışı çalışma:** İnternet olmayan alanlarda kesintisiz çalışma
- **Basit UX:** Form tek sayfada; karmaşık menülerden kaçınılmalı
- **Performans:** PDF oluşturma 2 saniyenin altında

## 6. Başarı Kriterleri (KPI'lar)

- Raporlama süresi: Tek formun PDF olarak paylaşılması 60 saniyenin altında
- Doğruluk: Raporlardaki eksik alan oranı %0 (zorunlu alan validasyonu ile)
- Erişilebilirlik: Arama/filtre ile bir kayda 10 saniye içinde ulaşılabilmeli

## 7. Riskler ve Varsayımlar

**Varsayımlar:** Kullanıcılar düzenli yedek alacak; teknisyen tek cihaz kullanacak; kurum bilgileri bir kez girilip korunacak.

**Riskler:** Cihaz kaybı/hasara bağlı veri kaybı (çözüm: yedekleme uyarısı ve Export); kullanıcının yedek almaması.

## 8. Kapsam Dışı (v1)

v1 kapsamında olmayacaklar: Zorunlu bulut senkronizasyonu, çoklu dil, kurumsal SSO/giriş, ekip/rol yönetimi, bakım fotoğrafı ekleme, dijital imza alanı. İleride değerlendirilebilir.

## 9. Veri Sözlüğü (Sütun Yapısı)

| Alan Adı         | Tip            | Açıklama                          |
|------------------|----------------|-----------------------------------|
| Sıra No          | Otomatik Sayı  | Rapor satır numarası              |
| Demirbaş No      | Alfanümerik    | Kurumun verdiği envanter numarası |
| Asansör No       | Alfanümerik    | Bakımı yapılan asansör kodu       |
| Malzeme Adı      | Metin          | Kontrol edilen parça              |
| Bulunduğu Birim  | Metin          | Lokasyon bilgisi                 |
| Bakım Tarihi     | Tarih          | İşlemin yapıldığı gün             |
| Yapılan İşlem    | Metin          | Teknik müdahale detayı            |
| Bakım Yapan      | Metin          | Sorumlu personel adı              |
| Durum            | Boolean        | Yapıldı (✅) veya Yapılmadı (❌)  |
