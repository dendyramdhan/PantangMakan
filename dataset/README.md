# Dataset PemilahKalimat (Create ML)

Model `PantangMakan/Models/PemilahKalimat.mlmodel` memberi jenis tiap kalimat di label kemasan:

- `bahan`: daftar komposisi atau pernyataan "mengandung". Hanya ini yang dicocokkan dengan pantangan.
- `peringatan`: "dapat mengandung", "diproduksi menggunakan peralatan yang juga memproses …".
- `lain`: gizi, alamat, cara penyajian, "tanpa pengawet", "lihat daftar bahan yang dicetak tebal".

## Asal data

1. 220 foto label komposisi produk Indonesia dari [Open Food Facts](https://world.openfoodfacts.org) (CC BY-SA). Daftar dan tautan: `sumber-foto.json`. 10 produk di `validasi/` sengaja tidak ikut.
2. Teks dibaca dengan Vision (`ocr.swift`, sama dengan app): `ocr.json`.
3. Teks dipotong jadi kalimat dan diberi label awal dengan kata kunci (`seg.py`). Aturan potongnya sama dengan `PantangMakan/Services/Pemilah.swift`.
4. Semua kalimat yang menyebut "mengandung/contain/proses/produksi" dan kalimat `lain` yang memuat nama bahan dibaca satu per satu, lalu dikoreksi (`fix.py`). Contoh: OCR "lungkin mengandung kacang" jadi `peringatan`, "Minyak: minyak nabati dan bumbu kari" jadi `bahan`. 10 kalimat campur dibuang.
5. Hasil: 1.197 kalimat (665 lain, 469 bahan, 63 peringatan) di `kalimat-berlabel.json`, dibagi per produk 80/20 ke `kalimat-train.csv` dan `kalimat-test.csv`.

## Latih

```
swift dataset/latih.swift
```

Algoritma maxEnt (embedding Apple belum mendukung bahasa Indonesia). Akurasi di data uji, produk yang tidak pernah dilihat model: 208 dari 230 kalimat (90,4%). Semua kalimat `peringatan` di data uji benar. Salah terbanyak: `lain` terbaca `bahan` (16), yang tidak mengubah hasil karena kalimat itu tidak memuat nama pantangan.

Foto aslinya (153 MB) tidak disimpan di repo. Unduh ulang dari `sumber-foto.json`, lalu jalankan `ocr.swift`, `seg.py`, dan `fix.py`.
