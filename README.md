# PantangMakan

App iOS untuk Challenge Day 3, Dicoding x Apple Developer Institute (Professional AI Solutions), Jalur Tim, Grup 5.

Pengguna memilih pantangan makannya (susu, kacang, telur, gluten, pemanis, garam), memfoto daftar komposisi di kemasan, lalu membaca satu kalimat, misalnya "Ada kacang dan pemanis di komposisi ini." atau "Tidak ditemukan garam di komposisi ini." App melaporkan isi komposisi, bukan diagnosis.

## Fitur AI dalam satu alur

1. **Vision** membaca teks dari foto, hanya bagian di bawah judul Komposisi, Ingredients, atau Daftar bahan. Foto yang bukan daftar komposisi ditolak.
2. **Create ML** (`PantanganText.mlmodel`, text classifier lewat Core ML) menebak jenis pantangan dari teks komposisi. Labelnya tampil di bagian "HASIL AI".
3. **Foundation Models** (System Language Model, Apple Intelligence) menyusun kalimat hasil.
4. **API Dicoding** (`openai/gpt-oss-20b`) menyusun kalimat kalau Foundation Models tidak tersedia. Kalau koneksi gagal, kalimat keluar dari daftar kata dan muncul tombol Coba lagi.

Kalimat dari model dicek sebelum tampil. Kalau tidak sesuai fakta, app memakai kalimat dari daftar kata.

## Menjalankan

- Xcode 26.6, iOS 26.0 ke atas.
- Buka `PantangMakan.xcodeproj`, pilih personal Team di Signing, lalu ⌘R.
- Foundation Models butuh iPhone dengan Apple Intelligence menyala, atau Simulator iOS 27.

## Isi repo

- `PantangMakan/` kode app dan model Create ML.
- `presentasi/` slide (`PantangMakan.pptx`, `PantangMakan.pdf`), screenshot demo, dan script pembuat slide.
- `figma-frames/`, `figma-plugin/`, `ui/` bahan desain dan naskah tim.

## Tim

Muhammad Fajar Wira Azdi, Ahmad Syafiq Kamil, Dendy Ramdhan Fauzy, Mohamad Arrizal, Zuber Khatib.
