# ScanBite: alur app, model, dan dataset

*Scan First, Eat Safer.* Grup 5 · Jalur Tim · Challenge Day 3 Dicoding x Apple Developer Institute.

Repo: https://github.com/dendyramdhan/ScanBite

## Ringkasan

ScanBite membaca foto daftar komposisi di kemasan, lalu memberi tahu apakah pantangan pengguna ada di daftar bahan. AI yang dipakai ada tiga, semuanya jalan di iPhone tanpa server:

| AI | Buatan | Tugas | Kelompok di rubric |
|---|---|---|---|
| Vision | Apple | Membaca huruf dari foto | Side-app (baca teks dari foto) |
| Model kustom `PemilahKalimat` (Create ML) | Kami latih sendiri | Memilah tiap kalimat label: bahan, peringatan, atau lain | Diajarkan, sesi 1.3 |
| Foundation Models | Apple Intelligence | Menjelaskan arti bahan yang ditemukan | Diajarkan, sesi 2.6 |

Merah atau hijau diputuskan oleh **daftar kata** (aturan, bukan AI), supaya app tidak pernah mengarang bahan. AI dipakai untuk membaca, memilah, dan menjelaskan.

## 1. Alur app

```
Pilih pantangan → Foto label
  ① Vision            foto → teks
  ② Gerbang judul      ada "Komposisi/Ingredients"? tidak → Ditolak
  ③ Potong kalimat     teks → daftar kalimat
  ④ Create ML          tiap kalimat → bahan / peringatan / lain
  ⑤ Daftar kata        cari pantangan di kalimat bahan dan peringatan
  ⑥ Kartu hasil        merah / hijau / + kotak kuning
  ⑦ Foundation Models  penjelasan di bagian "Kenapa"
```

### Langkah 0 · Pilih pantangan
- Enam pilihan: susu, kacang, telur, gluten (Alergi), pemanis, garam (Pantangan).
- Disimpan di iPhone. Tombol **Ubah** untuk mengganti.
- **Tanpa pantangan:** tombol **Scan tanpa pantangan** muncul kalau belum ada yang dipilih. Keenam alergen dan pantangan dicek, dan kartunya netral (bukan merah atau hijau): "Komposisi ini memuat susu, telur, …" atau "Tidak ada alergen umum di komposisi ini."

### Langkah 1 · Foto
- Tombol **Pakai kamera**. Kalau izin kamera ditolak: pesan dan tombol **Buka Pengaturan**.

### ① Vision membaca teks (`ScanService.swift`)
- `VNRecognizeTextRequest`, `recognitionLevel = .accurate`, bahasa `id-ID` dan `en-US`, koreksi bahasa menyala.
- Hasilnya teks per baris, kadang dengan salah baca, misalnya "Cula" untuk "Gula".

### ② Gerbang judul (`Pantangan.swift` → `bagianKomposisi`)
- Mencari baris yang diawali `komposisi`, `ingredients`, `daftar bahan`, `bahan-bahan`, atau `composition`.
- Tidak ada judul → **"Ditolak. Gambar ini bukan daftar komposisi."** dengan tombol Foto ulang. Ini unhappy path.
- Ada judul → ambil teks sesudahnya sampai `informasi nilai gizi`, `nutrition facts`, `cara penyimpanan`, `diproduksi oleh`, `berat bersih`, dan sejenisnya.

### ③ Potong kalimat (`Pemilah.swift` → `potong`)
- Dipotong di titik (kecuali di angka seperti 3.7%), titik koma, bullet, " - ", dan **sebelum** frasa seperti "Dapat mengandung", "May contain", "Diproduksi menggunakan", "Allergen information".
- Aturan ini sama persis dengan yang dipakai saat membuat data latih.

### ④ Model kustom PemilahKalimat memilah kalimat (`PemilahKalimat.mlmodel`)
- Text classifier, dipanggil lewat Core ML dan NaturalLanguage (`NLModel`).
- Label:
  - `bahan`: "Tepung terigu, gula, susu bubuk, garam" · "Allergen information: Contains Milk, Soy"
  - `peringatan`: "Dapat mengandung telur dan kacang" · "Diproduksi menggunakan peralatan yang juga memproses kacang pohon"
  - `lain`: "Mengandung alergen, lihat daftar bahan yang dicetak tebal" · "Takaran saji 30 g" · alamat pabrik
- Create ML **tidak tahu** pantangan pengguna. Ia hanya menilai jenis kalimat.
- **Pengaman:** tebakan `peringatan` hanya diterima kalau kalimatnya memuat penanda seperti "dapat", "mungkin", "may", "diproduksi", atau "peralatan". Tanpa penanda, kalimat dianggap `bahan`. Ini supaya bahan pantangan tidak pernah tersembunyi sebagai peringatan.
- Kalau model gagal dimuat, semua kalimat dianggap `bahan`.
- **Confidence:** model memberi persentase untuk ketiga label, misalnya "Dapat mengandung kacang" → peringatan 93%, "Takaran saji 30 g" → lain 88%. Label teratas hanya dipakai kalau keyakinannya **≥ 60%**. Kalau ragu, kalimat dianggap `bahan`, supaya pantangan tetap dicek. Satu kata seperti "kacang" saja memang ragu (peringatan 50%, lain 28%, bahan 20%) karena kata itu muncul di kalimat bahan maupun peringatan. Di app, yang masuk ke model selalu kalimat utuh dari label, dan kalimat utuh biasanya yakin di atas 80%.
- Label `lain` tetap dipakai model (supaya baris gizi, alamat, dan promo tidak dianggap bahan), tapi di layar hanya jumlah bahan dan peringatan yang ditampilkan.

### ⑤ Daftar kata (`Pantangan.swift`)
- Nama tiap pantangan dalam bahasa Indonesia, Inggris, nama ilmiah, dan kode E. Contoh:
  - susu: susu, whey, keju, krim, mentega, kasein, laktosa, milk, cheese
  - kacang: kacang tanah, kacang mede, peanut, arachis hypogaea, almond, cashew, hazelnut
  - telur: telur, egg, albumin, ovalbumin, lysozyme, mayones
  - gluten: tepung terigu, gandum, wheat, barley, rye, malt, semolina
  - pemanis: gula, madu, sirup, sugar, sukrosa, fruktosa, glukosa, aspartam, sukralosa, stevia, sorbitol
  - garam: garam, salt, natrium klorida, MSG, mononatrium glutamat, penguat rasa
- Dicocokkan per kata utuh, jadi "glukosa" tidak dianggap "gluten".
- Pengecualian: cocoa butter dan lemak kakao bukan susu, susu kedelai bukan susu, natrium benzoat bukan garam.
- Dicocokkan di kalimat `bahan` (untuk kartu), lalu di kalimat `peringatan` (untuk kotak kuning).

### ⑥ Kartu hasil
| Kondisi | Tampilan |
|---|---|
| Pantangan ada di kalimat bahan | Merah: "Ada kacang dan pemanis di komposisi ini." |
| Tidak ada | Hijau: "Tidak ditemukan garam di komposisi ini." |
| Hanya di kalimat peringatan | Hijau + kotak kuning: "Label juga menulis dapat mengandung kacang." |
| Bukan daftar komposisi | Abu-abu: "Ditolak" |

Kata "aman" sengaja tidak dipakai. App melaporkan isi label, bukan menjamin keamanan.

### ⑦ Foundation Models menjelaskan
- `SystemLanguageModel.default` dan `LanguageModelSession`, model bawaan Apple Intelligence di iPhone.
- Hanya jalan kalau ada pantangan yang ditemukan. Masukannya fakta pasti, misalnya "kacang ada di daftar bahan, tertulis: kacang tanah, arachis hypogaea".
- Instruksi: satu kalimat per fakta, paling banyak tiga, jelaskan nama Latin, nama Inggris, atau bahan turunan. Dilarang memakai kata "aman", memberi saran medis, atau menyebut bahan lain.
- Jawaban dicek dulu: ditolak kalau memuat kata utuh "aman" atau "safe", menyebut pantangan lain, atau lebih dari 320 huruf. Tanda markdown dibersihkan.
- **Bahasa:** dicoba bahasa Indonesia dulu. iOS 26.5 belum mendukung bahasa Indonesia di Foundation Models (daftar bahasa modelnya tidak memuat "id"), jadi app mengulang dengan prompt bahasa Inggris. Di iOS 27, penjelasan keluar dalam bahasa Indonesia.
- Kalau tidak tersedia, kartu tetap jalan. Hanya bagian "Kenapa" yang hilang.

### Layar hasil, dari atas ke bawah
1. Foto label (kecil)
2. Kartu merah atau hijau, dengan kotak kuning kalau ada peringatan
3. **Kenapa**: penjelasan Foundation Models
4. **Di label**: kalimat Bahan dan Dapat mengandung, kata pantangan disorot merah
5. **Hasil AI**: "Kalimat label: 1 bahan · 1 peringatan · 0 lain" dan "Penjelasan: Apple Foundation Models, bahasa Indonesia/Inggris dan alasannya"
6. Tombol **Foto ulang** menempel di bawah

## 2. Dataset Create ML

### Kenapa datanya teks OCR
App tidak pernah melihat teks label yang rapi. App menerima teks hasil Vision, lengkap dengan salah baca. Karena itu data latih dibuat dari teks hasil Vision juga, supaya model belajar dari bentuk teks yang sama dengan yang akan ia terima.

### Sumber
- **Open Food Facts** (openfoodfacts.org), database produk makanan terbuka yang diisi relawan. Lisensi CC BY-SA.
- Diambil lewat API publik: produk dengan negara Indonesia yang punya foto komposisi.
- 220 foto. 10 produk validasi (Teh Pucuk, Ultra Milk, Oat M*lk, Indomie, Oreo, Energen, Superco, Choki Choki, Del Monte BBQ, Roma Kelapa) sengaja tidak diambil.

### Langkah (folder `dataset/` di repo)
| # | Langkah | File | Hasil |
|---|---|---|---|
| 1 | Unduh foto label | `sumber-foto.json` | 220 foto |
| 2 | Baca teks dengan Vision, pengaturan sama dengan app | `ocr.swift` → `ocr.json` | teks per foto |
| 3 | Potong kalimat, label awal dengan kata kunci | `seg.py` | 1.207 potongan |
| 4 | Baca dan koreksi manual kalimat yang meragukan | `fix.py` → `kalimat-berlabel.json` | 1.197 kalimat |
| 5 | Buang potongan OCR rusak, bagi per produk, tambahkan salinan kalimat bahan tanpa judul "Komposisi:" | `bersihkan.py` | 940 kalimat asli, 257 dibuang |
| 6 | Latih dengan Create ML | `latih.swift` | `PemilahKalimat.mlmodel` |

**Label awal (langkah 3):**
- `peringatan`: "dapat mengandung", "mungkin mengandung", "may contain", "can contain", "diproduksi menggunakan", "juga memproses", "shared equipment", "traces of" di awal kalimat
- `lain`: "takaran saji", "kkal", "simpan", "PT", "Jl", "BPOM", "halal", "berat bersih", "lihat daftar bahan yang dicetak tebal", "tanpa pengawet"
- `bahan`: diawali "Komposisi", "Ingredients", "Allergen information", atau berisi banyak koma

**Koreksi manual (langkah 4):** sekitar 440 kalimat yang memuat "mengandung", "contain", "proses", "produksi", "fasilitas", atau "peralatan" dibaca satu per satu. Contoh: "lungkin mengandung kacang tanah" (salah baca OCR) jadi `peringatan`, "MINYAK : Minyak nabati dan bumbu kari" jadi `bahan`.

**Pembersihan (langkah 5):** potongan dibuang kalau kurang dari separuh katanya umum (muncul di minimal 3 produk). Contoh yang dibuang: teks promo "ATA KELUARIN OCAP MANIS, BORENG", kode produksi, "TEHBOTOLSOSRO", tabel gizi berbahasa Belanda atau Jerman. Daftarnya di `kalimat-dibuang.csv`. Salah baca kecil seperti "Cula" tetap dipakai.

### Train, validation, test
Dibagi **per produk** (70/15/15). Kalimat dari satu produk hanya ada di satu bagian. Produk yang punya kalimat peringatan dibagi terpisah, supaya ketiga bagian berisi contoh peringatan.

| Bagian | Produk | Kalimat | bahan | peringatan | lain | Dipakai untuk |
|---|---|---|---|---|---|---|
| `kalimat-train.csv` | 145 | 805 | 452 | 46 | 307 | Belajar |
| `kalimat-validation.csv` | 31 | 169 | 95 | 9 | 65 | Diukur Create ML selama latihan |
| `kalimat-test.csv` | 30 | 170 | 86 | 8 | 76 | Angka akhir, tidak disentuh selama latihan |

## 3. Melatih model

- Framework **Create ML** (`MLTextClassifier`), dijalankan di Mac ini lewat `swift dataset/latih.swift`.
- Algoritma **maxEnt** (maximum entropy). Transfer learning dengan embedding Apple dicoba, tapi tidak bisa dipakai karena embedding Apple belum mendukung bahasa Indonesia.
- Validation diberikan langsung ke Create ML (`validation: .dataFrame(...)`). Test baru dipakai setelah model jadi.

| Data | Benar | Akurasi |
|---|---|---|
| Train | 805 / 805 | 100% |
| Validation | 155 / 169 | 91,7% |
| **Test** | **146 / 170** | **85,9%** |

Salah terbanyak di test adalah `lain` yang tertebak `bahan` (18), kebanyakan baris gizi bahasa Inggris seperti "Fat 18.1g/5g". Biasanya tidak mengubah hasil, karena baris itu tidak memuat nama pantangan.

**Membuka di aplikasi Create ML:** Xcode → Open Developer Tool → Create ML → New Document → Text Classification. Training `kalimat-train.csv`, Validation `kalimat-validation.csv`, Testing `kalimat-test.csv`, kolom `text` dan `label`, algoritma Maximum Entropy, lalu Train. Simpan sebagai `dataset/PemilahKalimat.mlproj`.

## 4. Validasi produk

10 label produk Indonesia yang tidak ikut data latih, keenam pantangan dipilih (`validasi/`).

| | Benar |
|---|---|
| Tanpa Create ML (semua kalimat dianggap bahan) | 8 dari 10 |
| Dengan Create ML | **10 dari 10** |

Dua yang diperbaiki Create ML:
- **Superco:** "Dapat mengandung telur, kedelai dan kacang" sebelumnya dihitung sebagai bahan.
- **Oat M*lk:** "Diproduksi menggunakan peralatan yang juga memproses kacang pohon" sebelumnya dihitung sebagai bahan.

## 5. Batasan

1. Label data latih dibuat dengan aturan lalu dikoreksi manual untuk kalimat yang meragukan. Tidak semua kalimat dibaca satu per satu.
2. Validasi produk hanya 10 label, dan fotonya dari Open Food Facts, bukan dari kamera app.
3. Nama bahan yang tidak ada di daftar kata tidak akan tertangkap.
4. Penjelasan Foundation Models bergantung pada versi iOS dan Apple Intelligence.

## 6. Jawaban singkat untuk juri

- **Pakai model apa?** Tiga, semua di perangkat. Vision untuk membaca teks foto, model kustom buatan kami bernama PemilahKalimat (dilatih dengan Create ML) untuk memilah kalimat bahan dan "dapat mengandung", dan Foundation Models untuk menjelaskan.
- **Data latihnya?** 220 foto label produk Indonesia dari Open Food Facts, dibaca dengan Vision, jadi 940 kalimat yang dipakai setelah dibersihkan. Dibagi train, validation, dan test per produk. Akurasi test 85,9%.
- **Kenapa keputusannya bukan AI?** Supaya tidak ada bahan yang dikarang. AI membaca, memilah, dan menjelaskan. Pantangan dicocokkan dengan daftar yang pasti.
- **Kalau Apple Intelligence mati?** Kartu tetap jalan, hanya penjelasan yang tidak muncul.
