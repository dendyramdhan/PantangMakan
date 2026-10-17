# ScanBite

*Scan First, Eat Safer*

App iOS untuk Challenge Day 3, Dicoding x Apple Developer Institute (Professional AI Solutions), Jalur Tim, Grup 5.

Pengguna memilih pantangan makannya (susu, kacang, telur, gluten, pemanis, garam), memfoto daftar komposisi di kemasan, lalu membaca satu kalimat: "Ada kacang dan pemanis di komposisi ini." atau "Tidak ditemukan garam di komposisi ini." Kalimat "dapat mengandung" di label tampil sebagai peringatan terpisah. App melaporkan isi label, bukan diagnosis. Semua AI jalan di perangkat, tanpa server.

## Fitur AI dalam satu alur

1. **Vision** membaca teks dari foto, hanya bagian di bawah judul Komposisi atau Ingredients. Foto yang bukan daftar komposisi ditolak.
2. **Create ML** (`PemilahKalimat.mlmodel`, text classifier lewat Core ML) memilah tiap kalimat: `bahan`, `peringatan`, atau `lain`. Daftar kata hanya mencocokkan pantangan di kalimat `bahan`. Dilatih dari 1.197 kalimat 220 label produk Indonesia (Open Food Facts), akurasi uji 90,4%. Lihat [`dataset/`](dataset/README.md).
3. **Foundation Models** (System Language Model, Apple Intelligence) menjelaskan kenapa, misalnya "Arachis hypogaea adalah nama ilmiah kacang tanah." Penjelasan dicek dulu: tidak boleh memakai kata "aman" atau menyebut pantangan lain. Kalau Apple Intelligence mati, penjelasan tidak tampil dan kartu tetap jalan.

## Validasi

10 label produk Indonesia yang tidak ikut data latih: 8 benar tanpa Create ML, 10 benar dengan Create ML. Lihat [`validasi/HASIL.md`](validasi/HASIL.md).

## Menjalankan

- Xcode 26.6 atau lebih baru, iOS 26.0 ke atas.
- Buka `PantangMakan.xcodeproj`, pilih personal Team di Signing, lalu ⌘R.
- Foundation Models butuh iPhone dengan Apple Intelligence menyala, atau Simulator iOS 27.
- Pratinjau tanpa kamera: jalankan dengan argumen `--pratinjau`, `--aman`, `--peringatan`, atau `--ditolak`.

## Isi repo

- `PantangMakan/` kode app dan model Create ML.
- `dataset/` data latih, script OCR/label, dan `latih.swift`.
- `validasi/` 10 foto uji, script evaluasi, dan hasilnya.
- `presentasi/` slide (`ScanBite.pptx`, `ScanBite.pdf`), screenshot demo, dan script pembuat slide.
- `figma-frames/`, `figma-plugin/`, `ui/` bahan desain dan naskah tim.

## Tim

Muhammad Fajar Wira Azdi, Ahmad Syafiq Kamil, Dendy Ramdhan Fauzy, Mohamad Arrizal, Zuber Khatib.
