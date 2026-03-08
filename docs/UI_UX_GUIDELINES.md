# UI/UX Kılavuzu (UI/UX Guidelines)

Dijital Defter uygulamasının görsel ve deneyim standartları. Tüm yeni widget ve sayfalar tasarlanırken bu belgedeki kurallara uyulmalıdır.

## 1. Görsel Kimlik ve Renk Paleti

`AppColors` (genellikle `lib/utils/app_colors.dart` altında bulunur) sınıfında tanımlanan merkezi renk teması kullanılır.

- **Primary (Ana Renk):** Uygulamanın marka rengi. Başlıklar ve ana AppBar için kullanılır.
- **Secondary / Accent:** Floating Action Button (FAB) ve öne çıkarılan butonlarda kullanılır.
- **Background / Surface:** Listeler ve kartlar için arka plan renkleri (light theme: material white veya açık gri; açık alanda yansımayı azaltacak kontrastta).
- **Durum Renkleri (Semantic Colors):**
  - **Success (Başarılı/Yapıldı):** Yeşil. `status == 1` olduğunda veya "Yapıldı" switch'i aktifken metin, sınır (border) veya ikon rengi.
  - **Error (Hata/Yapılmadı):** Kırmızı. `status == 0` olduğunda veya validasyon hatalarında kullanılan renk.

## 2. Tipografi (Fontlar)

Projede varsayılan Material Design fontları veya belirtilmişse **Noto Sans** kullanılır.

- **Başlıklar (Headings):** AppBar (kalın, 20-22sp) ve sayfa içi ana başlıklar.
- **Gövde (Body Text):** Liste öğeleri (14-16sp).
- **Tablo İçi (Table Text):** Daha küçük bir punto (12-14sp) ile PDF ve tablo formlarında okunabilirlik maksimize edilir. PDF raporlarında Türkçe karakter desteği için `Noto Sans` veya `PdfGoogleFonts` zorunludur.

## 3. Form Görünümü (Form Design)

1. Saha personeli genellikle tek elle işlem yapabileceğinden girdiler büyük dokunma alanlarına sahip olmalıdır.
2. Zorunlu alanların (Asansör No, Malzeme Adı, Yapılan İşlem vs.) yanında görsel bir belirteç (*) bulunmalıdır.
3. Form girişleri kaydedilirken hata varsa TextField kırmızı çerçeveye (error border) dönüşmeli ve açıklayıcı hata mesajı (örn: "Lütfen demirbaş no giriniz.") göstermelidir.
4. "Durum" (status) bir Switch aracı ile yönetilir, sağında "Yapıldı" veya "Yapılmadı" metni Switch hareketine göre dinamik olarak renk (Yeşil/Kırmızı) değiştirir.

## 4. Kullanıcı Deneyimi Prensipleri

- **Single Screen Entry:** "Defter" hissini korumak için veri girişi tek formda yapılmalı, gereksiz adım/sihirbaz (wizard) kullanılmamalıdır.
- **Anında Geri Bildirim:** Liste güncellemeleri anında (optimistic update veya FutureBuilder tekrarı ile) olmalı, "Kaydedildi" gibi Snackbar mesajları mutlaka gösterilmelidir.
- **Hızlı Ardışık Kayıt:** Form sayfasının altındaki "Kaydet ve yeni kayıt ekle" butonu ile sayfa geçişlerinden doğan bekleme süresi ortadan kaldırılır.
- **Erişilebilirlik (A11y):** Form alanları (TextField) için karanlıkta dahi görülebilecek yüksek kontrast oranı zorunludur.
