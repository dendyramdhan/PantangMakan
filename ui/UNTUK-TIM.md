Grup 5 · Jalur Tim · PantangMakan

Prototipe: https://safe-scan-snack.lovable.app/

Naskah slide. Isinya sama dengan `presentasi/PantangMakan.pptx`. Yang dinilai: app iOS yang jalan, plus tiga berkas di folder iCloud.

## Tim Kami

Bagian ini tidak dinilai. Pekerjaan dan peran diisi setelah disepakati di grup.

| Nama | Pekerjaan saat ini | Peran di tim |
| --- | --- | --- |
| Muhammad Fajar Wira Azdi | | |
| Ahmad Syafiq Kamil | | |
| Dendy Ramdhan Fauzy | | |
| Mohamad Arrizal | | |
| Zuber Khatib | | |

## Masalah yang Kami Selesaikan

- Pengguna: yang punya pantangan makan, karena alergi atau pilihan sendiri.
- Masalah: huruf daftar komposisi di kemasan terlalu kecil, jadi bahan pantangan terlewat.
- Asal masalah: dari pengguna yang punya pantangan. Saat presentasi, sebut nama dan pantangan pengguna sungguhan.
- Cara app menyelesaikannya: pilih pantangan sekali, foto komposisinya, lalu baca satu kalimat.
- Dampak lain: nama bahan asing ikut dikenali. Arachis hypogaea terbaca sebagai kacang.

App tidak memakai kata "aman". Kalimatnya hanya melaporkan isi komposisi: "Ada kacang dan pemanis di komposisi ini." atau "Tidak ditemukan garam di komposisi ini."

## Solusi Berbasis AI

Satu alur, dari foto sampai kalimat. Bagian "HASIL AI" di layar hasil menunjukkan label Create ML dan sumber kalimat.

1. Vision (side-app, baca teks dari foto) membaca huruf di foto. Yang dipakai hanya teks di bawah judul Komposisi, Ingredients, atau Daftar bahan. Kalau judul itu tidak ada: "Ditolak. Gambar ini bukan daftar komposisi."
2. Create ML (diajarkan, sesi 1.3) menebak jenis pantangan dari teks komposisi, misalnya "kacang 92%".
3. Foundation Models (diajarkan, sesi 2.6) menyusun kalimatnya. Jalan di iPhone yang Apple Intelligence-nya menyala.
4. API Dicoding (side-app, model di server) dipakai kalau model Apple tidak tersedia. Kalau koneksi gagal, kalimat tetap keluar dari daftar kata, dengan tombol Coba lagi.

Kalimat dari model dicek dulu. Kalau tidak lolos, app memakai kalimat dari daftar kata. Warna kartu selalu dari daftar kata sesuai pantangan yang dipilih.

Bahan yang mirip tulisannya tidak ikut. Cocoa butter bukan susu. Susu kedelai bukan susu. Sodium benzoate bukan garam. Glukosa bukan gluten.

## Demo Produk

1. Happy path: pilih kacang dan pemanis, foto komposisi yang memuat kacang dan gula. Kartu merah.
2. Tanpa menutup app: tekan Ubah, pilih garam, foto komposisi teh. Kartu hijau.
3. Unhappy path: foto depan kemasan. "Ditolak", gambar kemasan dicoret, dan tombol Foto ulang.
4. Cadangan: izin kamera ditolak. Pesan dan tombol Buka Pengaturan.

## Validasi Produk

Evaluasi belum dijalankan. Foto 10 kemasan sungguhan, lalu isi:

- Input yang dicoba: __
- Berhasil: __ dari __
- Contoh yang gagal: __
- Lesson learned: model bahasa kadang menambah kata sendiri, misalnya "Fakta:" di depan kalimat. Karena itu kalimatnya dicek dulu.

## Rencana Pengembangan

Lengkapi daftar nama bahan. Nama bahan dari kemasan yang salah dibaca ditambahkan ke daftar kata, lalu kemasan yang sama dicoba lagi.

## Pengumpulan

Sebelum 15:30, folder iCloud `Grup 5 - PantangMakan` berisi slide `.pptx` dari template panitia, `link-github.txt` berisi https://github.com/dendyramdhan/PantangMakan, dan screenshot atau video demo.
