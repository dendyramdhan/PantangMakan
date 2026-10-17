# PantangMakan

Grup 5. Satu pengguna: orang yang sudah tahu alerginya, huruf komposisi di bungkus terlalu kecil.

## Selesai kalau

1. Pengguna memilih pantangan, memfoto daftar komposisi, dan melihat satu kalimat.
2. Foto kedua mengganti kalimat itu tanpa menutup aplikasi.
3. Izin kamera yang ditolak menampilkan pesan dan tombol Pengaturan.
4. Kalimat tidak pernah memakai kata "aman" dan tidak menambah bahan di luar yang terbaca.

## Yang tampil, berurutan

1. Create ML (`PantanganText.mlmodel`) membaca teks hasil OCR. Ini fitur yang diajarkan, sesi 1.3.
2. Foundation Models menyusun satu kalimat dari fakta kata yang cocok. Ini fitur yang diajarkan, sesi 2.6. Hanya jalan di iPhone dengan Apple Intelligence, atau Simulator iOS 27.
3. API Dicoding (`openai/gpt-oss-20b`) menyusun kalimat yang sama. Ini fitur side-app. Kalau koneksi gagal, kalimat tetap keluar dari kata yang cocok, plus pesan dan tombol Coba lagi.

## Urutan demo, 7 menit

1. Cerita satu orang dulu, sebelum membuka fitur.
2. Pilih kacang dan pemanis. Foto komposisi yang memuat kacang dan gula.
3. Tanpa menutup aplikasi, tekan Ubah, pilih garam, foto komposisi teh. Kalimat berganti.
4. Foto depan kemasan: Ditolak. Cadangan: tolak izin kamera, tunjukkan pesan dan tombol Buka Pengaturan.

## Tidak dibuat

Diagnosis, kata "aman", resep, cek obat, cek uang.
