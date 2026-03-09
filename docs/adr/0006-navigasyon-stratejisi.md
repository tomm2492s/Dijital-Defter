# ADR 006: Navigasyon ve Sayfa Yönlendirme (Routing) Stratejisi

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 09.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)
Uygulamanın kaç ekrandan oluşacağı, ekranlar arası veri taşımanın (örn. ID parametresi ile Form ekranına gitmek) nasıl yapılacağı, derin bağlantı (Deep Linking) ihtiyacı olup olmadığı gibi konularda bir standart belirlenmesi gerekmektedir. 

## 2. Karar (Decision)
Uygulamanın v1 aşamasında **Standart Flutter Navigator (Navigator 1.0)** yapısının isimlendirilmiş rotalar (Named Routes - `Navigator.pushNamed`) ile kullanılmasına karar verilmiştir. GoRouter veya AutoRoute gibi Navigator 2.0 çözümlerine şimdilik geçilmemiştir.

## 3. Mimari Gerekçeler
- **Ekran Sayısı ve Karmaşıklık:** Dijital Defter, v1 itibarıyla nispeten az sayıda (Dashboard, Liste, Form, Ayarlar, Önizleme) ekrana sahiptir. İç içe geçmiş (nested) rotasyonlar, alt tab menüleri gibi karmaşık seyir sistemleri bulunmamaktadır.
- **Parametre Aktarımı:** Sınırlı sayıdaki parametreler (`arguments` ile) kolayca yeni ekrana aktarılabilir.
- **Geliştirme Hızı:** Navigator 2.0'ın öğrenme eğrisi ve setup süresi, MVP çıkarılmak istenen bu proje için gereksiz zaman kaybı olarak değerlendirilmiştir.

## 4. Sonuçlar (Consequences)
**Olumlu:** Basit kurulum, ekstra paket bağımlılığı yok, kolay anlaşılır standart kod yapısı.
**Olumsuz:** Web/PWA versiyonu çıkarılmak istendiğinde URL yönetimi (URL Sync) zorlaşacaktır (Ancak projenin mevcut odak platformu Mobildir). Animasyonlu geçiş tipleri her rota için manuel tanımlanmalıdır.

## 5. Reddedilen Seçenekler
- **GoRouter:** Resmi paket ve çok güçlü olmasına rağmen, sadece 5-6 ekranı olan kapalı devre (offline) bir mobil uygulama için over-engineering (aşırı mühendislik) kabul edildi. Web/Desktop hedefleri ciddileştiğinde migration (göç) yapılabilir.
- **AutoRoute:** Kod üretimi (Code Generation - `build_runner`) gerektirdiği için derleme (build) sürelerini uzatacağından reddedildi.
