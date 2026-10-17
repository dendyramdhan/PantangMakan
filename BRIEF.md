# ScanBite

Scan First, Eat Safer.

Grup 5. Satu pengguna: yang sudah tahu pantangannya, huruf komposisi di bungkus terlalu kecil.

## Selesai kalau

1. Pengguna memilih pantangan, memfoto daftar komposisi, dan melihat satu kalimat.
2. Foto kedua mengganti kalimat itu tanpa menutup aplikasi.
3. "Dapat mengandung" tampil sebagai peringatan, bukan bahan.
4. Izin kamera yang ditolak menampilkan pesan dan tombol Pengaturan.
5. Kalimat tidak pernah memakai kata "aman" dan tidak menambah bahan di luar yang terbaca.

## Yang tampil, berurutan

1. Vision membaca teks dari foto. Fitur side-app.
2. Model kustom PemilahKalimat (`PemilahKalimat.mlmodel`, dilatih dengan Create ML) memilah kalimat: bahan, peringatan, lain. Fitur yang diajarkan, sesi 1.3.
3. Foundation Models menjelaskan kenapa. Fitur yang diajarkan, sesi 2.6. Hanya jalan di iPhone dengan Apple Intelligence, atau Simulator iOS 27.

Tidak ada server. Semua jalan di perangkat.

## Urutan demo, 7 menit

1. Cerita satu pengguna dulu, sebelum membuka fitur.
2. Pilih kacang dan pemanis. Foto komposisi yang memuat kacang dan gula.
3. Tanpa menutup aplikasi, tekan Ubah, pilih garam, foto komposisi teh. Kalimat berganti.
4. Foto label dengan "dapat mengandung kacang": kotak kuning.
5. Foto depan kemasan: Ditolak. Cadangan: tolak izin kamera, tunjukkan pesan dan tombol Buka Pengaturan.

## Tidak dibuat

Diagnosis, kata "aman", resep, cek obat, cek uang.
