# Gelecek Planlaması ve Backlog (Future & Backlog)

"MoSCoW" matrisinde "Could Have" ve "Won't Have (v1)" olarak belirlenmiş olan, uygulamanın sonraki sürümlerine dahil edilebilecek geliştirme önerileridir.

## 1. Bulut Senkronizasyonu & Yedekleme
- **Google Drive / Dropbox Export:** `sqlite.db` dosyasının otomatik veya manuel olarak bulut depolama servislerine yüklenmesi.
- **Çoklu Mobil Cihaz Senkronizasyonu:** Merkezi bir PostgreSQL/MySQL veritabanı kurarak REST API aracılığıyla farklı teknisyenlerin aynı binaya veri girmesini sağlayan ekip senkronizasyonu modeli. (Requires Backend).

## 2. Multimedya Özellikleri
- **Fotoğraf Ekleme:** Olası arıza durumlarında teknisyenin kameradan veya galeriden arızalı parçanın/asansörün fotoğrafını çekip `maintenance_records` alanına path (yol) veya Base64 olarak bağlaması.
- **PDF'e Fotoğraf Ekleme:** Eklenmiş fotoğrafların, cihazdaki bellek durumunu gözeterek (kırpılarak/sıkıştırılarak) üretilen "Rapor PDF"inin en son sayfasına "Ek Dosyalar" olarak otomatik basılması.

## 3. Kurumsal / Resmi İş Akışları
- **E-İmza (E-Signature):** Saha personelinin ekranda parmağıyla/kalemle imza atması (Signature Pad) ve bu imzanın dijitalize edilerek DOCX/PDF'in altına otomatik yerleştirilmesi. (Fiziksel defterdeki orijinal imza kolonuna daha sadık kalınması için).
- **Yönetici Onayı:** Oluşturulan PDF'in e-posta üzerinden değil de, uygulama içi bir sistem aracılığıyla yöneticinin onay/red akışına gönderilmesi.

## 4. Kullanıcı Arayüzü İyileştirmeleri (UI/UX)
- **Koyu Tema (Dark Mode):** Sistem temasına bağlı olarak veya ayarlardan değiştirilebilen Dark Mode desteği.
- **Gelişmiş Filtreleme ve Arama Ekranı:** "Şu ay ile bu ay arasındaki tüm *Yapılmadı* olan kayıtlar" gibi karmaşık sorgular yapabilen gelişmiş bir Dashboard özeti ve arama widget'ı.
- **Çoklu Dil (Multi-language):** \`arb\` dosyası entegrasyonu ile uygulamanın aynı dilde English/Turkish seçenekleri sunması (Genel pazar hedeflenirse).
- **Excel (.xlsx/csv) Export:** Tablonun doğrudan Excel'de çalışılabilir formata dönüştürülmesi (Mevcut DOCX'e alternatif).
