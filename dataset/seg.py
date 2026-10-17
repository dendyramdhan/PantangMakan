import json,re,random,collections
SPLIT=re.compile(r'\||(?<!\d)\.(?!\d)|;|•|·|\s[-–]\s|(?:^|\s)\*(?=\S)')
MARK=re.compile(r'(?=\b(?:dapat mengandung|mungkin mengandung|bisa mengandung|may (?:also )?contain|diproduksi (?:menggunakan|di|pada|dengan)|diproses (?:di|dengan|pada)|informasi nilai gizi|nutrition facts|informasi alergen|allergen information|mengandung alergen|ingredients?\b|komposisi|takaran saji|saran penyajian|cara penyajian|diproduksi oleh|layanan konsumen)\b)',re.I)
def segments(lines):
    t=" ".join(l.strip() for l in lines)
    t=re.sub(r'\s+',' ',t)
    t=MARK.sub('|',t)
    return [s.strip(" ,:-*") for s in SPLIT.split(t) if len(s.strip(" ,:-*"))>=4]
PER=re.compile(r'can contain|manufactured\s+(?:using|on)|juga memproses|shared equipment|dapat mengandung|mungkin mengandung|bisa mengandung|may contain|may also contain|might contain|diproduksi\s+(?:menggunakan|dengan|di\s+(?:fasilitas|pabrik|jalur|tempat|lini)|pada)|diproses\s+(?:di|dengan|menggunakan|pada)|dibuat\s+(?:di|pada|menggunakan)\s+(?:fasilitas|pabrik|peralatan|jalur|lini)|produced\s+(?:in|on|using)|manufactured\s+(?:in|on)|processed\s+(?:in|on)|made\s+(?:in|on)\s+(?:a\s+)?(?:factory|facility|equipment|line)|(?:fasilitas|peralatan|jalur produksi|lini produksi)\s+yang\s+(?:juga|sama)|traces?\s+of|same\s+(?:facility|equipment|line)',re.I)
LAIN=re.compile(r'takaran saji|serving|energi total|total energy|kkal|kcal|\bakg\b|daily value|lemak total|total fat|nilai gizi|nutrition|simpan|penyimpanan|store|storage|seduh|cara penyajian|petunjuk|how to|diproduksi oleh|dikemas oleh|didistribusikan|produced by|manufactured by|distributed|imported|diimpor|\bpt\b|\bjl\b|jalan |jakarta|tangerang|bekasi|indonesia\b|layanan konsumen|consumer|bpom|\bmd\s?\d|\bml\s?\d|halal|kedaluwarsa|expired|exp\b|best before|baik digunakan|berat bersih|netto|net wt|isi bersih|www\.|\.com|\.co\.id|@|lihat daftar|dicetak tebal|in bold|see ingredients|tanpa pengawet|no preservative|cocok untuk|untuk anak|kocok|setelah dibuka|after opening|recycle|buang|kode produksi|batch',re.I)
BAHANKEY=re.compile(r'komposisi|ingredients?|bahan|contains?\b|mengandung|allergen',re.I)
HEAD=re.compile(r'^\W*(?:komposisi|ingredients?|bahan|allergen information|informasi alergen)\b',re.I)
def label(s):
    m=PER.search(s)
    if m and m.start()<=40: return "peringatan"
    if m: return "campur"
    if HEAD.search(s) and not re.search(r'lihat daftar|dicetak tebal|in bold|see ingredients|see bold|refer to',s,re.I): return "bahan"
    if LAIN.search(s) and s.count(",")<3: return "lain"
    if s.count(",")>=2 or BAHANKEY.search(s): return "bahan"
    return "lain"
if __name__=="__main__":
    o=json.load(open("dataset/ocr.json")); rows=[]
    for k,lines in o.items():
        for s in segments(lines): rows.append((k,s,label(s)))
    print(len(rows),collections.Counter(r[2] for r in rows))
    json.dump(rows,open("dataset/kalimat-berlabel-awal.json","w"),ensure_ascii=False)
    random.seed(1)
    for lab in ["peringatan","bahan","lain"]:
        print("=====",lab)
        for r in random.sample([r for r in rows if r[2]==lab],min(25,sum(1 for r in rows if r[2]==lab))): print(" -",r[1][:150])
