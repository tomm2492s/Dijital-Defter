# ADR 005: Raporlama ve Çıktı Üretim (PDF/DOCX) Motoru

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 09.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)
Uygulamanın en temel vaadi, sahada manuel tutulan bakım kayıt defterini dijitalleştirip profesyonel formata (PDF ve DOCX) saniyeler içinde çevirmek. Bu çıktıların hem her cihazda aynı stabilitede görünmesi hem de Türkçe karakter/font sorunları yaşamaması gerekmektedir.

## 2. Karar (Decision)
Flutter ortamında döküman üretimi için **`pdf`** ve **`printing`** paketleri (PDF için) ve DOCX üretimi için harici bir kütüphane/şablon sistemi (Örn. `docx_template` veya `docx_creator`) kullanılmasına karar verilmiştir. 

## 3. Mimari Gerekçeler
- **Native PDF Desteği:** `pdf` paketi, arka planda web görünümüne (HTML-to-PDF) ihtiyaç duymadan doğrudan Canvas üzerinden PDF çizer. Bu da işlem hızını artırır ve offline ortamlarda dış bağımlılık yaratmaz.
- **Tablo Yapısı:** Fiziksel defterin mizanpajını birebir taklit etmek için `Table` ve `TableRow` widget'larını destekler. Uzun metinlerde otomatik alt satıra geçme (Word-wrap) özelliği rakiplerine göre daha stabildir.
- **Önizleme:** `printing` paketinin sunduğu `PdfPreview` widget'ı, Flutter UI'ı içinde native bir PDF görüntüleyici sağlar. 

## 4. Sonuçlar (Consequences)
**Olumlu:** Çıktı alma süresi milisaniyeler seviyesine iner. Kurum adı, logo gibi Header bilgileri her sayfaya dinamik olarak basılabilir.
**Olumsuz:** PDF tasarımı esnasında standart Flutter Widget'ları (`Column`, `Row` vb.) yerine `pdf` kütüphanesinin kendi özel UI elementleri (`pw.Column`, `pw.Row`) kullanılmak zorundadır, kod tekrarı yaratabilir.

## 5. Reddedilen Seçenekler
- **HTML-to-PDF:** HTML şablonları tasarlayıp PDF'e çevirmek (örn. `flutter_html_to_pdf`) web için kolay olsa da mobil cihazların render motorlarına (Webview) bağımlılık yaratır. Performansı değişkendir ve font yüklemelerinde sorun yaşatabilir.
- **Sadece CSV/Excel:** Basitliği nedeniyle cazip olsa da hedef kitlenin (Denetmen/Yönetici) resmi evrak formatı beklentisi nedeniyle ana raporlama formatı olarak reddedilmiştir (Ancak opsiyonel olarak eklenebilir).
