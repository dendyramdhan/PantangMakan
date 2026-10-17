import json
rows=json.load(open("dataset/kalimat-berlabel-awal.json"))
# Koreksi manual setelah membaca tiap baris kandidat (teks OCR rusak / segmen campur).
FIX={
 "kungkin mengandung kacang tanah":"peringatan","lungkin mengandung kacang tanah":"peringatan","Murgkin mengandung":"peringatan",
 "Muy contain races":"peringatan","ga memproses produk yang mengandung Telur":"peringatan",
 "Produce on share equipment":"peringatan","Mungkin mennandung kedelai":"peringatan","tatan yang juga mi sproses":"peringatan",
 "May contains ollergen":"lain","May contains allargen":"lain","OKEY Chicken Nugget is made":"lain","Chicken Stick Nugget are made":"lain",
 "Pewarna Alami Karamel IV Amonia Sulfit Proses, Anti Kempal":"bahan","pengatur-keasaman lasam sitray":"bahan",
 "Diproduksi oleh: Otsuka PT Amerta Indah Otsuka, Pasuruan":"lain","Mangandung pewanis buatan":"bahan",
 "aRc Snock Balk Digunakan":"lain","Takaran saji/ Serving*e 7":"lain","Kegunaan: Mere inara":"lain",
 "con Disodium Orpposptoto":"bahan",
}
DROP=["Mav Contain Cther Nuts","Manistactured on shared","CONTAINS MILK AND SO1) MAY COUTAIN","Soy and Wheat, ạẠạKandestve","Hacphan! Mengandung Gula","Containing allergens, see bold material Manufactured"]
out=[];n=0
for k,s,l in rows:
    if any(d in s for d in DROP) or l=="campur": n+=1; continue
    for key,v in FIX.items():
        if key in s: l=v
    out.append((k,s,l))
json.dump(out,open("dataset/kalimat-berlabel.json","w"),ensure_ascii=False)
import collections; print("dropped",n,len(out),collections.Counter(r[2] for r in out))
# Baris bumbu/minyak yang terpisah dari daftar komposisi (dicek manual).
for i in [23,38,41,66,208,377,491,808,908,1190]:
    k,s,_=out[i]; out[i]=(k,s,"bahan")
json.dump(out,open("dataset/kalimat-berlabel.json","w"),ensure_ascii=False)
print(collections.Counter(r[2] for r in out))
