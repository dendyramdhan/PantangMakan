Grup 5 · Jalur Tim · PantangMakan

Naskah slide. Isinya sama dengan `presentasi/PantangMakan.pptx`.

## Tim Kami

Bagian ini tidak dinilai. Isi pekerjaan dan peran setelah disepakati, plus foto tim.

| Nama | Pekerjaan saat ini | Peran di tim |
| --- | --- | --- |
| Muhammad Fajar Wira Azdi | | |
| Ahmad Syafiq Kamil | | |
| Dendy Ramdhan Fauzy | | |
| Mohamad Arrizal | | |
| Zuber Khatib | | |

## Masalah yang Kami Selesaikan

Buka dengan cerita satu pengguna sungguhan (nama dan pantangannya) sebelum menunjukkan fitur.

- Pengguna: yang punya pantangan makan, karena alergi atau pilihan sendiri.
- Masalah: huruf daftar komposisi terlalu kecil, jadi bahan pantangan terlewat.
- Cara app menyelesaikannya: pilih pantangan sekali, foto komposisinya, lalu baca satu kalimat.
- Dampak lain: "dapat mengandung" tidak lagi tercampur dengan bahan. Nama Latin seperti arachis hypogaea ikut dikenali.

## Solusi Berbasis AI

1. Vision (side-app, baca teks dari foto) membaca huruf di bawah judul Komposisi atau Ingredients.
2. Create ML (diajarkan, sesi 1.3) memilah tiap kalimat jadi bahan, peringatan, atau lain. Hanya kalimat bahan yang dicocokkan dengan daftar kata.
3. Foundation Models (diajarkan, sesi 2.6) menjelaskan kenapa, di bagian KENAPA.

Bagian HASIL AI di layar menunjukkan jumlah kalimat yang dipilah Create ML dan apakah Foundation Models jalan.

## Demo Produk

1. Happy path: pilih kacang dan pemanis, foto komposisi selai kacang. Kartu merah, penjelasan di KENAPA.
2. Tanpa menutup app: Ubah ke garam, foto komposisi teh. Kartu hijau.
3. Foto label dengan "dapat mengandung kacang": kartu hijau dengan kotak kuning.
4. Unhappy path: foto depan kemasan. Ditolak, ada tombol Foto ulang. Cadangan: izin kamera ditolak, tombol Buka Pengaturan.

Sebelum maju: Apple Intelligence menyala, bahasa iPhone dan Siri English.

## Validasi Produk

- Input: 10 label produk Indonesia dari Open Food Facts, tidak ikut data latih.
- Berhasil: 10 dari 10 dengan Create ML. Sebelumnya 8 dari 10.
- Contoh gagal (versi lama): Superco, "Dapat mengandung telur, kedelai dan kacang" dihitung sebagai bahan.
- Lesson learned: label mencampur bahan dengan peringatan, jadi kalimatnya perlu dipilah dulu.

## Rencana Pengembangan

Uji 30 kemasan dari kamera iPhone sendiri di minimarket, lalu kalimat yang salah dipilah ditambahkan ke data latih Create ML.

## Pengumpulan

Sebelum 15:30, folder iCloud `Grup 5 - PantangMakan`: slide `.pptx`, `link-github.txt` (https://github.com/dendyramdhan/PantangMakan), dan screenshot atau video demo.
