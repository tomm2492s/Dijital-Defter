# Kullanıcı Kılavuzu (User Guide)

Bu kılavuz "Dijital Defter" uygulamasını sahada nasıl kullanacağınızı adım adım açıklamaktadır.

## 1. İlk Kurulum ve Ayarlar

Uygulamayı ilk açtığınızda kurum bilgilerinizi girmek için **Ayarlar** menüsüne gidin (Genellikle menüde veya sağ üst köşedeki dişli çark ikonundadır).
1. "Kurum/İşletme Adı" alanını doldurun.
2. "Bulunduğunuz Birim", "Sorumlu Kişi" ve "Dönem" alanlarını organizasyonunuza uygun doldurun.
3. Rapor Başlığı alanına raporlarınızda en üstte görünmesini istediğiniz başlığı yazın (Örn: ENVANTER BAKIM DEĞERİ).

*Not: Bu bilgiler PDF ve DOCX raporları oluşturulurken üst bilgi olarak otomatik basılacaktır.*

## 2. Ana Ekran ve Kayıt Sayfaları

Ana ekranda uygulama logosu ve "Dijital Defter" başlığı görünür. Sağ üstte Rapor Al ve Ayarlar (dişli) ikonları vardır.

Fiziksel bir defterin sayfaları gibi, kayıtlarınız sayfalar (Sheet Pages) altında gruplanır.
1. Ana ekranda **(+) Yeni Sayfa** butonuna tıklayarak o güne, o haftaya veya o binaya ait yeni bir defter sayfası oluşturabilirsiniz.
2. Oluşturduğunuz veya önceden var olan defter sayfalarından birine dokunarak sayfa detayı görünümüne geçin.

## 3. Bakım Kaydı Girmek

Sayfa detayına girdiğinizde varsa geçmiş kayıtlar bir tablo olarak listelenir.
1. Yeni kayıt eklemek için **(+) Yeni Satır Ekle** (veya benzeri bir isimdeki) eylem butonuna dokunun.
2. **Demirbaş No**, **Asansör No**, **Malzeme Adı**, **Bulunduğu Birim** gibi detayları doldurun.
3. Uygulanan işlemi **Yapılan İşlem** satırına yazın.
4. **Bakım Tarihi** standart olarak "bugün" seçilidir ancak üzerine dokunarak istediğiniz günü seçebilirsiniz.
5. Eğer işlem yapıldıysa **Durum** anahtarını açık/yeşil (Yapıldı) konumuna, yapılmadıysa kapalı/kırmızı (Yapılmadı) konumuna getirin.
6. Tek kayıt giriyorsanız "Kaydet" deyin. Hemen peşine devam edecekseniz "Kaydet ve yeni kayıt ekle" butonunu kullanın. Form sıfırlanıp ardışık kayıt yapmanıza olanak tanıyacaktır.

> Not (gelecek sürümler): Uygulama; Ayarlar ekranında tanımlanacak global bir bakım periyodu (örneğin 3 ay veya 6 ay) üzerinden, girdiğiniz **Bakım Tarihi** bilgilerini takip ederek ileride bakım zamanı yaklaşan veya geciken kayıtları ana ekranda özet bir listeyle hatırlatacak şekilde genişletilebilir. Bu mantıkta kayıt formuna ekstra alan eklenmez; takip tamamen uygulama genelindeki tarih ve periyot ayarları üzerinden yapılır.

## 4. Rapor Oluşturma ve Görüntüleme

Bir defter sayfasındayken tüm o sayfadaki satırları döküme almak için işlemi şu şekilde yaparsınız:
1. Sayfa detay ekranındayken **"Rapor Al"** butonuna dokunun.
2. Karşınıza 4 seçenekli bir Rapor Menüsü gelir:
   - **PDF ile Görüntüle:** Tıkladığınızda sayfa boyutlu PDF önizlemeye geçersiniz. Parmağınızla yakınlaştırıp detayları okuyabilirsiniz. (Buradan da direkt paylaşım yapabilirsiniz).
   - **PDF Kaydet / Paylaş:** Doğrudan WhatsApp, e-posta açılır veya "Telefona Kaydet" dersiniz.
   - **DOCX ile Görüntüle:** Word formatında dosya açılır (cihazınızda Word destekleyen bir uygulama olmalıdır).
   - **DOCX Kaydet / Paylaş:** Tablo yapılandırmasını değiştirmek, daha sonra üzerine imza satırı eklemek için DOCX versiyonunu cihazınıza veya mailinize kaydedersiniz.

## 5. Ayarlar – Neler yeni, Yedekleme ve Hata Raporu

**Neler yeni:** Ayarlar ekranında **Kaydet** butonunun **altında** **"Neler yeni"** bölümü bulunur. Ekranı **aşağı kaydırmanız** gerekir (form alanları ve Kaydet’ten sonra). "Yapılan işler ve güncellemeler" kartına dokunduğunuzda uygulama özellikleri ile son güncellemelerin listesi açılır (özellikler, raporlama, yedekleme, hata loglama vb.).

Ayarlar ekranında **Yedekleme** bölümünden veritabanını (.db) veya veriyi (JSON) dışa aktarıp paylaşabilirsiniz.

**Hakkında:** Ayarlar ekranının en altında "Hakkında" bölümünde uygulama adı, sürüm ve geliştiren kişi bilgisi yer alır.

**Hata kayıtları:** Uygulama, oluşan hataları cihaz hafızasında saklar. Bir sorun yaşadığınızda veya teknik destek istediğinizde:
1. **Ayarlar** > **Hata kayıtları** bölümüne gidin.
2. **Hata raporunu paylaş** butonuna dokunun.
3. Kayıtlı hata varsa, tüm hata bilgilerini içeren bir metin dosyası (.txt) oluşturulur ve paylaşım menüsü açılır; WhatsApp, e-posta vb. ile gönderebilirsiniz.
4. Kayıtlı hata yoksa "Kayıtlı hata yok." mesajı görünür.

## 6. Tablo Sütunlarını ve Durum Metinlerini Özelleştirme / Gizleme

**Sütun başlıklarını ve durum metinlerini değiştirme:**

- **Ayarlar** ekranında, **"Tablo başlıkları ve durum metinleri"** kartı içinde Demirbaş No, Asansör No, Malzeme Adı, Bulunduğu Birim, Tarih, Yapılan İşlem, Bakım Yapan ve Durum için istediğiniz sütun başlıklarını girebilirsiniz.
- Aynı kartta, **Durum = true** ve **Durum = false** metinlerini (örneğin *Yapıldı / Yapılmadı* yerine *Uygun / Uygun Değil*) kendi kullanımınıza göre güncelleyebilirsiniz. Bu metinler kayıt formunda, tablo görünümünde ve PDF/DOCX raporlarda aynı şekilde kullanılır.

**Sütunları global olarak gizleme:**

- Aynı kartın altında yer alan **"Gizlenecek sütunlar"** bölümünde, ihtiyaç duymadığınız sütunları işaretleyerek **global olarak gizleyebilirsiniz**.
- Burada gizlediğiniz sütunlar:
  - Sayfa detaylarındaki tablo görünümünde gösterilmez.
  - **"Tablo görünümünü düzenle"** ekranında eklenebilir sütunlar listesinde yer almaz.
  - PDF ve DOCX rapor çıktılarında da aynı şekilde hiç görünmez.
