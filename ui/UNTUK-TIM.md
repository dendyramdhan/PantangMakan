Grup 5 · jalur tim · nama app belum final

Prototipe: https://safe-scan-snack.lovable.app/

Naskah slide. Bukan berkas yang dinilai. Yang dinilai: app iOS yang jalan, plus folder iCloud.

## Tim Kami

Bagian ini wajib ada di slide. Pekerjaan dan peran diisi setelah disepakati di grup.

| Nama | Pekerjaan saat ini | Peran di tim |
| --- | --- | --- |
| Muhammad Fajar Wira Azdi | | |
| Ahmad Syafiq Kamil | | |
| Dendy Ramdhan Fauzy | | |
| Mohamad Arrizal | | |
| Zuber Khatib | | |

Lembar absen: Grup 5 lima orang. Pekerjaan dan peran diisi setelah disepakati. Nanny Kurnia Yulianti dan muhammad sutrisno ada di Grup 6.

## Masalah yang Kami Selesaikan

User sudah tahu pantangan makannya, alergi atau yang sengaja dihindari.

Daftar komposisi di kemasan tertulis terlalu kecil, jadi bahan yang harus dihindari terlewat. Masalah ini datang dari user.

Di app, user memilih pantangan dulu, memfoto daftar komposisi, lalu membaca satu kalimat. Kalau bahan yang dipilih ada, kartu merah: "Tidak aman, mengandung garam." Kalau tidak ada, kartu hijau: "Aman, bisa kamu makan, tidak mengandung garam." Lebih dari satu bahan disebut sekaligus, misalnya "Tidak aman, mengandung kacang dan pemanis."

Foto kedua mengganti kalimat itu tanpa menutup aplikasi. User tidak perlu menebak dari huruf yang kecil.

## Solusi Berbasis AI

Satu alur, dari foto sampai kalimat. Layar tidak menuliskan nama model.

1. Kamera dan Vision membaca huruf di foto, bahasa Indonesia dan Inggris. Yang dipakai hanya teks di bawah judul Komposisi, Ingredients, atau Daftar bahan. Informasi nilai gizi, cara penyimpanan, dan berat bersih tidak masuk ke keputusan. Kalau judul itu tidak ada, tulisan "Ditolak" besar, lalu gambar kemasan yang dicoret, dan kalimat "Gambar ini bukan daftar komposisi."
2. Create ML, sesi 1.3, fitur yang diajarkan. Model mengklasifikasi teks komposisi di perangkat. Labelnya tidak tampil di layar.
3. Foundation Models, sesi 2.6, fitur yang diajarkan. Nama model bawaannya `SystemLanguageModel`, model on-device Apple Intelligence. Model ini menyusun satu kalimat dari bahan terpilih yang cocok. Kalimatnya "Aman, bisa kamu makan, tidak mengandung …" atau "Tidak aman, mengandung …". Kalimat ini keluar di iPhone yang Apple Intelligence-nya menyala, atau di Simulator iOS 27. Kalau model itu tidak tersedia, side-app di server menyusun kalimat yang sama. Kalau koneksi juga gagal, kalimat tetap keluar dari kata yang cocok, dengan tombol Coba lagi.

Urutannya sama dengan Fact U Drink! dan My Body Goodness di Challenge Day 3: baca teks dari foto, lalu Foundation Models.

Bahan yang mirip tulisannya tidak ikut. Cocoa butter bukan susu. Susu kedelai bukan susu. Sodium benzoate bukan garam. Glukosa bukan gluten. Nama Inggris dan nama kimia ikut, misalnya arachis untuk kacang.

## Demo Produk

Yang ditunjuk ke tim, mengikuti prototipe:

1. Happy path bahaya. Pilih pantangan. Tekan Pakai kamera, foto daftar komposisi. Foto tampil di atas. Saat dibaca, tiga titik merah tua naik turun di bawah foto, lalu tulisan "Membaca komposisi". Kalau bahan terpilih ada, kartu merah: "Tidak aman, mengandung ...." Kata yang cocok di "Komposisi terbaca" ditandai kapsul merah.
2. Foto kedua, tanpa menutup app. Bahan terpilih tidak ada. Kartu hijau: "Aman, bisa kamu makan, tidak mengandung ...."
3. Foto yang bukan daftar komposisi. Tulisan "Ditolak" besar, lalu gambar kemasan yang dicoret dan kalimat "Gambar ini bukan daftar komposisi." Teks komposisi tidak muncul.
4. Izin kamera ditolak. Pesan di pita kiri, plus tombol Buka Pengaturan.
5. Tombol Foto ulang: ikon di kiri, menempel di tulisan, keduanya di tengah tombol. Judul layar dan kalimat hasil sama ukurannya.

Di prototipe web, Pakai kamera membuka kamera simulasi. Di bawahnya ada contoh untuk pantangan yang dipilih: Contoh ada [bahan], Contoh tanpa [bahan], dan Contoh bukan komposisi. Kalau lebih dari satu yang dicentang, pemilih kecil mengetes satu bahan. Contoh itu hanya ada di prototipe. App iOS tidak menampilkan tombol contoh.

## Validasi Produk

Evaluasi belum dijalankan.

- Input yang dicoba: 10 foto kemasan
- Berhasil: __ dari 10
- Contoh yang gagal: __
- Lesson learned: Foundation Models selalu gagal di Simulator iOS 26. Di Simulator iOS 27 kalimatnya keluar.

## Rencana Pengembangan

Sabtu 17 Oktober, foto 10 kemasan sungguhan di meja. Catat berapa yang benar dan satu contoh yang gagal. Angka itu masuk ke slide bagian 5.

## Pengumpulan

Sebelum 15:30, folder iCloud `Grup 5 - PantangMakan` berisi tiga berkas: slide `.pptx` dari template panitia, `link-github.txt` ke repo public, dan screenshot atau video demo.
