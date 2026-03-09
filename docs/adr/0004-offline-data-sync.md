# ADR 004: Çevrimdışı Veri Senkronizasyonu (Offline Data Sync / Merge)

**Durum:** Kabul Edildi (Accepted)  
**Tarih:** 09.03.2026  
**Hazırlayan:** Serhan Şeftalioğlu & Gemini

---

## 1. Bağlam (Context)
Saha teknisyenlerinin uygulamanın içine girdikleri verileri, internet üzerinden anlık bir merkezi sunucuya atamadıkları durumlarda, gün sonunda verilerini merkez bilgisayarı (veya yöneticinin tableti) ile birleştirmeleri (Merge) gerekmektedir. Bu durum, "Merkezi bir backend olmadan çok kullanıcılı deneyim nasıl sağlanır?" sorusunu doğurur.

## 2. Karar (Decision)
Offline P2P (Peer-to-Peer) veri senkronizasyonu için **JSON Data Exchange (Import/Export)** mimarisine karar verilmiştir. Kullanıcı, seçtiği kayıtları veya tüm veritabanını belirli bir formata sahip JSON dosyasına (`.ddb` veya `.json`) çevirerek WhatsApp, Mail veya USB kablo ile diğer tarafa iletir. Alıcı cihaz bu dosyayı "İçe Aktar (Import)" diyerek okur.

## 3. Mimari Gerekçeler ve Çakışma Yönetimi (Conflict Resolution)
Bu sistemin en riskli tarafı Duplikasyon (Aynı verinin iki defa yazılması) riskidir. Bunu engellemek için:
- Her cihaza uygulama kurulurken `UUID v4` ile benzersiz bir Cihaz ID (veya User ID) atanır. Her kayıt satırına `created_by_device_id` gizli kolonu eklenir.
- Bir JSON içe aktarıldığında cihaz mevcut veritabanına bakarak `(elevator_no + maintenance_date + action_done + created_by_device_id)` değerlerinin hash'ini kontrol eder. 
- Eğer hash aynı ise bu kayıt "Zaten mevcut" sayılarak atlanır (Ignore).
- Farklı ise veritabanına yeni ID ile (Auto-Increment) `INSERT` edilir.

## 4. Sonuçlar (Consequences)
**Olumlu:** Sunucu (Server) maliyeti sıfırdır. Tamamen KVKK uyumludur, veri kurumun kendi ağındaki cihazlar/iletişim araçları arasında gezer. Teknik arıza olsa bile kullanıcı her zaman Excel mantığında verisini flash bellek ile taşıyabilir.
**Olumsuz:** Gerçek zamanlı (Real-time) senkronizasyon yoktur. Kullanıcı manual olarak (WhatsApp üzerinden) dosya göndermek zorundadır. Kullanıcılar çakışmayı yönetme noktasında bazen hataya düşüp aynı veriyi farklı günlerde sisteme sokarsa duplicate oluşabilir.

## 5. Reddedilen Seçenekler
- **Firebase / Supabase (Cloud Sync):** Saha personeli internet olmadan da kesintisiz çalışmalı kuralı ve ilk versiyonda bakım, sunucu maliyeti yüklenilmek istenmediği için reddedildi (Faz 2'ye bırakıldı).
- **Wi-Fi Direct / Bluetooth (P2P):** Yakın alan paylaşımda teknisyenlerin cihaz eşleştirme sorunları, Android ve iOS dosya sistemi bariyerleri sebebiyle geliştirme maaliyeti çok yüksek bulundu. Onun yerine Android'in share (Paylaş) intent'i (WhatsApp vb.) çok daha düşük maliyetli görülmüştür.
