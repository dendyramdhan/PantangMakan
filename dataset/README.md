# Dataset PemilahKalimat (Create ML)

Model `PantangMakan/Models/PemilahKalimat.mlmodel` memberi jenis tiap kalimat di label kemasan:

- `bahan`: daftar komposisi atau pernyataan "mengandung". Hanya ini yang dicocokkan dengan pantangan.
- `peringatan`: "dapat mengandung", "diproduksi menggunakan peralatan yang juga memproses …".
- `lain`: gizi, alamat, cara penyajian, "tanpa pengawet", "lihat daftar bahan yang dicetak tebal".

## Kenapa datanya teks hasil OCR

App tidak pernah melihat teks label yang rapi. App hanya menerima teks hasil bacaan Vision dari foto, lengkap dengan salah baca seperti "Cula" untuk "Gula". Karena itu data latih juga dibuat dari teks hasil Vision, supaya model belajar dari bentuk teks yang sama dengan yang nanti ia terima.

## Langkah

| # | Langkah | File | Hasil |
|---|---|---|---|
| 1 | Ambil foto label komposisi produk Indonesia dari [Open Food Facts](https://world.openfoodfacts.org) (CC BY-SA). 10 produk validasi tidak diambil. | `sumber-foto.json` | 220 foto |
| 2 | Baca teks dengan Vision, pengaturan sama dengan app | `ocr.swift` → `ocr.json` | teks per foto |
| 3 | Potong jadi kalimat (aturan sama dengan `Pemilah.swift`), beri label awal dengan kata kunci | `seg.py` → `kalimat-berlabel-awal.json` | 1.207 potongan |
| 4 | Baca dan koreksi manual kalimat yang meragukan, buang yang tercampur | `fix.py` → `kalimat-berlabel.json` | 1.197 kalimat |
| 5 | Buang potongan OCR yang rusak (kurang dari separuh katanya umum), lalu bagi per produk 70/15/15 | `bersihkan.py` | 940 kalimat dipakai, 257 dibuang (`kalimat-dibuang.csv`) |
| 6 | Latih dengan Create ML | `latih.swift` | `PemilahKalimat.mlmodel` |

Contoh potongan yang dibuang di langkah 5: teks promo "ATA KELUARIN OCAP MANIS, BORENG", nomor kode produksi, merek yang tergabung seperti "TEHBOTOLSOSRO", dan tabel gizi berbahasa Belanda atau Jerman.

## Train, validation, test

Dibagi **per produk**, jadi kalimat dari satu produk hanya ada di satu bagian. Produk yang punya kalimat peringatan dibagi terpisah supaya ketiga bagian berisi contoh peringatan.

| Bagian | Produk | Kalimat | bahan | peringatan | lain | Dipakai untuk |
|---|---|---|---|---|---|---|
| `kalimat-train.csv` | 145 | 657 | 304 | 46 | 307 | Belajar |
| `kalimat-validation.csv` | 31 | 139 | 65 | 9 | 65 | Diukur Create ML selama latihan |
| `kalimat-test.csv` | 30 | 144 | 60 | 8 | 76 | Angka akhir, tidak disentuh selama latihan |

## Latih

```
swift dataset/latih.swift
```

- Framework: **Create ML** (`MLTextClassifier`), dijalankan di Mac ini.
- Algoritma: **maxEnt** (maximum entropy). Transfer learning dengan embedding Apple tidak bisa dipakai karena belum mendukung bahasa Indonesia.

| Data | Benar | Akurasi |
|---|---|---|
| Train | 657 / 657 | 100% |
| Validation | 126 / 139 | 90,6% |
| **Test** | **122 / 144** | **84,7%** |

Di test, ke-8 kalimat peringatan benar semua. Salah terbanyak adalah `lain` yang tertebak `bahan` (18), kebanyakan baris gizi bahasa Inggris seperti "Fat 18.1g/5g".

## Membuka di aplikasi Create ML

1. Buka **Create ML** (Xcode → Open Developer Tool → Create ML) → New Document → **Text Classification**.
2. Training Data: `kalimat-train.csv`. Validation Data: `kalimat-validation.csv`. Testing Data: `kalimat-test.csv`. Text column `text`, label column `label`.
3. Algorithm: **Maximum Entropy**, lalu Train.
4. Simpan project di `dataset/PemilahKalimat.mlproj`.

Foto aslinya (153 MB) tidak disimpan di repo. Unduh ulang dari `sumber-foto.json`, lalu jalankan langkah 2–6.
