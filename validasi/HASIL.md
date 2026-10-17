# Validasi ScanBite

10 foto label komposisi produk Indonesia dari [Open Food Facts](https://world.openfoodfacts.org) (CC BY-SA), di `validasi/foto/`. Ke-10 produk ini tidak dipakai untuk melatih model Create ML.

Alurnya sama dengan app: Vision membaca teks, gerbang judul Komposisi/Ingredients, Create ML `PemilahKalimat` memilah kalimat, lalu daftar kata mencocokkan pantangan di kalimat bahan. Keenam pantangan dipilih sekaligus. Foundation Models tidak ikut karena hanya menulis penjelasan.

```
swiftc -O -o /tmp/pm-eval validasi/main.swift PantangMakan/Models/Pantangan.swift PantangMakan/Services/Pemilah.swift
/tmp/pm-eval validasi/foto/*.jpg               # dengan Create ML
/tmp/pm-eval validasi/foto/*.jpg --tanpa-model # semua kalimat dianggap bahan (versi lama)
/tmp/pm-eval validasi/foto/*.jpg --rinci       # tampilkan jenis tiap kalimat
```

Jawaban benar dibaca dari foto. Bahan = daftar komposisi dan pernyataan "mengandung". "Dapat mengandung" harus jadi peringatan, bukan bahan.

| # | Produk | Bahan seharusnya | Peringatan seharusnya | Tanpa Create ML | Dengan Create ML |
|---|---|---|---|---|---|
| 1 | Teh Pucuk Harum Jasmine | pemanis | – | Benar | Benar |
| 2 | Ultra Milk Full Cream | susu | – | Benar | Benar |
| 3 | Creamy Classic Oat M*lk | pemanis, garam | kacang | Salah: kacang jadi bahan | Benar |
| 4 | Indomie Mi Goreng | susu, telur, gluten, pemanis, garam | – | Benar | Benar |
| 5 | Oreo Original | gluten, pemanis, garam | – | Benar | Benar |
| 6 | Energen Coklat | susu, telur, gluten, pemanis, garam | – | Benar | Benar |
| 7 | Superco | susu, gluten, pemanis, garam | telur, kacang | Salah: telur dan kacang jadi bahan | Benar |
| 8 | Choki Choki Chococashew | susu, kacang, pemanis, garam | – | Benar | Benar |
| 9 | Del Monte BBQ | pemanis, garam | – | Benar | Benar |
| 10 | Biskuit Roma Kelapa | susu, gluten, pemanis, garam | – | Benar | Benar |

Tanpa Create ML: 8 dari 10. Dengan Create ML: 10 dari 10.

Kedua kegagalan versi lama punya sebab yang sama: kalimat "Dapat mengandung telur, kedelai dan kacang" (Superco) dan "Diproduksi menggunakan peralatan yang juga memproses kacang pohon" (Oat M*lk) ikut dihitung sebagai bahan. Create ML memisahkannya jadi peringatan.

Batas evaluasi ini: hanya 10 foto, dan foto Open Food Facts diambil pengguna lain, bukan kamera app. Akurasi model per kalimat ada di `dataset/README.md` (85,9% di 170 kalimat test).
