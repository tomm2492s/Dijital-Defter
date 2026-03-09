# ADR 003: Yerel Veritabanı (Local Database) Seçimi

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 09.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)
Dijital Defter uygulamasının "Offline-First" (İnternetsiz öncelikli) yapısı gereği, teknisyenlerin asansör boşluklarında veya sahada girdikleri verilerin cihazda güvenli, hızlı ve yapısal (relational) olarak saklanması gerekmektedir. İleride eklenebilecek tablo ilişkileri (örn. Sayfa -> Kayıt ilişkisi) ve raporlama (PDF) ihtiyaçları için verilerin düzgün formatlanabiliyor olması kritiktir.

## 2. Karar (Decision)
Flutter ekosisteminde SQLite kullanımını sağlayan **sqflite** paketinin ana veritabanı motoru olarak kullanılmasına karar verilmiştir.

## 3. Mimari Gerekçeler
- **İlişkisel Veri İhtiyacı:** Defter sayfaları (`sheet_pages`) ile bakım kayıtları (`maintenance_records`) arasındaki One-to-Many ilişkisini FOREIGN KEY constraint'leri ile yönetebilmek.
- **Sorgu Esnekliği:** İleride eklenecek filtreleme mekanizmaları (Örn: "Sadece Malzeme Adı X olan ve Durumu Y olan kayıtları getir") için standard SQL sorgularının gücünden faydalanmak.
- **Export/Import Kolaylığı:** `.db` formatındaki SQLite dosyası, yedekleme (Backup) süreçlerinde tek bir dosya olarak kopyalanabilir ve paylaşılabilir.

## 4. Sonuçlar (Consequences)
**Olumlu:** SQL bilgisine sahip her geliştirici projeye dahil olabilir. Tablo ilişkileri sayesinde veri bütünlüğü (Data Integrity) en üst seviyededir.
**Olumsuz:** NoSQL (Object tabanlı) çözümlere kıyasla Dart objelerinden SQL satırlarına Mapping (toMap, fromMap) işlemleri için ekstra boilerplate kod yazımı gerektirir. 

## 5. Reddedilen Seçenekler
- **Hive:** Çok hızlı bir NoSQL Key-Value veritabanı olmasına rağmen, kompleks filtreleme ve (JOIN gibi) ilişkili veri yönetimi zayıf olduğu için asansör kayıt raporlamaları için yetersiz bulundu.
- **Realm / Isar:** Object-oriented local DB'ler performansta harika olsa da, ekip deneyimi ve SQLite'ın endüstri standardı oluşu (SQL formatından PDF'e / diğer raporlara geçişin bilinen yolları) sebebiyle sqflite tercih edildi.
- **Shared Preferences:** Sadece Ayarlar (Kurum Adı, Dönem vb.) gibi basit veriler için kullanılacaktır; bakım kayıtları için büyüklüğü ve mimarisi elverişsizdir.
