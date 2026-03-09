# ADR 002: Uygulama İçi Durum Yönetimi (State Management) Seçimi

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 09.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)
Uygulamanın form ekranlarından girilen verilerin anında liste ekranlarına yansıması, offline çalışan uygulamanın çoklu sayfa yönetimi (Sayfa ekleme, silme, sıralama) ve ayarlar ekranında yapılan tercihlerin (Sütun gizleme, Rapor başlığı vb.) global olarak tüm uygulamaya duyurulması için güvenilir, sürdürülebilir ve esnek bir State Management (Durum Yönetimi) mimarisine ihtiyaç vardır.

## 2. Karar (Decision)
**Provider** paketinin temel state management çözümü olarak kullanılmasına karar verilmiştir. (Eğer mevcut yapıda BLoC kullanılıyorsa, karar BLoC yönünde kalacaktır ancak küçük/orta ölçekli offline-first yapılar için Provider/Riverpod tercih sebebidir).

## 3. Mimari Gerekçeler
- **Öğrenme Eğrisi ve Bakım:** Provider, Flutter ekibi tarafından önerilen ve öğrenmesi BLoC'a göre daha kolay, boilerplate kodu daha az olan bir yapıdır.
- **Performans:** Uygulamanın anlık değişen durumları (Formdaki switch'in tiklenmesi vb.) lokal Widget state'i (`StatefulWidget`) ile, sayfalar arası global durumlar (Veritabanı okumaları, ayarlar) ise Provider ile yönetilecektir.
- **Kapsam:** MVP aşamasında uygulamanın state karmaşıklığı çok yüksek olmadığı için Redux veya BLoC gibi ağır altyapılara ihtiyaç duyulmamıştır.

## 4. Sonuçlar (Consequences)
**Olumlu:** Geliştirme hızı artar. Kod okunabilirliği daha temiz kalır. Yeni geliştiricilerin projeye adaptasyonu kolaylaşır.
**Olumsuz:** İleride çok karmaşık asenkron Cloud Sync akışları gelirse, Provider'ın yetenekleri BLoC kadar katı bir mimari sunmadığı için spagetti koda dönüşme riski taşır (Bunun için servis mimarisi sıkı tutulacaktır).

## 5. Reddedilen Seçenekler
- **BLoC (Business Logic Component):** Uygulama çok fazla stream ve event-driven yapı gerektirmediği için MVP'de aşırı mühendislik (over-engineering) olarak değerlendirildip şimdilik reddedildi.
- **GetX:** Çok yetenekli olsa da Context-free yapısı nedeniyle uygulamanın ilerleyen fazlarında Flutter'ın standart widget ağacı (Widget Tree) yaşam döngüsünden kopma riski taşıdığı için tercih edilmedi.
