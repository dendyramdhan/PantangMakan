"""Langkah 5: buang potongan OCR yang rusak, lalu bagi per produk jadi train/validation/test.

Potongan dianggap rusak kalau kurang dari setengah katanya (>= 3 huruf) muncul di
>= 3 produk berbeda. Contoh yang dibuang: "an0 10 8", "TEHBOTOLSOSRO", "Ülig≤aJI",
baris gizi berbahasa Belanda/Jerman. Teks OCR yang masih terbaca (salah ketik kecil
seperti "Cula" untuk "Gula") tetap dipakai, karena app juga menerima teks seperti itu.
"""
import collections, csv, json, random, re

rows = json.load(open("dataset/kalimat-berlabel.json"))
tok = lambda s: [t for t in re.findall(r"[a-zA-ZÀ-ÿ]+", s.lower()) if len(t) >= 3]

produk_per_kata = collections.defaultdict(set)
for kode, s, _ in rows:
    for t in set(tok(s)):
        produk_per_kata[t].add(kode)
umum = {t for t, ps in produk_per_kata.items() if len(ps) >= 3}

def mutu(s):
    ts = tok(s)
    return sum(t in umum for t in ts) / len(ts) if ts else 0.0

bersih = [(k, s, l) for k, s, l in rows if mutu(s) >= 0.5]
buang = [(k, s, l) for k, s, l in rows if mutu(s) < 0.5]
json.dump(bersih, open("dataset/kalimat-bersih.json", "w"), ensure_ascii=False)
with open("dataset/kalimat-dibuang.csv", "w", newline="") as f:
    w = csv.writer(f); w.writerow(["text", "label", "produk"])
    for k, s, l in buang: w.writerow([s, l, k.replace(".jpg", "")])

# Dibagi per produk 70/15/15: satu produk hanya ada di satu bagian.
# Produk yang punya kalimat peringatan dibagi terpisah, supaya validation dan test
# juga berisi contoh peringatan (kelas paling sedikit).
kode = sorted({k for k, _, _ in bersih})
ada_peringatan = {k for k, _, l in bersih if l == "peringatan"}
bagian = {}
random.seed(42)
for kelompok in [sorted(ada_peringatan), sorted(set(kode) - ada_peringatan)]:
    random.shuffle(kelompok)
    n = len(kelompok)
    for i, k in enumerate(kelompok):
        bagian[k] = "train" if i < n * 0.70 else ("validation" if i < n * 0.85 else "test")

for nama in ["train", "validation", "test"]:
    with open(f"dataset/kalimat-{nama}.csv", "w", newline="") as f:
        w = csv.writer(f); w.writerow(["text", "label", "produk"])
        isi = [(k, s, l) for k, s, l in bersih if bagian[k] == nama]
        for k, s, l in isi: w.writerow([s, l, k.replace(".jpg", "")])
        hit = collections.Counter(l for _, _, l in isi)
        print(f"{nama:10s} {sum(1 for x in kode if bagian[x]==nama):3d} produk  {len(isi):4d} kalimat  {dict(hit)}")
print("dibuang", len(buang), "dari", len(rows), collections.Counter(l for _, _, l in buang))
