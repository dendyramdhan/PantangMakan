// Builds real ScanBite components and five screens on the current page.
// Matches the Lovable prototype: six pantangan, no "aman", kacang examples.

const INK = rgb("2B2B28");
const BG = rgb("F9F6F1");
const WHITE = rgb("FFFFFF");
const MUTED = rgb("6E6B65");
const LINE = rgb("E4E0D8");
const CHIP_LINE = rgb("D5D3CE");
const ACCENT = rgb("B85A3C");
const BUTTON = rgb("2B2B28");
const BUTTON_OFF = rgb("9C9B96");
const FINDER = rgb("EEECE4");
const BANNER = rgb("F6E3DC");
const AMAN = rgb("217347");
const AMAN_LATAR = rgb("E3F5E8");
const BAHAYA = rgb("BA2929");
const BAHAYA_LATAR = rgb("FCE6E6");
const SECONDARY = rgb("E6E3DB");
const CANVAS = rgb("EFECE6");
let step = "start";

function rgb(hex) {
  const n = parseInt(hex, 16);
  return { r: ((n >> 16) & 255) / 255, g: ((n >> 8) & 255) / 255, b: (n & 255) / 255 };
}

function solid(color) {
  return [{ type: "SOLID", color: color }];
}

let paint = {};
let type = {};

function listed(method) {
  try {
    if (typeof figma[method] === "function") return figma[method]();
  } catch (err) {
    return [];
  }
  return [];
}

function paintStyle(name, color) {
  const found = listed("getLocalPaintStyles").find((s) => s.name === name);
  const style = found || figma.createPaintStyle();
  style.name = name;
  style.paints = solid(color);
  return style;
}

function textStyle(name, style, size, line, spacing) {
  const found = listed("getLocalTextStyles").find((s) => s.name === name);
  const ts = found || figma.createTextStyle();
  ts.name = name;
  ts.fontName = { family: "Inter", style: style };
  ts.fontSize = size;
  ts.lineHeight = { unit: "PIXELS", value: line };
  if (spacing !== undefined) ts.letterSpacing = { unit: "PIXELS", value: spacing };
  return ts;
}

function makeText(characters, styleName, colorStyle) {
  const style = type[styleName];
  const t = figma.createText();
  t.fontName = style.fontName;
  t.characters = characters;
  t.fontSize = style.fontSize;
  t.lineHeight = style.lineHeight;
  if (style.letterSpacing && style.letterSpacing.value) t.letterSpacing = style.letterSpacing;
  t.fills = paint[colorStyle].paints;
  t.name = "Label";
  t.textAutoResize = "WIDTH_AND_HEIGHT";
  return t;
}

function hug(node) {
  try {
    node.layoutSizingHorizontal = "HUG";
    node.layoutSizingVertical = "HUG";
  } catch (err) {
    /* some components reject HUG */
  }
}

function fillX(node) {
  try {
    node.layoutSizingHorizontal = "FILL";
  } catch (err) {
    /* keep the node's own width */
  }
}

function emptyFills(node) {
  node.fills = [];
}

function strokeOf(node, color, weight) {
  node.strokes = solid(color);
  node.strokeWeight = weight;
  node.strokeAlign = "INSIDE";
}

function iconBase(name) {
  const c = figma.createComponent();
  c.name = name;
  c.resize(18, 18);
  emptyFills(c);
  c.clipsContent = false;
  return c;
}

function strokeNode(node, color, weight) {
  node.fills = [];
  node.strokes = solid(color);
  node.strokeWeight = weight;
  node.strokeCap = "ROUND";
  node.strokeJoin = "ROUND";
}

function lineIcon(parent, data, color, weight) {
  const v = figma.createVector();
  v.vectorPaths = [{ windingRule: "NONE", data: data }];
  strokeNode(v, color, weight);
  parent.appendChild(v);
  return v;
}

function makeIcons() {
  const arrow = iconBase("Icon/Arrow");
  const shaft = figma.createRectangle();
  shaft.resize(8, 1.75);
  shaft.x = 1;
  shaft.y = 8.1;
  shaft.cornerRadius = 1;
  shaft.fills = solid(INK);
  arrow.appendChild(shaft);
  lineIcon(arrow, "M 7.5 4.5 L 13.5 9 L 7.5 13.5", INK, 1.75);

  const camera = iconBase("Icon/Camera");
  const body = figma.createRectangle();
  body.resize(14, 10);
  body.x = 2;
  body.y = 5;
  body.cornerRadius = 2;
  strokeNode(body, INK, 1.5);
  camera.appendChild(body);
  const lens = figma.createEllipse();
  lens.resize(4, 4);
  lens.x = 7;
  lens.y = 8;
  strokeNode(lens, INK, 1.5);
  camera.appendChild(lens);
  const bump = figma.createRectangle();
  bump.resize(5, 2);
  bump.x = 6;
  bump.y = 3.5;
  bump.cornerRadius = 1;
  bump.fills = solid(INK);
  camera.appendChild(bump);

  const refresh = iconBase("Icon/Refresh");
  const ring = figma.createEllipse();
  ring.resize(11, 11);
  ring.x = 3.5;
  ring.y = 4;
  strokeNode(ring, INK, 1.5);
  refresh.appendChild(ring);
  lineIcon(refresh, "M 8 3 L 13 3 L 13 8", INK, 1.75);

  const back = iconBase("Icon/Back");
  const chev = figma.createVector();
  chev.vectorPaths = [{ windingRule: "NONE", data: "M 12 3 L 5 9 L 12 15" }];
  strokeNode(chev, INK, 1.5);
  back.appendChild(chev);

  const scan = iconBase("Icon/Scan");
  const marks = [
    [2, 2, false, false],
    [10, 2, true, false],
    [2, 10, false, true],
    [10, 10, true, true],
  ];
  for (const mark of marks) {
    const h = figma.createRectangle();
    h.resize(6, 1.5);
    h.cornerRadius = 1;
    h.fills = solid(ACCENT);
    h.x = mark[2] ? mark[0] : mark[0];
    h.y = mark[3] ? mark[1] + 4.5 : mark[1];
    scan.appendChild(h);
    const v = figma.createRectangle();
    v.resize(1.5, 6);
    v.cornerRadius = 1;
    v.fills = solid(ACCENT);
    v.x = mark[2] ? mark[0] + 4.5 : mark[0];
    v.y = mark[1];
    scan.appendChild(v);
  }

  const alert = iconBase("Icon/Alert");
  const disc = figma.createEllipse();
  disc.resize(14, 14);
  disc.x = 2;
  disc.y = 2;
  strokeNode(disc, ACCENT, 1.5);
  alert.appendChild(disc);
  const bang = figma.createRectangle();
  bang.resize(1.5, 5);
  bang.x = 8.25;
  bang.y = 5;
  bang.cornerRadius = 1;
  bang.fills = solid(ACCENT);
  alert.appendChild(bang);
  const dot = figma.createEllipse();
  dot.resize(1.5, 1.5);
  dot.x = 8.25;
  dot.y = 11.5;
  dot.fills = solid(ACCENT);
  alert.appendChild(dot);

  const gear = iconBase("Icon/Settings");
  const sliders = [
    [2, 3.5, 14],
    [2, 8.1, 14],
    [2, 12.7, 14],
  ];
  for (const slider of sliders) {
    const row = figma.createRectangle();
    row.resize(slider[2], 1.5);
    row.x = slider[0];
    row.y = slider[1];
    row.cornerRadius = 1;
    row.fills = solid(ACCENT);
    gear.appendChild(row);
  }
  const knobs = [
    [4, 2.2],
    [10, 6.8],
    [6, 11.4],
  ];
  for (const knob of knobs) {
    const dot = figma.createEllipse();
    dot.resize(4, 4);
    dot.x = knob[0];
    dot.y = knob[1];
    dot.fills = solid(ACCENT);
    gear.appendChild(dot);
  }

  const camOff = iconBase("Icon/Camera off");
  const mini = camera.createInstance();
  mini.x = 0;
  mini.y = 0;
  camOff.appendChild(mini);
  lineIcon(camOff, "M 3.5 14.5 L 14.5 3.5", INK, 1.75);

  return { arrow, camera, refresh, back, scan, alert, gear, camOff };
}

function useFill(node, style) {
  node.fills = style.paints;
  try {
    node.fillStyleId = style.id;
  } catch (err) {
    /* style link is optional */
  }
}

function recolorIcon(instance, color) {
  const nodes = instance.findAll(function (n) {
    return n.type !== "INSTANCE" && n.type !== "COMPONENT" && "strokes" in n;
  });
  for (const n of nodes) {
    try {
      if (Array.isArray(n.strokes) && n.strokes.length) n.strokes = solid(color);
      if (Array.isArray(n.fills) && n.fills.length && n.fills[0].type === "SOLID") n.fills = solid(color);
    } catch (err) {
      /* nested instance paint can be locked */
    }
  }
}

function makeChipSet() {
  function variant(state) {
    const selected = state === "Selected";
    const c = figma.createComponent();
    c.name = "State=" + state;
    c.layoutMode = "HORIZONTAL";
    c.primaryAxisSizingMode = "AUTO";
    c.counterAxisSizingMode = "AUTO";
    c.primaryAxisAlignItems = "CENTER";
    c.counterAxisAlignItems = "CENTER";
    c.paddingLeft = 14;
    c.paddingRight = 14;
    c.paddingTop = 8;
    c.paddingBottom = 8;
    c.cornerRadius = 999;
    c.fills = solid(selected ? BANNER : BG);
    strokeOf(c, selected ? ACCENT : CHIP_LINE, 1);
    const label = makeText("susu", "Chip", selected ? "Accent" : "Ink");
    c.appendChild(label);
    c.description = selected ? "Pantangan yang sedang dipakai." : "Pantangan yang belum dipilih.";
    return c;
  }
  const idle = variant("Default");
  const on = variant("Selected");
  const set = figma.combineAsVariants([idle, on], figma.currentPage);
  set.name = "Chip";
  set.layoutMode = "HORIZONTAL";
  set.itemSpacing = 12;
  set.paddingTop = 12;
  set.paddingBottom = 12;
  set.paddingLeft = 12;
  set.paddingRight = 12;
  emptyFills(set);
  set.description = "Enam bahan saja: susu, kacang, telur, gluten, pemanis, garam.";
  return set;
}

function chip(set, label, state) {
  const source = set.children.find((n) => n.name === "State=" + state);
  const inst = source.createInstance();
  inst.findOne((n) => n.name === "Label").characters = label;
  return inst;
}

function makeButtonSet(icons) {
  function build(kind) {
    const c = figma.createComponent();
    c.name = "Kind=" + kind;
    c.layoutMode = "HORIZONTAL";
    c.primaryAxisAlignItems = kind === "Secondary" ? "CENTER" : "SPACE_BETWEEN";
    c.counterAxisAlignItems = "CENTER";
    c.paddingLeft = 16;
    c.paddingRight = 16;
    c.itemSpacing = 8;
    c.cornerRadius = kind === "Secondary" ? 12 : 14;
    c.resize(350, kind === "Secondary" ? 44 : 52);
    c.primaryAxisSizingMode = "FIXED";
    c.counterAxisSizingMode = "FIXED";
    const lead = icons.refresh.createInstance();
    lead.name = "Icon lead";
    const label = makeText(kind === "Secondary" ? "Contoh ada kacang" : "Mulai scan", "Button", kind === "Secondary" ? "Ink" : "White");
    label.name = "Label";
    label.textAlignHorizontal = kind === "Secondary" ? "CENTER" : "LEFT";
    const trail = (kind === "Secondary" ? icons.camera : icons.arrow).createInstance();
    trail.name = "Icon trail";
    c.appendChild(lead);
    c.appendChild(label);
    c.appendChild(trail);
    const inkOnFill = kind === "Secondary" ? INK : WHITE;
    recolorIcon(lead, inkOnFill);
    recolorIcon(trail, inkOnFill);
    if (kind === "Primary") {
      useFill(c, paint.Button);
      lead.visible = false;
    } else if (kind === "Disabled") {
      useFill(c, paint["Button disabled"]);
      lead.visible = false;
    } else {
      useFill(c, paint.Secondary);
      lead.visible = false;
      trail.visible = false;
    }
    return c;
  }
  const primary = build("Primary");
  const disabled = build("Disabled");
  const secondary = build("Secondary");
  const set = figma.combineAsVariants([primary, disabled, secondary], figma.currentPage);
  set.name = "Button";
  set.layoutMode = "VERTICAL";
  set.itemSpacing = 12;
  set.paddingTop = 12;
  set.paddingBottom = 12;
  set.paddingLeft = 12;
  set.paddingRight = 12;
  emptyFills(set);
  set.description = "Primary untuk aksi utama. Disabled sebelum ada pantangan. Secondary untuk contoh foto.";
  return set;
}

function button(set, kind, label, leadIcon, trailIcon, alignRight) {
  const source = set.children.find((n) => n.name === "Kind=" + kind);
  const inst = source.createInstance();
  const text = inst.findOne((n) => n.name === "Label");
  text.characters = label;
  const lead = inst.findOne((n) => n.name === "Icon lead");
  const trail = inst.findOne((n) => n.name === "Icon trail");
  if (leadIcon) {
    lead.visible = true;
    lead.swapComponent(leadIcon);
    recolorIcon(lead, kind === "Secondary" ? INK : WHITE);
  } else lead.visible = false;
  if (trailIcon) {
    trail.visible = true;
    trail.swapComponent(trailIcon);
    recolorIcon(trail, kind === "Secondary" ? INK : WHITE);
  } else trail.visible = false;
  if (alignRight) {
    text.textAlignHorizontal = "RIGHT";
    text.textAutoResize = "HEIGHT";
    fillX(text);
  }
  return inst;
}

function fotoUlang(set, icons) {
  const inst = button(set, "Primary", "Foto ulang", icons.refresh, null, false);
  inst.primaryAxisAlignItems = "CENTER";
  inst.itemSpacing = 8;
  const text = inst.findOne((n) => n.name === "Label");
  text.textAlignHorizontal = "CENTER";
  text.textAutoResize = "WIDTH_AND_HEIGHT";
  try {
    text.layoutSizingHorizontal = "HUG";
  } catch (err) {
    /* hug is optional on this instance */
  }
  return inst;
}

function makeAppBar(icons) {
  const c = figma.createComponent();
  c.name = "App bar";
  c.layoutMode = "VERTICAL";
  c.itemSpacing = 12;
  c.resize(350, 48);
  c.primaryAxisSizingMode = "AUTO";
  c.counterAxisSizingMode = "FIXED";
  useFill(c, paint.Background);
  const row = h("Title");
  row.primaryAxisAlignItems = "SPACE_BETWEEN";
  row.resize(350, 28);
  row.primaryAxisSizingMode = "FIXED";
  row.appendChild(makeText("ScanBite.", "App", "Ink"));
  row.appendChild(icons.scan.createInstance());
  const line = figma.createRectangle();
  line.name = "Divider";
  line.resize(350, 1);
  line.fills = solid(LINE);
  c.appendChild(row);
  c.appendChild(line);
  fillX(row);
  fillX(line);
  c.description = "Nama di kiri, tanda scan di kanan. Dipakai semua layar.";
  return c;
}

function makeCapturedPhoto() {
  const c = figma.createComponent();
  c.name = "Foto hasil";
  c.layoutMode = "NONE";
  c.resize(350, 210);
  c.cornerRadius = 22;
  c.clipsContent = true;
  useFill(c, paint.Finder);
  const marks = [
    [15, 15, 22, 2, 15, 15, 2, 22],
    [313, 193, 22, 2, 333, 173, 2, 22],
  ];
  for (const mark of marks) {
    const hbar = figma.createRectangle();
    hbar.resize(mark[2], mark[3]);
    hbar.x = mark[0];
    hbar.y = mark[1];
    hbar.fills = solid(ACCENT);
    const vbar = figma.createRectangle();
    vbar.resize(mark[6], mark[7]);
    vbar.x = mark[4];
    vbar.y = mark[5];
    vbar.fills = solid(ACCENT);
    c.appendChild(hbar);
    c.appendChild(vbar);
  }
  const card = v("Label pada foto", 4);
  card.paddingTop = 14;
  card.paddingBottom = 14;
  card.paddingLeft = 16;
  card.paddingRight = 16;
  card.cornerRadius = 8;
  card.fills = solid(WHITE);
  const isi = makeText("KOMPOSISI\nkacang tanah, gula,\nminyak kelapa", "Body", "Ink");
  isi.name = "Isi foto";
  card.appendChild(isi);
  c.appendChild(card);
  card.x = 78;
  card.y = 62;
  c.description = "Foto yang baru diambil. Sudut 22, tanda siku kiri atas dan kanan bawah.";
  return c;
}

function fotoHasil(comp, teks) {
  const inst = comp.createInstance();
  const isi = inst.findOne((n) => n.name === "Isi foto");
  if (isi && isi.type === "TEXT") isi.characters = teks;
  return inst;
}

function makeViewfinder(icons) {
  const c = figma.createComponent();
  c.name = "Viewfinder";
  c.layoutMode = "NONE";
  c.resize(350, 210);
  c.cornerRadius = 22;
  useFill(c, paint.Finder);
  c.clipsContent = true;
  const corners = [
    [15, 15, 15, 15],
    [313, 188, 333, 173],
  ];
  for (const corner of corners) {
    const horizontal = figma.createRectangle();
    horizontal.resize(22, 2);
    horizontal.x = corner[0];
    horizontal.y = corner[1];
    horizontal.cornerRadius = 1;
    horizontal.fills = solid(ACCENT);
    const vertical = figma.createRectangle();
    vertical.resize(2, 22);
    vertical.x = corner[2];
    vertical.y = corner[3];
    vertical.cornerRadius = 1;
    vertical.fills = solid(ACCENT);
    c.appendChild(horizontal);
    c.appendChild(vertical);
  }
  const column = figma.createFrame();
  column.name = "Label stack";
  column.layoutMode = "VERTICAL";
  column.primaryAxisAlignItems = "CENTER";
  column.counterAxisAlignItems = "CENTER";
  column.itemSpacing = 8;
  emptyFills(column);
  column.x = 95;
  column.y = 68;
  const cam = icons.camera.createInstance();
  recolorIcon(cam, MUTED);
  const caption = makeText("Daftar komposisi", "Body", "Muted");
  column.appendChild(cam);
  column.appendChild(caption);
  c.appendChild(column);
  column.x = Math.max(12, (c.width - column.width) / 2);
  column.y = Math.max(28, (c.height - column.height) / 2);
  c.description = "Area foto daftar komposisi. Bukan hasil scan.";
  return c;
}

function makeStatusSet(icons) {
  function line(kind, copy) {
    const c = figma.createComponent();
    c.name = "Kind=" + kind;
    c.layoutMode = "HORIZONTAL";
    c.counterAxisAlignItems = "CENTER";
    c.itemSpacing = 8;
    c.primaryAxisSizingMode = "AUTO";
    c.counterAxisSizingMode = "AUTO";
    emptyFills(c);
    const icon = icons.alert.createInstance();
    const label = makeText(copy, "Meta", "Accent");
    c.appendChild(icon);
    c.appendChild(label);
    return c;
  }
  const found = line("Found", "Bahan ditemukan");
  const unread = line("Unread", "Dari teks yang terbaca");
  const set = figma.combineAsVariants([found, unread], figma.currentPage);
  set.name = "Status";
  set.layoutMode = "VERTICAL";
  set.itemSpacing = 10;
  set.paddingTop = 12;
  set.paddingBottom = 12;
  set.paddingLeft = 12;
  set.paddingRight = 12;
  emptyFills(set);
  set.description = "Satu kalimat status. Bukan diagnosis.";
  return set;
}

function status(set, kind) {
  return set.children.find((n) => n.name === "Kind=" + kind).createInstance();
}

function makeBanner(icons) {
  const c = figma.createComponent();
  c.name = "Banner/Kamera ditolak";
  c.layoutMode = "VERTICAL";
  c.itemSpacing = 8;
  c.paddingTop = 14;
  c.paddingBottom = 14;
  c.paddingLeft = 14;
  c.paddingRight = 14;
  c.cornerRadius = 0;
  c.resize(350, 80);
  c.strokes = solid(ACCENT);
  c.strokeTopWeight = 0;
  c.strokeRightWeight = 0;
  c.strokeBottomWeight = 0;
  c.strokeLeftWeight = 2;
  c.primaryAxisSizingMode = "AUTO";
  c.counterAxisSizingMode = "FIXED";
  useFill(c, paint.Banner);
  const row = figma.createFrame();
  row.name = "Title row";
  row.layoutMode = "HORIZONTAL";
  row.itemSpacing = 8;
  row.counterAxisAlignItems = "MIN";
  emptyFills(row);
  const icon = icons.camOff.createInstance();
  const copy = makeText("Kamera ditolak. Buka Pengaturan, izinkan kamera, lalu kembali ke sini.", "Body", "Ink");
  copy.textAutoResize = "HEIGHT";
  copy.name = "Body";
  row.appendChild(icon);
  row.appendChild(copy);
  fillX(copy);
  const link = figma.createFrame();
  link.name = "Link";
  link.layoutMode = "HORIZONTAL";
  link.itemSpacing = 6;
  link.paddingLeft = 26;
  link.counterAxisAlignItems = "CENTER";
  emptyFills(link);
  link.appendChild(icons.gear.createInstance());
  link.appendChild(makeText("Buka Pengaturan", "Meta", "Accent"));
  c.appendChild(row);
  c.appendChild(link);
  fillX(row);
  return c;
}

function h(name) {
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = "HORIZONTAL";
  f.counterAxisAlignItems = "CENTER";
  f.itemSpacing = 8;
  emptyFills(f);
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "AUTO";
  return f;
}

function v(name, gap) {
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = "VERTICAL";
  f.itemSpacing = gap;
  emptyFills(f);
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "AUTO";
  return f;
}

function screenFrame(name) {
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = "VERTICAL";
  f.itemSpacing = 20;
  f.paddingTop = 22;
  f.paddingBottom = 22;
  f.paddingLeft = 20;
  f.paddingRight = 20;
  f.resize(390, 100);
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "FIXED";
  useFill(f, paint.Background);
  f.cornerRadius = 28;
  f.clipsContent = true;
  strokeOf(f, LINE, 1);
  f.effects = [
    {
      type: "DROP_SHADOW",
      color: { r: 0.12, g: 0.1, b: 0.06, a: 0.14 },
      offset: { x: 0, y: 10 },
      radius: 28,
      spread: 0,
      visible: true,
      blendMode: "NORMAL",
    },
  ];
  return f;
}

function stackIn(parent, child) {
  parent.appendChild(child);
  fillX(child);
}

function navRow(icons, label) {
  const row = h("Nav");
  row.primaryAxisAlignItems = "SPACE_BETWEEN";
  row.resize(350, 24);
  row.primaryAxisSizingMode = "FIXED";
  row.counterAxisSizingMode = "AUTO";
  row.appendChild(icons.back.createInstance());
  const eye = makeText(label, "Eyebrow", "Muted");
  row.appendChild(eye);
  return row;
}

function activeRow(chipSet, labels) {
  const row = h("Pantangan aktif");
  row.itemSpacing = 6;
  row.layoutWrap = "WRAP";
  const list = Array.isArray(labels) ? labels : [labels];
  for (const label of list) row.appendChild(chip(chipSet, label, "Default"));
  row.appendChild(makeText("Ubah", "Body", "Muted"));
  return row;
}

function contohRow(buttonSet) {
  const block = v("Contoh", 10);
  block.appendChild(makeText("Contoh foto untuk pantangan yang dipilih.", "Caption", "Muted"));
  const row = h("Dua contoh");
  row.itemSpacing = 8;
  row.resize(350, 44);
  row.primaryAxisSizingMode = "FIXED";
  const ada = button(buttonSet, "Secondary", "Contoh ada kacang");
  const tanpa = button(buttonSet, "Secondary", "Contoh tanpa kacang");
  row.appendChild(ada);
  row.appendChild(tanpa);
  block.appendChild(row);
  const bukan = button(buttonSet, "Secondary", "Contoh bukan komposisi");
  block.appendChild(bukan);
  fillX(row);
  fillX(bukan);
  return { block: block, ada: ada, tanpa: tanpa, bukan: bukan };
}

function rule() {
  const line = figma.createRectangle();
  line.name = "Divider";
  line.resize(350, 1);
  line.fills = solid(LINE);
  return line;
}

function pecahSorot(line, highlights) {
  const daftar = (highlights || []).filter(Boolean).sort((a, b) => b.length - a.length);
  if (!daftar.length) return [{ text: line, hit: false }];
  const lower = line.toLowerCase();
  let i = 0;
  const out = [];
  while (i < line.length) {
    let found = "";
    for (const kata of daftar) {
      if (lower.startsWith(kata.toLowerCase(), i)) {
        found = line.slice(i, i + kata.length);
        break;
      }
    }
    if (found) {
      out.push({ text: found, hit: true });
      i += found.length;
    } else {
      let j = i + 1;
      while (j < line.length && !daftar.some((kata) => lower.startsWith(kata.toLowerCase(), j))) j += 1;
      const plain = line.slice(i, j).trim();
      if (plain) out.push({ text: plain, hit: false });
      i = j;
    }
  }
  return out;
}

function ocrBlock(lines, highlights) {
  const block = v("Komposisi terbaca", 8);
  block.appendChild(makeText("KOMPOSISI TERBACA", "Eyebrow", "Muted"));
  for (const line of lines) {
    const row = h("Baris");
    row.layoutWrap = "WRAP";
    row.itemSpacing = 4;
    row.counterAxisSpacing = 4;
    row.counterAxisAlignItems = "CENTER";
    row.resize(350, 24);
    row.primaryAxisSizingMode = "FIXED";
    row.counterAxisSizingMode = "AUTO";
    for (const part of pecahSorot(line, highlights)) {
      if (part.hit) {
        const tanda = h("Kapsul");
        tanda.paddingLeft = 6;
        tanda.paddingRight = 6;
        tanda.paddingTop = 2;
        tanda.paddingBottom = 2;
        tanda.cornerRadius = 999;
        tanda.fills = solid(BAHAYA_LATAR);
        tanda.appendChild(makeText(part.text, "Meta", "Bahaya"));
        row.appendChild(tanda);
      } else {
        row.appendChild(makeText(part.text, "Body", "Ink"));
      }
    }
    block.appendChild(row);
    fillX(row);
  }
  return block;
}

function bukanKomposisiGambar() {
  const kartu = figma.createFrame();
  kartu.name = "Bukan komposisi";
  kartu.layoutMode = "NONE";
  kartu.resize(318, 128);
  kartu.cornerRadius = 16;
  kartu.clipsContent = true;
  kartu.fills = solid(WHITE);
  const isi = makeText("KEMASAN\nRasa original\nBerat bersih 68 g", "Body", "Muted");
  isi.x = 16;
  isi.y = 16;
  kartu.appendChild(isi);
  const coret = figma.createVector();
  coret.vectorPaths = [{ windingRule: "NONE", data: "M 16 112 L 300 16" }];
  coret.strokes = solid(BAHAYA);
  coret.strokeWeight = 3;
  coret.strokeCap = "ROUND";
  coret.fills = [];
  kartu.appendChild(coret);
  coret.resize(318, 128);
  return kartu;
}

function kotakHasil(kind, sentence) {
  const box = v("Kotak hasil", 6);
  box.paddingTop = 16;
  box.paddingBottom = 16;
  box.paddingLeft = 16;
  box.paddingRight = 16;
  box.cornerRadius = 22;
  box.resize(350, 40);
  box.primaryAxisSizingMode = "AUTO";
  box.counterAxisSizingMode = "FIXED";
  if (kind === "Found") useFill(box, paint["Bahaya latar"]);
  else if (kind === "Unread") useFill(box, paint["Aman latar"]);
  else {
    box.fills = solid(FINDER);
    strokeOf(box, LINE, 1);
  }
  if (kind === "Rejected") {
    const besar = makeText("Ditolak", "Title", "Ink");
    besar.fontSize = 44;
    besar.lineHeight = { unit: "PIXELS", value: 48 };
    box.appendChild(besar);
    const kartu = bukanKomposisiGambar();
    box.appendChild(kartu);
    fillX(kartu);
    const gambar = makeText("Gambar ini bukan daftar komposisi.", "Body", "Ink");
    gambar.textAutoResize = "HEIGHT";
    box.appendChild(gambar);
    fillX(gambar);
    return box;
  }
  const warna = kind === "Found" ? "Bahaya" : "Aman";
  const kalimat = makeText(sentence, "Title", warna);
  kalimat.textAutoResize = "HEIGHT";
  box.appendChild(kalimat);
  fillX(kalimat);
  return box;
}

function libraryCard(title, child) {
  const card = v(title, 8);
  card.appendChild(makeText(title, "Eyebrow", "Muted"));
  card.appendChild(child);
  hug(child);
  return card;
}

async function main() {
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  await figma.loadFontAsync({ family: "Inter", style: "Medium" });
  await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Bold" });

  paint = {
    Background: paintStyle("Pantang/Background", BG),
    Ink: paintStyle("Pantang/Ink", INK),
    Muted: paintStyle("Pantang/Muted", MUTED),
    Accent: paintStyle("Pantang/Accent", ACCENT),
    White: paintStyle("Pantang/White", WHITE),
    Line: paintStyle("Pantang/Line", LINE),
    Button: paintStyle("Pantang/Button", BUTTON),
    "Button disabled": paintStyle("Pantang/Button disabled", BUTTON_OFF),
    Finder: paintStyle("Pantang/Finder", FINDER),
    Banner: paintStyle("Pantang/Banner", BANNER),
    Aman: paintStyle("Pantang/Aman", AMAN),
    "Aman latar": paintStyle("Pantang/Aman latar", AMAN_LATAR),
    Bahaya: paintStyle("Pantang/Bahaya", BAHAYA),
    "Bahaya latar": paintStyle("Pantang/Bahaya latar", BAHAYA_LATAR),
    Secondary: paintStyle("Pantang/Secondary", SECONDARY),
  };
  type = {
    App: textStyle("Pantang/App", "Semi Bold", 20, 26, -0.3),
    Title: textStyle("Pantang/Title", "Regular", 30, 39, 0),
    Body: textStyle("Pantang/Body", "Regular", 15, 21, 0),
    Chip: textStyle("Pantang/Chip", "Medium", 15, 18, 0),
    Button: textStyle("Pantang/Button", "Semi Bold", 15, 18, 0),
    Eyebrow: textStyle("Pantang/Eyebrow", "Medium", 11, 14, 1.1),
    Meta: textStyle("Pantang/Meta", "Medium", 14, 18, 0),
    Caption: textStyle("Pantang/Caption", "Regular", 13, 18, 0),
  };

  const page = figma.currentPage;
  page.name = "ScanBite";
  const leftover = page.children.slice();
  for (const node of leftover) node.remove();

  step = "icons";
  const icons = makeIcons();
  step = "chips";
  const chips = makeChipSet();
  step = "buttons";
  const buttons = makeButtonSet(icons);
  step = "appbar";
  const appBar = makeAppBar(icons);
  step = "finder";
  const finder = makeViewfinder(icons);
  const foto = makeCapturedPhoto();
  step = "status";
  const statuses = makeStatusSet(icons);
  step = "banner";
  const banner = makeBanner(icons);
  step = "meta";


  const library = v("Library", 28);
  library.paddingTop = 8;
  library.paddingBottom = 8;
  library.fills = [];

  const swatches = h("Warna");
  swatches.itemSpacing = 10;
  swatches.layoutWrap = "WRAP";
  swatches.resize(360, 80);
  swatches.primaryAxisSizingMode = "FIXED";
  swatches.counterAxisSizingMode = "AUTO";
  const swatchNames = ["Background", "Ink", "Accent", "Button", "Button disabled", "Finder", "Banner", "Secondary"];
  for (const name of swatchNames) {
    const dot = figma.createFrame();
    dot.name = "Color/" + name;
    dot.resize(36, 36);
    dot.cornerRadius = 18;
    useFill(dot, paint[name]);
    strokeOf(dot, LINE, 1);
    swatches.appendChild(dot);
  }
  library.appendChild(libraryCard("Warna", swatches));

  const iconRow = h("Ikon");
  iconRow.itemSpacing = 12;
  for (const key of ["arrow", "camera", "refresh", "back", "scan", "alert", "gear", "camOff"]) {
    iconRow.appendChild(icons[key]);
  }
  library.appendChild(libraryCard("Ikon", iconRow));
  library.appendChild(libraryCard("Chip", chips));
  library.appendChild(libraryCard("Button", buttons));
  library.appendChild(libraryCard("App bar", appBar));
  library.appendChild(libraryCard("Viewfinder", finder));
  library.appendChild(libraryCard("Foto hasil", foto));
  library.appendChild(libraryCard("Status", statuses));
  library.appendChild(libraryCard("Banner", banner));


  function phone(name, minHeight) {
    const screen = screenFrame(name);
    if (minHeight) {
      screen.resize(390, minHeight);
      screen.primaryAxisSizingMode = "FIXED";
    }
    stackIn(screen, appBar.createInstance());
    return screen;
  }

  step = "screen-1";
  const pilih = phone("01 Pilih pantangan", 844);
  const intro = v("Intro", 10);
  const eye = h("Eyebrow");
  const dash = figma.createRectangle();
  dash.resize(18, 2);
  dash.cornerRadius = 1;
  useFill(dash, paint.Accent);
  eye.appendChild(dash);
  eye.appendChild(makeText("SEBELUM MEMINDAI", "Eyebrow", "Muted"));
  intro.appendChild(eye);
  const title = makeText("Pilih pantangan sebelum scan.", "Title", "Ink");
  title.textAutoResize = "HEIGHT";
  intro.appendChild(title);
  const lede = makeText("Hasil hanya dari kata yang terbaca di daftar komposisi.", "Body", "Muted");
  lede.textAutoResize = "HEIGHT";
  intro.appendChild(lede);
  stackIn(pilih, intro);
  fillX(title);
  fillX(lede);

  function chipGroup(heading, labels) {
    const group = v(heading, 10);
    group.appendChild(makeText(heading, "Meta", "Ink"));
    const row = h(heading + " chips");
    row.itemSpacing = 8;
    row.layoutWrap = "WRAP";
    row.resize(350, 40);
    row.primaryAxisSizingMode = "FIXED";
    row.counterAxisSizingMode = "AUTO";
    for (const label of labels) row.appendChild(chip(chips, label, "Default"));
    group.appendChild(row);
    return group;
  }
  stackIn(pilih, chipGroup("Alergi", ["susu", "kacang", "telur", "gluten"]));
  stackIn(pilih, chipGroup("Pantangan", ["pemanis", "garam"]));
  const spacer = figma.createFrame();
  spacer.name = "Spacer";
  emptyFills(spacer);
  spacer.resize(350, 20);
  pilih.appendChild(spacer);
  fillX(spacer);
  try {
    spacer.layoutSizingVertical = "FILL";
  } catch (err) {
    spacer.resize(350, 80);
  }
  const count = h("Pilihan");
  count.primaryAxisAlignItems = "SPACE_BETWEEN";
  count.resize(350, 20);
  count.primaryAxisSizingMode = "FIXED";
  count.appendChild(makeText("Pantangan pilihanmu", "Caption", "Muted"));
  count.appendChild(makeText("0 dipilih", "Caption", "Muted"));
  stackIn(pilih, count);
  stackIn(pilih, button(buttons, "Disabled", "Mulai scan", null, icons.arrow));
  const disclaimer = makeText("Dari komposisi, bukan diagnosis.", "Caption", "Muted");
  disclaimer.textAlignHorizontal = "CENTER";
  pilih.appendChild(disclaimer);
  fillX(disclaimer);

  function scanBase(name) {
    const screen = phone(name);
    stackIn(screen, navRow(icons, "BACA KOMPOSISI"));
    screen.appendChild(activeRow(chips, "kacang"));
    const heading = makeText("Foto daftar komposisi di belakang kemasan.", "Title", "Ink");
    heading.textAutoResize = "HEIGHT";
    stackIn(screen, heading);
    fillX(heading);
    stackIn(screen, finder.createInstance());
    return screen;
  }

  const scan = scanBase("02 Baca komposisi");
  stackIn(scan, button(buttons, "Primary", "Pakai kamera", null, icons.camera));
  const contohScan = contohRow(buttons);
  stackIn(scan, contohScan.block);
  fillX(contohScan.ada);
  fillX(contohScan.tanpa);
  fillX(contohScan.bukan);
  const deniedLink = h("Pratinjau ditolak");
  deniedLink.primaryAxisAlignItems = "CENTER";
  deniedLink.appendChild(icons.camOff.createInstance());
  deniedLink.appendChild(makeText("Tunjukkan izin kamera ditolak", "Caption", "Muted"));
  scan.appendChild(deniedLink);
  fillX(deniedLink);

  function resultScreen(name, kind, sentence, ocrLines, fotoTeks, highlights, labels) {
    const screen = phone(name);
    stackIn(screen, navRow(icons, kind === "Loading" ? "BACA KOMPOSISI" : "HASIL KOMPOSISI"));
    screen.appendChild(activeRow(chips, labels));
    stackIn(screen, fotoHasil(foto, fotoTeks));
    if (kind === "Loading") {
      const tunggu = makeText("Membaca komposisi", "Body", "Muted");
      tunggu.textAlignHorizontal = "CENTER";
      stackIn(screen, tunggu);
    } else {
      stackIn(screen, kotakHasil(kind, sentence));
      if (kind !== "Rejected") stackIn(screen, ocrBlock(ocrLines, highlights));
    }
    stackIn(screen, fotoUlang(buttons, icons));
    const contoh = contohRow(buttons);
    stackIn(screen, contoh.block);
    fillX(contoh.ada);
    fillX(contoh.tanpa);
    fillX(contoh.bukan);
    return screen;
  }

  const muat = resultScreen(
    "03 Membaca",
    "Loading",
    "",
    [],
    "SELAI KACANG\nKOMPOSISI\nkacang tanah (arachis hypogaea),\ngula, minyak kelapa",
    [],
    ["kacang", "pemanis"]
  );
  const ada = resultScreen(
    "04 Ada kacang dan pemanis",
    "Found",
    "Tidak aman, mengandung kacang dan pemanis.",
    ["kacang tanah (arachis hypogaea),", "gula, minyak kelapa"],
    "SELAI KACANG\nKOMPOSISI\nkacang tanah (arachis hypogaea),\ngula, minyak kelapa\nINFORMASI NILAI GIZI",
    ["kacang tanah", "arachis hypogaea", "gula"],
    ["kacang", "pemanis"]
  );
  const tanpa = resultScreen(
    "05 Tidak terbaca",
    "Unread",
    "Aman, bisa kamu makan, tidak mengandung kacang dan pemanis.",
    ["air, daun teh,", "bunga melati"],
    "TEH MELATI\nKOMPOSISI\nair, daun teh,\nbunga melati",
    [],
    ["kacang", "pemanis"]
  );
  const ditolak = resultScreen(
    "06 Ditolak",
    "Rejected",
    "Gambar ini bukan daftar komposisi.",
    [],
    "KRIUK\nKeripik Kentang\nRasa Original\nBerat bersih 68 g",
    [],
    ["kacang", "pemanis"]
  );

  const denied = scanBase("07 Kamera ditolak");
  stackIn(denied, banner.createInstance());
  stackIn(denied, button(buttons, "Primary", "Pakai kamera", null, icons.camera));
  const contohDenied = contohRow(buttons);
  stackIn(denied, contohDenied.block);
  fillX(contohDenied.ada);
  fillX(contohDenied.tanpa);
  fillX(contohDenied.bukan);
  const deniedLink2 = h("Pratinjau ditolak");
  deniedLink2.primaryAxisAlignItems = "CENTER";
  deniedLink2.appendChild(icons.camOff.createInstance());
  deniedLink2.appendChild(makeText("Tunjukkan izin kamera ditolak", "Caption", "Muted"));
  denied.appendChild(deniedLink2);
  fillX(deniedLink2);

  const screens = h("Screens");
  screens.itemSpacing = 28;
  screens.counterAxisAlignItems = "MIN";
  for (const screen of [pilih, scan, muat, ada, tanpa, ditolak, denied]) screens.appendChild(screen);

  const board = h("ScanBite");
  board.itemSpacing = 64;
  board.paddingTop = 48;
  board.paddingBottom = 48;
  board.paddingLeft = 48;
  board.paddingRight = 48;
  board.counterAxisAlignItems = "MIN";
  useFill(board, paint.Secondary);
  board.cornerRadius = 24;
  const libWrap = v("Components", 12);
  libWrap.appendChild(makeText("Components", "Title", "Ink"));
  libWrap.appendChild(makeText("Chip, tombol, app bar, viewfinder, status, banner. Layar di kanan memakai instance.", "Body", "Muted"));
  libWrap.appendChild(library);
  const screenWrap = v("Screens", 12);
  screenWrap.appendChild(makeText("Screens", "Title", "Ink"));
  screenWrap.appendChild(screens);
  board.appendChild(libWrap);
  board.appendChild(screenWrap);
  page.appendChild(board);

  page.selection = [chips, buttons];
  figma.viewport.scrollAndZoomIntoView([board]);
  figma.closePlugin("Komponen ScanBite siap");
}

main().catch(function (err) {
  figma.closePlugin((step + " | " + String(err && err.message ? err.message : err)).slice(0, 160));
});
