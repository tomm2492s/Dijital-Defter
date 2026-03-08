# Pazar Gereksinimleri Dokümanı (MRD): Dijital Defter

**Proje:** Dijital Defter (Bakım Takip Çözümü)  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini | **Sürüm:** 1.0  

**Platform Stratejisi:** Önce **Android** pazarına çıkış; ardından **iOS** ile genişleme (Flutter ile tek codebase).

---

## 1. Hedef Pazar ve Müşteri Segmentasyonu

Dijital Defter, fiziksel denetim ve periyodik bakım gerektiren sektörleri hedefler.

- **Belediyeler ve kamu kurumları:** Kamu binalarındaki asansör, jeneratör, yangın sistemleri takibi
- **Asansör bakım firmaları:** Teknisyenlerin formları dijital doldurup müşteriye anında PDF sunması
- **Site ve apartman yönetimleri:** Teknik envanter (havuz, asansör, hidrofor vb.) kayıt altına alınması
- **Fabrikalar ve endüstriyel tesisler:** Makine parkuru periyodik kontrolleri

## 2. Pazar Problemi (Pain Points)

- **Arşivleme zorluğu:** Kağıt formların ıslanması, kaybolması, okunaksız hale gelmesi
- **Raporlama gecikmesi:** Sahadaki verinin ofise gelip dijitalleşmesi günleri bulabiliyor
- **Hatalı veri:** Bakımın yapılıp yapılmadığının kontrolü zor
- **Maliyet:** Sürekli kağıt basımı ve dosyalama masrafları

## 3. Değer Önerisi (Value Proposition)

- **Fizikselden dijitale köprü:** Tanıdık defter yapısı korunarak personelin adaptasyonu hızlanır
- **"Cepteki mühendis":** Ofise dönmeden asansör başında resmi rapor oluşturma ve paylaşma
- **Güven ve şeffaflık:** ✅/❌ (Yapıldı/Yapılmadı) ile denetim süreçleri netleşir

## 4. Rekabet Analizi

(Doğrudan rakip ürün isimleri sektöre göre eklenebilir.)

| Özellik             | Kağıt Defter | Excel / WhatsApp | Büyük Kurumsal | Dijital Defter |
|---------------------|--------------|------------------|----------------|----------------|
| Hız                 | Yavaş        | Orta             | Orta           | Çok Hızlı      |
| Maliyet             | Düşük        | Düşük            | Çok Yüksek     | Düşük / Orta   |
| Profesyonel PDF     | Yok          | Zor              | Var            | Otomatik       |
| Offline çalışma     | Var          | Kısmen           | Kısmen         | Var            |
| Kullanım kolaylığı  | Kolay        | Zor (mobilde)   | Karmaşık       | Çok Kolay      |

## 5. Başarı Kriterleri (Key Metrics)

- **Zaman tasarrufu:** Manuel raporlama süresi rapor başına 15 dakikadan 1 dakikanın altına inmesi
- **Kullanıcı bağlılığı:** Teknik personelin haftalık aktif kullanım oranı
- **Hata oranı:** Eksik alan bırakılmış form sayısında azalma

## 6. Yol Haritası (Future Roadmap)

- **Faz 1:** Temel veri girişi ve PDF/DOCX çıktısı — **Android** sürümü (mevcut odak)
- **Faz 1.5:** **iOS** sürümü (Flutter ile aynı kod tabanı)
- **Faz 2:** Bulut senkronizasyonu ve ekip yönetimi
- **Faz 3:** Bakım zamanı geldiğinde otomatik bildirimler (Push Notifications)
- **Faz 4:** QR kod ile asansör/bakım eşleştirme ve geçmiş veriye anında ulaşım

## 7. Go-to-Market

- **İlk hedef:** Pilot müşteri veya tek hedef segment (örn. belediye teknisyenleri veya bir asansör bakım firması)
- **Dağıtım:** Android — Google Play Store; gerekirse kurumsal APK. iOS (Faz 1.5) — App Store

## 8. Fiyatlandırma / Lisans (v1)

v1 için ücretsiz veya tek seferlik sembolik ücret; reklam yok. Abonelik veya kurumsal lisans ileride değerlendirilebilir.
