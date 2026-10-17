// Membuat PantangMakan.pptx. Jalankan: npm install && node buat-slide.js
const pptxgen = require("pptxgenjs");
const pres = new pptxgen();

pres.defineLayout({ name: "WIDE", width: 13.333, height: 7.5 });
pres.layout = "WIDE";
pres.author = "Grup 5";
pres.title = "PantangMakan";
pres.subject = "Challenge Day 3 · Jalur Tim";

const C = {
  bg: "F7F4EE", ink: "1C1917", muted: "6B6560", brick: "B85A3C",
  green: "1E7345", greenBg: "E3F5E8", red: "BA2929", redBg: "FCE6E6",
  amberBg: "FDF0CC", line: "E4DDD4", card: "FFFCF8", white: "FFFFFF", dark: "2B2B28",
};
const FONT = "Calibri";
const SERIF = "Georgia";
const DEMO = __dirname + "/demo/";
const FOTO = __dirname + "/../validasi/foto/";
const PHONE = 1260 / 2736;
const FOOT = "Grup 5  ·  PantangMakan  ·  Jalur Tim";

const bg = (s) => { s.background = { color: C.bg }; };
const footer = (s) => s.addText(FOOT, { x: 0.55, y: 7.05, w: 8, h: 0.25, fontFace: FONT, fontSize: 11, color: C.muted, margin: 0 });
const title = (s, t) => s.addText(t, { x: 0.55, y: 0.35, w: 12.2, h: 0.6, fontFace: SERIF, fontSize: 32, color: C.ink, margin: 0 });
const eyebrow = (s, t, x, y, w, color = C.brick) => s.addText(t, { x, y, w, h: 0.3, fontFace: FONT, fontSize: 12, bold: true, charSpacing: 1, color, margin: 0 });
const card = (s, x, y, w, h, fill = C.card) => s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x, y, w, h, fill: { color: fill }, line: { color: C.line, width: 0.75 }, rectRadius: 0.12 });
const phone = (s, file, x, y, h, alt) => {
  const w = h * PHONE;
  s.addImage({ path: file, x, y, w, h, altText: alt });
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x, y, w, h, fill: { type: "none" }, line: { color: C.line, width: 1 }, rectRadius: 0.18 });
  return w;
};

// Slide pemisah: nomor, judul, satu kalimat pengantar, dan potongan layar app di kanan.
function divider(num, judul, lead, visual, note) {
  const s = pres.addSlide();
  bg(s);
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.18, h: 7.5, fill: { color: C.brick } });
  s.addText(num, { x: 0.85, y: 2.0, w: 3, h: 0.9, fontFace: SERIF, fontSize: 54, color: C.brick, margin: 0 });
  s.addText(judul, { x: 0.85, y: 3.0, w: 6.6, h: 1.2, fontFace: SERIF, fontSize: 38, color: C.ink, margin: 0, valign: "top" });
  s.addText(lead, { x: 0.85, y: 4.35, w: 6.2, h: 1.0, fontFace: FONT, fontSize: 18, color: C.muted, margin: 0, valign: "top" });
  if (visual) visual(s);
  s.addNotes(note);
}
const cropRight = (file, ratio, alt) => (s) => {
  const w = 5.0, h = w * ratio;
  s.addImage({ path: DEMO + file, x: 7.75, y: (7.5 - h) / 2, w, h, altText: alt });
};

// --- Sampul ---
{
  const s = pres.addSlide();
  bg(s);
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.18, h: 7.5, fill: { color: C.brick } });
  s.addText("Jalur Tim  ·  Grup 5", { x: 0.85, y: 1.7, w: 7, h: 0.35, fontFace: FONT, fontSize: 16, color: C.brick, margin: 0 });
  s.addText("PantangMakan.", { x: 0.85, y: 2.15, w: 7, h: 1.05, fontFace: SERIF, fontSize: 60, color: C.ink, margin: 0 });
  s.addText("Foto komposisinya, langsung tahu ada pantanganmu atau tidak.", { x: 0.85, y: 3.35, w: 6.5, h: 0.8, fontFace: FONT, fontSize: 20, color: C.muted, margin: 0, valign: "top" });
  s.addText("Muhammad Fajar Wira Azdi\nAhmad Syafiq Kamil\nDendy Ramdhan Fauzy\nMohamad Arrizal\nZuber Khatib", { x: 0.85, y: 4.55, w: 6, h: 1.9, fontFace: FONT, fontSize: 15, color: C.ink, margin: 0, valign: "top", paraSpaceAfter: 3 });
  phone(s, DEMO + "pantang-bahaya.png", 9.1, 0.55, 6.4, "Layar hasil PantangMakan: Ada kacang dan pemanis di komposisi ini");
  s.addNotes("Sebut nama app, jalur tim, dan lima nama Grup 5. Langsung ke cerita pengguna.");
}

// --- 1 Tim Kami ---
divider("01", "Tim Kami", "Lima anggota, satu app.", null, "Bagian ini tidak dinilai. Sebut nama saja.");
{
  const s = pres.addSlide();
  bg(s);
  title(s, "Tim Kami");
  const head = { fill: { color: C.dark }, color: C.white, bold: true, fontFace: FONT, fontSize: 13, valign: "middle" };
  const cell = { fill: { color: C.card }, color: C.ink, fontFace: FONT, fontSize: 15, valign: "middle" };
  const names = ["Muhammad Fajar Wira Azdi", "Ahmad Syafiq Kamil", "Dendy Ramdhan Fauzy", "Mohamad Arrizal", "Zuber Khatib"];
  const rows = [
    [{ text: "Nama", options: head }, { text: "Pekerjaan saat ini", options: head }, { text: "Peran di tim", options: head }],
    ...names.map((n) => [{ text: n, options: cell }, { text: "", options: cell }, { text: "", options: cell }]),
  ];
  // Kolom kanan untuk foto tim.
  s.addTable(rows, { x: 0.55, y: 1.25, w: 8.4, h: 4.6, colW: [3.6, 2.4, 2.4], border: { type: "solid", pt: 0.5, color: C.line } });
  card(s, 9.3, 1.25, 3.5, 4.6, C.card);
  s.addText("Foto tim", { x: 9.3, y: 3.3, w: 3.5, h: 0.4, fontFace: FONT, fontSize: 14, color: C.muted, align: "center", margin: 0 });
  footer(s);
  s.addNotes("Isi pekerjaan dan peran sesuai kesepakatan grup, lalu tempel foto tim di kotak kanan.");
}

// --- 2 Masalah ---
divider("02", "Masalah yang Kami Selesaikan", "Huruf komposisi terlalu kecil, dan label mencampur bahan dengan peringatan.",
  (s) => {
    s.addImage({ path: FOTO + "07-8888166603431.jpg", x: 7.6, y: 1.9, w: 5.2, h: 5.2 * 1225 / 1889, altText: "Foto label komposisi Superco" });
    s.addText("Label Superco. Foto: Open Food Facts", { x: 7.6, y: 5.32, w: 5.2, h: 0.25, fontFace: FONT, fontSize: 10, color: C.muted, align: "right", margin: 0 });
  },
  "Mulai dari cerita satu pengguna sungguhan sebelum fitur. Sebut nama dan pantangannya, jangan dikarang.");
{
  const s = pres.addSlide();
  bg(s);
  title(s, "Masalah yang Kami Selesaikan");
  const items = [
    ["Pengguna", "Pengguna yang punya pantangan makan, karena alergi atau pilihan sendiri."],
    ["Masalah", "Huruf daftar komposisi terlalu kecil, jadi bahan pantangan terlewat."],
    ["Asal masalah", "Dari pengguna yang punya pantangan: tiap belanja ia membalik bungkus dan membaca huruf kecil satu per satu."],
    ["Cara app menyelesaikannya", "Pilih pantangan sekali, foto komposisinya, lalu baca satu kalimat."],
  ];
  items.forEach(([k, t], i) => {
    const y = 1.2 + i * 1.18;
    eyebrow(s, k.toUpperCase(), 0.55, y, 6.4);
    s.addText(t, { x: 0.55, y: y + 0.32, w: 6.6, h: 0.8, fontFace: FONT, fontSize: 17, color: C.ink, margin: 0, valign: "top" });
  });
  card(s, 7.55, 1.2, 5.25, 4.55, C.amberBg);
  eyebrow(s, "DAMPAK LAIN", 7.85, 1.45, 4.7, C.ink);
  s.addText("“Dapat mengandung” tidak lagi tercampur dengan bahan.", { x: 7.85, y: 1.85, w: 4.7, h: 1.2, fontFace: SERIF, fontSize: 22, color: C.ink, margin: 0, valign: "top" });
  s.addText("Pengguna tahu mana yang memang bahan produk, dan mana yang hanya kemungkinan dari pabrik. Nama Latin atau Inggris, misalnya arachis hypogaea, ikut dikenali.", { x: 7.85, y: 3.15, w: 4.7, h: 1.6, fontFace: FONT, fontSize: 15, color: C.ink, margin: 0, valign: "top" });
  s.addImage({ path: DEMO + "crop-peringatan.png", x: 7.85, y: 4.65, w: 2.4, h: 2.4 * 560 / 1260, altText: "Kartu hijau dengan peringatan dapat mengandung kacang" });
  footer(s);
  s.addNotes("Dampak lain: pengguna bisa membedakan bahan dan kemungkinan sisa produksi. Nama Latin seperti arachis hypogaea dikenali sebagai kacang.");
}

// --- 3 Solusi AI ---
divider("03", "Solusi Berbasis AI", "Tiga fitur AI berurutan dalam satu foto.", cropRight("crop-hasil-ai.png", 910 / 1260, "Bagian hasil AI di layar app"),
  "Dua fitur diajarkan (Create ML, Foundation Models) dan satu dari side-app (baca teks dari foto). Semuanya jalan di perangkat.");
{
  const s = pres.addSlide();
  bg(s);
  title(s, "Solusi Berbasis AI");
  const steps = [
    ["1", "Side-app  ·  baca teks dari foto", "Vision", "Membaca huruf di foto, bahasa Indonesia dan Inggris. Hanya teks di bawah judul Komposisi atau Ingredients."],
    ["2", "Diajarkan  ·  sesi 1.3", "Create ML", "Model buatan kami memilah tiap kalimat: bahan, peringatan “dapat mengandung”, atau lain. Dilatih dari 1.197 kalimat 220 label sungguhan."],
    ["3", "Diajarkan  ·  sesi 2.6", "Foundation Models", "Model bawaan Apple Intelligence menjelaskan kenapa, misalnya “Arachis hypogaea adalah nama ilmiah kacang tanah.”"],
  ];
  steps.forEach(([n, grup, judul, isi], i) => {
    const x = 0.55 + i * 3.0;
    card(s, x, 1.25, 2.8, 4.2);
    s.addText(n, { x: x + 0.25, y: 1.45, w: 1, h: 0.5, fontFace: SERIF, fontSize: 28, color: C.brick, margin: 0 });
    s.addText(grup, { x: x + 0.25, y: 2.0, w: 2.4, h: 0.3, fontFace: FONT, fontSize: 11, color: C.muted, margin: 0 });
    s.addText(judul, { x: x + 0.25, y: 2.35, w: 2.45, h: 0.8, valign: "top", fontFace: SERIF, fontSize: 19, color: C.ink, margin: 0 });
    s.addText(isi, { x: x + 0.25, y: 3.25, w: 2.35, h: 2.4, fontFace: FONT, fontSize: 13.5, color: C.ink, margin: 0, valign: "top" });
    if (i < 2) s.addText("→", { x: x + 2.78, y: 3.0, w: 0.25, h: 0.4, fontFace: FONT, fontSize: 18, color: C.brick, margin: 0, align: "center" });
  });
  s.addText("Pantangan dicocokkan dengan daftar kata hanya di kalimat bahan. Kalimat peringatan jadi kotak kuning terpisah.", { x: 0.55, y: 5.65, w: 8.8, h: 0.6, fontFace: FONT, fontSize: 14, color: C.muted, margin: 0, valign: "top" });
  s.addImage({ path: DEMO + "crop-hasil-ai.png", x: 9.6, y: 1.25, w: 3.2, h: 3.2 * 910 / 1260, altText: "Hasil AI dan penjelasan di layar app" });
  s.addText("Layar hasil: bagian HASIL AI dan KENAPA", { x: 9.6, y: 3.65, w: 3.2, h: 0.3, fontFace: FONT, fontSize: 11, color: C.muted, margin: 0 });
  footer(s);
  s.addNotes("Urutan: foto, Vision membaca teks, Create ML memilah kalimat, daftar kata mencocokkan pantangan di kalimat bahan, Foundation Models menjelaskan. Tunjuk bagian HASIL AI saat demo.");
}

// --- 4 Demo ---
divider("04", "Demo Produk", "Satu kali foto, tiga kemungkinan hasil.", cropRight("crop-peringatan.png", 560 / 1260, "Kartu hijau dengan peringatan dapat mengandung"),
  "Pindah ke iPhone. Urutan: kacang dan pemanis jadi merah; Ubah ke garam, foto teh jadi hijau; foto wafer dengan dapat mengandung; foto depan kemasan ditolak.");
{
  const s = pres.addSlide();
  bg(s);
  title(s, "Demo Produk");
  const phones = [
    ["pantang-bahaya.png", "Happy path", "Ada kacang dan pemanis."],
    ["pantang-aman.png", "Foto lagi tanpa menutup app", "Tidak ditemukan garam."],
    ["pantang-peringatan.png", "Dapat mengandung", "Peringatan terpisah dari bahan."],
    ["pantang-ditolak.png", "Unhappy path", "Bukan daftar komposisi, ditolak."],
  ];
  const h = 5.0, w = h * PHONE, gap = 0.55;
  const start = (13.333 - (4 * w + 3 * gap)) / 2;
  phones.forEach(([f, cap, sub], i) => {
    const x = start + i * (w + gap);
    phone(s, DEMO + f, x, 1.1, h, cap);
    s.addText(cap, { x: x - 0.3, y: 6.2, w: w + 0.6, h: 0.3, fontFace: FONT, fontSize: 13, bold: true, color: C.ink, align: "center", margin: 0 });
    s.addText(sub, { x: x - 0.3, y: 6.5, w: w + 0.6, h: 0.3, fontFace: FONT, fontSize: 12, color: C.muted, align: "center", margin: 0 });
  });
  s.addNotes("Cadangan unhappy path: izin kamera ditolak, muncul pesan dan tombol Buka Pengaturan.");
}

// --- 5 Validasi ---
divider("05", "Validasi Produk", "10 label sungguhan: 8 benar sebelum Create ML, 10 benar sesudahnya.", (s) => {
    s.addText("8", { x: 7.9, y: 2.4, w: 1.6, h: 1.8, fontFace: SERIF, fontSize: 110, color: C.muted, margin: 0, align: "center" });
    s.addText("→", { x: 9.5, y: 2.75, w: 1.0, h: 1.0, fontFace: FONT, fontSize: 44, color: C.brick, margin: 0, align: "center" });
    s.addText("10", { x: 10.5, y: 2.4, w: 2.4, h: 1.8, fontFace: SERIF, fontSize: 110, color: C.green, margin: 0, align: "center" });
    s.addText("dari 10 label benar", { x: 7.9, y: 4.25, w: 5, h: 0.4, fontFace: FONT, fontSize: 16, color: C.muted, margin: 0, align: "center" });
  },
  "10 foto dari Open Food Facts, tidak ikut data latih. Detail di validasi/HASIL.md.");
{
  const s = pres.addSlide();
  bg(s);
  title(s, "Validasi Produk");
  const stats = [
    ["INPUT YANG DICOBA", "10 label", "Produk Indonesia dari Open Food Facts, tidak ikut data latih"],
    ["BERHASIL", "10 dari 10", "Sebelum Create ML: 8 dari 10"],
    ["CONTOH YANG GAGAL", "Superco", "Versi lama menghitung “dapat mengandung telur dan kacang” sebagai bahan"],
  ];
  stats.forEach(([k, v, d], i) => {
    const x = 0.55 + i * 4.15;
    card(s, x, 1.2, 3.95, 2.3);
    eyebrow(s, k, x + 0.28, 1.4, 3.4, C.muted);
    s.addText(v, { x: x + 0.28, y: 1.78, w: 3.4, h: 0.75, fontFace: SERIF, fontSize: 34, color: i === 1 ? C.green : C.ink, margin: 0 });
    s.addText(d, { x: x + 0.28, y: 2.6, w: 3.45, h: 0.75, fontFace: FONT, fontSize: 13, color: C.muted, margin: 0, valign: "top" });
  });
  card(s, 0.55, 3.75, 12.25, 2.95);
  eyebrow(s, "LESSON LEARNED", 0.85, 3.98, 6);
  s.addText("Label kemasan mencampur bahan dengan peringatan. Mencocokkan kata saja tidak cukup: kalimatnya perlu dipilah dulu. Model kami benar 90,4% di 230 kalimat uji.", { x: 0.85, y: 4.35, w: 7.4, h: 2.1, fontFace: SERIF, fontSize: 19, color: C.ink, margin: 0, valign: "top" });
  s.addImage({ path: FOTO + "07-8888166603431.jpg", x: 8.6, y: 3.98, w: 3.9, h: 3.9 * 1225 / 1889, altText: "Label Superco dengan kalimat dapat mengandung" });
  s.addText("Foto: Open Food Facts", { x: 8.6, y: 6.5, w: 3.9, h: 0.2, fontFace: FONT, fontSize: 9, color: C.muted, align: "right", margin: 0 });
  footer(s);
  s.addNotes("Gagal kedua di versi lama: Oat M*lk, kacang terbaca dari catatan peralatan produksi. Batasnya: hanya 10 foto, dan bukan dari kamera app.");
}

// --- 6 Rencana ---
divider("06", "Rencana Pengembangan", "Satu langkah berikutnya.", null, "Satu langkah saja. Jangan bahas bisnis atau pasar.");
{
  const s = pres.addSlide();
  bg(s);
  title(s, "Rencana Pengembangan");
  card(s, 0.55, 1.25, 7.6, 3.9);
  eyebrow(s, "LANGKAH BERIKUTNYA", 0.95, 1.6, 6);
  s.addText("Uji 30 kemasan dari kamera iPhone.", { x: 0.95, y: 2.0, w: 6.9, h: 1.3, fontFace: SERIF, fontSize: 32, color: C.ink, margin: 0, valign: "top" });
  s.addText("Validasi kali ini memakai foto dari Open Food Facts. Berikutnya kami foto sendiri di minimarket, termasuk huruf yang lengkung atau mengkilap, lalu kalimat yang salah dipilah ditambahkan ke data latih Create ML.", { x: 0.95, y: 3.45, w: 6.9, h: 2.0, fontFace: FONT, fontSize: 17, color: C.ink, margin: 0, valign: "top" });
  card(s, 8.45, 1.25, 4.35, 3.9, C.amberBg);
  eyebrow(s, "KENAPA INI", 8.75, 1.6, 3.8, C.ink);
  s.addText("Data latih dan uji sekarang berasal dari 230 foto Open Food Facts. Kamera iPhone di rak toko memberi sudut, cahaya, dan pantulan yang belum pernah dilihat model.", { x: 8.75, y: 2.0, w: 3.8, h: 3.5, fontFace: FONT, fontSize: 16, color: C.ink, margin: 0, valign: "top" });
  footer(s);
  s.addNotes("Penutup satu kalimat: berikutnya kami uji 30 kemasan dari kamera iPhone sendiri, lalu kalimat yang salah masuk ke data latih. Tidak ada slide penutup.");
}

pres.writeFile({ fileName: __dirname + "/PantangMakan.pptx" })
  .then(() => console.log("wrote pptx"))
  .catch((err) => { console.error(err); process.exit(1); });
