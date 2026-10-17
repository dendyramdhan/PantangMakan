# Validasi PantangMakan

10 foto label komposisi produk Indonesia dari [Open Food Facts](https://world.openfoodfacts.org) (CC BY-SA). Alurnya sama dengan app: Vision membaca teks (`id-ID`, `en-US`, accurate), gerbang judul Komposisi/Ingredients, lalu daftar kata. Keenam pantangan dipilih sekaligus. Foundation Models tidak ikut karena hanya menyusun kalimat dari hasil yang sama.

Jalankan ulang:

```
swiftc -O -o /tmp/pm-eval validasi/main.swift PantangMakan/Models/Pantangan.swift
/tmp/pm-eval validasi/foto/*.jpg
```

Jawaban benar dibaca dari foto: bahan di daftar komposisi dan pernyataan "mengandung". Kalimat "dapat mengandung" tidak dihitung sebagai bahan.

| # | Produk | Seharusnya | Hasil app | |
|---|---|---|---|---|
| 1 | Teh Pucuk Harum Jasmine | pemanis | pemanis | Benar |
| 2 | Ultra Milk Full Cream | susu | susu | Benar |
| 3 | Creamy Classic Oat M*lk | pemanis, garam | kacang, pemanis, garam | Salah |
| 4 | Indomie Mi Goreng | susu, telur, gluten, pemanis, garam | sama | Benar |
| 5 | Oreo Original | gluten, pemanis, garam | sama | Benar |
| 6 | Energen Coklat | susu, telur, gluten, pemanis, garam | sama | Benar |
| 7 | Superco | susu, gluten, pemanis, garam | susu, kacang, telur, gluten, pemanis, garam | Salah |
| 8 | Choki Choki Chococashew | susu, kacang, pemanis, garam | sama | Benar |
| 9 | Del Monte BBQ | pemanis, garam | sama | Benar |
| 10 | Biskuit Roma Kelapa | susu, gluten, pemanis, garam | sama | Benar |

Benar 8 dari 10.

Dua yang salah punya sebab yang sama. Kalimat peringatan di bawah komposisi ikut terbaca sebagai bahan:

- Superco: "Dapat mengandung telur, kedelai dan kacang" membuat app menyebut telur dan kacang.
- Oat M*lk: "Diproduksi menggunakan peralatan yang juga memproses kacang pohon" membuat app menyebut kacang.

Yang terbaca benar walau hurufnya rusak: Energen "Cula" (gula) tetap tertangkap lewat "Sugar" di teks Inggris. Natrium benzoat di Del Monte tidak dihitung sebagai garam.
