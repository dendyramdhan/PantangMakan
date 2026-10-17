const pptxgen = require("pptxgenjs");
const pres = new pptxgen();

pres.defineLayout({ name: "WIDE", width: 13.333, height: 7.5 });
pres.layout = "WIDE";
pres.author = "Grup 5";
pres.title = "PantangMakan";
pres.subject = "Challenge Day 3 · Jalur Tim";

const C = {
  bg: "F7F4EE",
  ink: "1C1917",
  muted: "6B6560",
  brick: "B85A3C",
  green: "1E7345",
  greenBg: "E3F5E8",
  red: "BA2929",
  redBg: "FCE6E6",
  line: "E4DDD4",
  card: "FFFCF8",
  white: "FFFFFF",
};

const FONT = "Calibri";
const SERIF = "Georgia";

function bg(slide) {
  slide.background = { color: C.bg };
}

function footer(slide, label) {
  slide.addText(label, {
    x: 0.55, y: 7.12, w: 8, h: 0.24,
    fontFace: FONT, fontSize: 11, color: C.muted, margin: 0,
  });
}

function divider(num, title, note) {
  const slide = pres.addSlide();
  bg(slide);
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 0.18, h: 7.5, fill: { color: C.brick },
  });
  slide.addText(num, {
    x: 0.85, y: 2.15, w: 4, h: 0.9,
    fontFace: SERIF, fontSize: 54, color: C.brick, margin: 0,
  });
  slide.addText(title, {
    x: 0.85, y: 3.15, w: 11, h: 1.1,
    fontFace: SERIF, fontSize: 40, color: C.ink, margin: 0,
  });
  slide.addNotes(note);
  return slide;
}

function contentTitle(slide, title) {
  slide.addText(title, {
    x: 0.55, y: 0.32, w: 12.2, h: 0.58,
    fontFace: SERIF, fontSize: 32, color: C.ink, margin: 0,
  });
}

// --- Sampul ---
{
  const s = pres.addSlide();
  bg(s);
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 0.18, h: 7.5, fill: { color: C.brick },
  });
  s.addText("Jalur Tim  ·  Grup 5", {
    x: 0.85, y: 1.7, w: 10, h: 0.35,
    fontFace: FONT, fontSize: 16, color: C.brick, margin: 0,
  });
  s.addText("PantangMakan.", {
    x: 0.85, y: 2.15, w: 11, h: 1.05,
    fontFace: SERIF, fontSize: 60, color: C.ink, margin: 0,
  });
  s.addText("Foto daftar komposisi. Satu kalimat: aman, atau tidak aman.", {
    x: 0.85, y: 3.35, w: 10, h: 0.4,
    fontFace: FONT, fontSize: 18, color: C.muted, margin: 0,
  });
  s.addText("Muhammad Fajar Wira Azdi    ·    Ahmad Syafiq Kamil    ·    Dendy Ramdhan Fauzy\nMohamad Arrizal    ·    Zuber Khatib", {
    x: 0.85, y: 4.5, w: 11, h: 0.8,
    fontFace: FONT, fontSize: 16, color: C.ink, margin: 0,
  });
  s.addNotes("Sampul. Sebut nama app, jalur tim, dan lima nama Grup 5. Langsung ke masalah. Jangan perkenalan panjang.");
}

divider("01", "Tim Kami", "Bagian ini tidak dinilai. Sebut nama saja. Pekerjaan dan peran masih kosong, jangan mengarang.");

{
  const s = pres.addSlide();
  bg(s);
  contentTitle(s, "Tim Kami");
  const header = {
    fill: { color: "1C1917" }, color: C.white, bold: true,
    fontFace: FONT, fontSize: 13, align: "left", valign: "middle",
  };
  const cell = {
    fill: { color: C.card }, color: C.ink,
    fontFace: FONT, fontSize: 15, align: "left", valign: "middle",
  };
  const empty = {
    fill: { color: C.card }, color: C.muted,
    fontFace: FONT, fontSize: 15, align: "left", valign: "middle",
  };
  const names = [
    "Muhammad Fajar Wira Azdi",
    "Ahmad Syafiq Kamil",
    "Dendy Ramdhan Fauzy",
    "Mohamad Arrizal",
    "Zuber Khatib",
  ];
  const rows = [
    [
      { text: "Nama", options: header },
      { text: "Pekerjaan saat ini", options: header },
      { text: "Peran di tim", options: header },
    ],
    ...names.map((name) => [
      { text: name, options: cell },
      { text: "—", options: empty },
      { text: "—", options: empty },
    ]),
  ];
  s.addTable(rows, {
    x: 0.55, y: 1.2, w: 12.2, h: 4.6,
    colW: [5.2, 3.5, 3.5],
    border: [{ pt: 0.5, color: C.line }, { pt: 0.5, color: C.line }, { pt: 0.5, color: C.line }, { pt: 0.5, color: C.line }],
    fontFace: FONT,
    valign: "middle",
  });
  s.addText("Foto tim belum ada. Pekerjaan dan peran diisi setelah disepakati.", {
    x: 0.55, y: 6.05, w: 12, h: 0.32,
    fontFace: FONT, fontSize: 14, color: C.muted, margin: 0,
  });
  footer(s, "Grup 5  ·  PantangMakan  ·  Jalur Tim");
  s.addNotes("Jangan isi pekerjaan atau peran kalau belum disepakati. Nanny dan sutrisno ada di Grup 6, jangan disebut sebagai anggota.");
}

divider("02", "Masalah yang Kami Selesaikan", "User sudah tahu pantangannya. Huruf di kemasan terlalu kecil, jadi bahan yang harus dihindari terlewat. Masalah ini dari user, bukan dari riset yang dikarang.");

{
  const s = pres.addSlide();
  bg(s);
  contentTitle(s, "Masalah yang Kami Selesaikan");
  // Lima isi yang diminta template: pengguna, masalah, asal masalah, cara app menyelesaikan, dampak lain.
  const cards = [
    { k: "Pengguna", t: "Orang yang sudah tahu pantangan makannya, karena alergi atau sengaja dihindari." },
    { k: "Masalah", t: "Huruf daftar komposisi di kemasan terlalu kecil, jadi bahan pantangan terlewat." },
    { k: "Asal masalah", t: "Dari pengguna nyata yang punya pantangan. Ia harus membalik bungkus dan membaca komposisi satu per satu." },
    { k: "Cara app menyelesaikannya", t: "Pilih pantangan sekali, foto komposisi, lalu baca satu kalimat: aman atau tidak aman." },
    { k: "Dampak lain", t: "Nama bahan asing ikut dikenali. Arachis hypogaea terbaca sebagai kacang, jadi user tidak perlu hafal nama Latin atau Inggris.", wide: true },
  ];
  const cardH = 1.62;
  const gapY = 0.2;
  cards.forEach((card, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = 0.55 + col * 6.35;
    const y = 1.15 + row * (cardH + gapY);
    const w = card.wide ? 12.4 : 6.05;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x, y, w, h: cardH,
      fill: { color: card.wide ? C.greenBg : C.card }, rectRadius: 0.12,
    });
    s.addText(card.k, {
      x: x + 0.3, y: y + 0.22, w: w - 0.6, h: 0.32,
      fontFace: FONT, fontSize: 13, color: card.wide ? C.green : C.brick, margin: 0,
    });
    s.addText(card.t, {
      x: x + 0.3, y: y + 0.6, w: w - 0.6, h: 0.85,
      fontFace: FONT, fontSize: 18, color: C.ink, margin: 0, valign: "top",
    });
  });
  footer(s, "Grup 5  ·  PantangMakan  ·  Jalur Tim");
  s.addNotes("Buka dengan cerita satu orang sebelum fitur (syarat D4 Skilled). Sebut nama dan pantangan orang sungguhan yang kalian kenal, jangan dikarang. Contoh alur: dia di minimarket, membalik bungkus selai, huruf komposisinya kecil. Lalu: pilih pantangan sekali, foto, baca satu kalimat. Dampak lain: arachis hypogaea dikenali sebagai kacang.");
}

divider("03", "Solusi Berbasis AI", "Sebut kelompoknya: dua diajarkan (Create ML, Foundation Models) dan dua side-app (baca teks dari foto, API). Jangan bilang semuanya on-device. Di layar hasil, tunjuk bagian HASIL AI.");

{
  const s = pres.addSlide();
  bg(s);
  contentTitle(s, "Solusi Berbasis AI");
  const steps = [
    { n: "1", grup: "Side-app  ·  baca teks dari foto", judul: "Vision", isi: "Membaca huruf di foto, bahasa Indonesia dan Inggris. Hanya teks di bawah judul Komposisi, Ingredients, atau Daftar bahan." },
    { n: "2", grup: "Diajarkan  ·  sesi 1.3", judul: "Create ML", isi: "Model PantanganText mengklasifikasi teks komposisi lewat Core ML. Labelnya tampil di layar hasil, misalnya kacang 92%." },
    { n: "3", grup: "Diajarkan  ·  sesi 2.6", judul: "Foundation Models", isi: "System Language Model bawaan Apple Intelligence menyusun kalimat aman atau tidak aman." },
    { n: "4", grup: "Side-app  ·  model di server", judul: "API Dicoding", isi: "Kalau model Apple tidak tersedia, gpt-oss-20b menyusun kalimat yang sama. Kalau internet mati, kalimat tetap keluar dan ada tombol Coba lagi." },
  ];
  steps.forEach((step, i) => {
    const x = 0.5 + i * 3.2;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x, y: 1.2, w: 3.02, h: 4.3,
      fill: { color: C.card }, rectRadius: 0.12,
    });
    s.addText(step.n, {
      x: x + 0.22, y: 1.4, w: 2.5, h: 0.5,
      fontFace: SERIF, fontSize: 28, color: C.brick, margin: 0,
    });
    s.addText(step.grup, {
      x: x + 0.22, y: 2.05, w: 2.58, h: 0.55,
      fontFace: FONT, fontSize: 12, color: C.muted, margin: 0,
    });
    s.addText(step.judul, {
      x: x + 0.22, y: 2.6, w: 2.58, h: 0.7,
      fontFace: SERIF, fontSize: 22, color: C.ink, margin: 0,
    });
    s.addText(step.isi, {
      x: x + 0.22, y: 3.4, w: 2.58, h: 1.9, valign: "top",
      fontFace: FONT, fontSize: 14, color: C.ink, margin: 0,
    });
  });
  footer(s, "Keputusan kartu: daftar kata, sesuai pantangan yang user pilih.");
  s.addNotes("Urutan di app: foto, Vision membaca teks, Create ML memberi label (tampil di HASIL AI), Foundation Models menyusun kalimat; API Dicoding hanya kalau model Apple tidak ada. Warna kartu tetap dari daftar kata sesuai pantangan user. User pilih garam, kemasan tidak memuat garam: Aman, bisa kamu makan, tidak mengandung garam. Ada arachis dan user pilih kacang: Tidak aman, mengandung kacang. System Language Model hanya menyusun kalimat itu.");
}

divider("04", "Demo Produk", "Saat bagian ini, pindah ke iPhone. Urutan: happy path merah, foto ulang jadi hijau, lalu foto yang bukan komposisi ditolak. Jangan tutup app di antara foto pertama dan kedua.");

{
  const s = pres.addSlide();
  bg(s);
  contentTitle(s, "Demo Produk");
  const phones = [
    { file: __dirname + "/demo/pantang-bahaya.png", cap: "Happy path", sub: "Tidak aman, mengandung kacang dan pemanis." },
    { file: __dirname + "/demo/pantang-aman.png", cap: "Foto kedua, app tetap terbuka", sub: "Aman, bisa kamu makan, tidak mengandung garam." },
    { file: __dirname + "/demo/pantang-ditolak.png", cap: "Unhappy path", sub: "Ditolak. Gambar ini bukan daftar komposisi." },
  ];
  const h = 4.85;
  const w = h * (1260 / 2736);
  const gap = 0.42;
  const total = phones.length * w + (phones.length - 1) * gap;
  const start = (13.333 - total) / 2;
  phones.forEach((phone, i) => {
    const x = start + i * (w + gap);
    s.addImage({
      path: phone.file,
      x, y: 1.08, w, h,
      sizing: { type: "contain", w, h },
      altText: phone.cap,
    });
    s.addText(phone.cap, {
      x: x - 0.15, y: 6.05, w: w + 0.3, h: 0.28,
      fontFace: FONT, fontSize: 13, color: C.ink, align: "center", bold: true, margin: 0,
    });
    s.addText(phone.sub, {
      x: x - 0.25, y: 6.32, w: w + 0.5, h: 0.55,
      fontFace: FONT, fontSize: 12, color: C.muted, align: "center", margin: 0,
    });
  });
  s.addNotes("Di iPhone: pilih kacang dan pemanis, foto komposisi yang memuat kacang dan gula. Lalu Foto ulang pada teh, pantangan garam: kartu hijau. Terakhir foto depan kemasan: Ditolak. Izin kamera ditolak juga bisa ditunjukkan: pita kiri dan Buka Pengaturan.");
}

divider("05", "Validasi Produk", "Jangan mengarang angka. Evaluasi 10 foto belum dijalankan. Lesson learned yang boleh disebut: Foundation Models gagal di Simulator iOS 26, jalan di Simulator iOS 27.");

{
  const s = pres.addSlide();
  bg(s);
  contentTitle(s, "Validasi Produk");
  const stats = [
    { k: "Input yang dicoba", v: "—", d: "Isi: jumlah foto kemasan sungguhan" },
    { k: "Berhasil", v: "—", d: "Isi: berapa yang kalimatnya benar" },
    { k: "Contoh yang gagal", v: "—", d: "Isi: satu kemasan yang salah dan sebabnya" },
  ];
  stats.forEach((item, i) => {
    const x = 0.55 + i * 4.2;
    s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
      x, y: 1.25, w: 3.95, h: 2.35,
      fill: { color: C.card }, rectRadius: 0.12,
    });
    s.addText(item.k, {
      x: x + 0.28, y: 1.45, w: 3.4, h: 0.32,
      fontFace: FONT, fontSize: 14, color: C.muted, margin: 0,
    });
    s.addText(item.v, {
      x: x + 0.28, y: 1.9, w: 3.4, h: 0.8,
      fontFace: SERIF, fontSize: 36, color: C.ink, margin: 0,
    });
    s.addText(item.d, {
      x: x + 0.28, y: 2.85, w: 3.4, h: 0.35,
      fontFace: FONT, fontSize: 14, color: C.brick, margin: 0,
    });
  });
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: 0.55, y: 3.9, w: 12.2, h: 2.35,
    fill: { color: C.card }, rectRadius: 0.12,
  });
  s.addText("Lesson learned", {
    x: 0.85, y: 4.15, w: 11, h: 0.32,
    fontFace: FONT, fontSize: 14, color: C.brick, margin: 0,
  });
  s.addText("Foundation Models selalu gagal di Simulator iOS 26. Di Simulator iOS 27, kalimatnya keluar.", {
    x: 0.85, y: 4.6, w: 11.5, h: 1.2,
    fontFace: SERIF, fontSize: 26, color: C.ink, margin: 0,
  });
  footer(s, "Grup 5  ·  PantangMakan  ·  Jalur Tim");
  s.addNotes("Kalau 10 foto sudah dicoba sebelum naik, ganti angka di slide ini. Jangan isi angka yang belum dihitung.");
}

divider("06", "Rencana Pengembangan", "Satu langkah berikutnya saja. Jangan bahas bisnis atau pasar.");

{
  const s = pres.addSlide();
  bg(s);
  contentTitle(s, "Rencana Pengembangan");
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: 0.55, y: 1.45, w: 12.2, h: 3.6,
    fill: { color: C.card }, rectRadius: 0.12,
  });
  s.addText("Langkah berikutnya", {
    x: 0.95, y: 1.85, w: 11, h: 0.35,
    fontFace: FONT, fontSize: 14, color: C.brick, margin: 0,
  });
  s.addText("Tambah data latih dari kemasan sungguhan.", {
    x: 0.95, y: 2.4, w: 11, h: 0.7,
    fontFace: SERIF, fontSize: 36, color: C.ink, margin: 0,
  });
  s.addText("Teks komposisi yang salah di Validasi Produk dimasukkan ke data latih\nCreate ML PantanganText, lalu model dilatih ulang dan dicoba lagi.", {
    x: 0.95, y: 3.35, w: 11, h: 1.3,
    fontFace: FONT, fontSize: 22, color: C.ink, margin: 0,
  });
  footer(s, "Grup 5  ·  PantangMakan  ·  Jalur Tim");
  s.addNotes("Satu kalimat penutup: kemasan yang salah kami masukkan ke data latih Create ML, lalu latih ulang. Sebut contoh gagal dari slide Validasi kalau sudah ada. Tidak ada slide penutup.");
}

pres.writeFile({ fileName: __dirname + "/PantangMakan.pptx" })
  .then(() => console.log("wrote pptx"))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
