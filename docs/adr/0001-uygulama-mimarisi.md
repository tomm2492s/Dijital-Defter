# ADR 001: Dijital Defter Uygulama Mimarisi

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 07.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)

Kurum envanterinde kayıtlı demirbaşların (özellikle asansörlerin) bakım kayıtlarının manuel, fiziksel defterler üzerinden tutulması; veri kaybına, geçmişe dönük arama zorluğuna ve rapor oluşturma sürecinin yavaşlığına neden olmaktadır. Fiziksel "Envanter Bakım Defteri"nin sütun yapısını koruyan ancak güncel ihtiyaçlara (Asansör No, Hızlı Durum Kontrolü) cevap veren mobil bir çözüm gerekmektedir.

## 2. Karar (Decision)

Uygulamanın aşağıdaki teknik yapı ve özelliklerle geliştirilmesine karar verilmiştir.

**Teknik Yığın (Tech Stack)**

- **Platform:** Flutter. Önce **Android** yayımlanacak; **iOS** sonraki fazda (aynı kod tabanı ile) hedeflenecektir.
- **Veri Yönetimi:** Yerel veritabanı (SQLite). İnternet olmayan asansör boşluğu/bodrum kat gibi alanlarda çalışabilmesi için.
- **Raporlama:** pdf ve docx kütüphaneleriyle dinamik tablo oluşturma.

**Veri Yapısı ve Sütunlar**

Görseldeki yapı revize edilerek şu alanlar zorunlu tutulacaktır:

- Sıra No: Otomatik artan sayı
- Demirbaş No: Manuel giriş
- Asansör No: Manuel giriş veya tanımlı listeden seçim
- Malzeme Adı: Bakımı yapılan parça bilgisi
- Bulunduğu Birim: Lokasyon bilgisi
- Bakım Tarihi: Güncel tarih (varsayılan bugün)
- Yapılan İşlem: Teknik detay açıklaması
- Bakım Yapan: Personel ismi
- Durum: Boolean (True/False). Çıktıda ✅ veya ❌ olarak görünecektir

**Not:** Orijinal görseldeki "Sonraki Bakım Tarihi" ve "İmza" alanları kullanıcı talebiyle kaldırılmış; yerine "Asansör No" ve "Durum" eklenmiştir.

## 3. Mimari Tasarım İlkeleri

- **Basitlik:** Minimum tıklama ile veri girişi (Single Screen Entry).
- **Çevrimdışı Öncelik (Offline-First):** Tüm veriler cihazda; paylaşım istendiğinde PDF üretilir.
- **Şablon Uyumu:** PDF çıktısı fiziksel defter formatında standart tablo olacaktır.

## 4. Sonuçlar (Consequences)

**Olumlu:** Bakım kayıtları standartlaşır, raporlama saniyelere iner, kağıt israfı önlenir.

**Olumsuz:** Düzenli yedekleme (Export/Backup) kullanıcı sorumluluğundadır; ileride bulut entegrasyonu gerekebilir.

## 5. Geriye Dönük Uyumluluk (Backward Compatibility)
Uygulamanın v1 sürümünde oluşturulan SQLite veritabanı dosyaları (.db), ileride v2 veya bulut entegrasyonlu modellere geçildiğinde, yerel bir migration scripti aracılığıyla doğrudan JSON API'lerine okunabilecek şekilde tasarlanmıştır.

## 6. Reddedilen Seçenekler

- **Bulut-first:** Saha koşullarında internet zorunluluğu kabul edilmedi; offline-first tercih edildi.
- **Sadece Excel/CSV export:** Resmi rapor ihtiyacı nedeniyle PDF/DOCX zorunlu tutuldu; Excel ileride eklenebilir.
- **Sonraki Bakım Tarihi ve İmza:** Kullanıcı talebiyle v1 kapsamından çıkarıldı; ileride opsiyonel eklenebilir.

## 7. Geri Dönüş Koşulları

Bu karar şu durumlarda revize edilebilir: Kurum zorunlu bulut/merkezi veri talebi; çoklu cihaz/ekip senkronizasyonu ihtiyacı; resmi mevzuatın imza veya ek alan zorunluluğu getirmesi.
