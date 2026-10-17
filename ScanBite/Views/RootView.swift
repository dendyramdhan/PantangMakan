import AVFoundation
import PhotosUI
import SwiftUI

struct RootView: View {
    @AppStorage("pantangmakan.pilihan") private var tersimpan = ""
    /// Pengguna memilih scan tanpa pantangan; disimpan supaya app langsung ke layar scan.
    @AppStorage("scanbite.tanpaPantangan") private var tanpaPantangan = false
    @State private var pilihan = Set<Pantangan>()
    @State private var selesaiOnboarding = false

    var body: some View {
        Group {
            if selesaiOnboarding {
                ScanView(pilihan: pilihan) {
                    selesaiOnboarding = false
                }
            } else {
                OnboardingView(pilihan: $pilihan) {
                    tersimpan = pilihan.map(\.rawValue).sorted().joined(separator: ",")
                    tanpaPantangan = pilihan.isEmpty
                    selesaiOnboarding = true
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("--aman") {
                pilihan = [.garam]
                selesaiOnboarding = true
                return
            }
            if args.contains("--tanpa") {
                pilihan = []
                selesaiOnboarding = true
                return
            }
            if args.contains("--peringatan") {
                pilihan = [.kacang]
                selesaiOnboarding = true
                return
            }
            if args.contains("--pratinjau") || args.contains("--ditolak") {
                pilihan = [.kacang, .pemanis]
                selesaiOnboarding = true
                return
            }
            if args.contains("--contoh") || args.contains("--contoh-susu") || args.contains("--contoh-teh") {
                pilihan = [.susu]
                selesaiOnboarding = true
                return
            }
            let nilai = Set(tersimpan.split(separator: ",").map { Pantangan(rawValue: String($0)) }.compactMap { $0 })
            pilihan = nilai
            selesaiOnboarding = !nilai.isEmpty || tanpaPantangan
        }
    }
}

struct OnboardingView: View {
    @Binding var pilihan: Set<Pantangan>
    var lanjut: () -> Void

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AppBar(subjudul: true)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Capsule().fill(Color.pantangAccent).frame(width: 18, height: 2)
                            Text("SEBELUM MEMINDAI")
                                .font(.pantangEyebrow)
                                .foregroundStyle(Color.pantangMuted)
                        }
                        Text("Pilih pantangan sebelum scan.")
                            .font(.pantangTitle)
                            .lineSpacing(6)
                            .foregroundStyle(Color.pantangInk)
                        Text("Hasil hanya dari kata yang terbaca di daftar komposisi.")
                            .font(.pantangBody)
                            .foregroundStyle(Color.pantangMuted)
                    }

                    chipGroup("Alergi", Pantangan.allCases.filter { $0.kelompok == "Alergi" })
                    chipGroup("Pantangan", Pantangan.allCases.filter { $0.kelompok == "Pantangan" })

                    Spacer(minLength: 28)

                    HStack {
                        Text("Pantangan pilihanmu")
                        Spacer()
                        Text("\(pilihan.count) dipilih")
                    }
                    .font(.pantangCaption)
                    .foregroundStyle(Color.pantangMuted)

                    PrimaryButton(
                        title: "Mulai scan",
                        systemImage: "arrow.right",
                        imageOnTrailing: true,
                        enabled: !pilihan.isEmpty,
                        action: lanjut
                    )
                    if pilihan.isEmpty {
                        PrimaryButton(title: "Scan tanpa pantangan", outline: true, action: lanjut)
                            .accessibilityHint("Menampilkan alergen umum yang ada di komposisi")
                    }
                    Text("Dari komposisi, bukan diagnosis.")
                        .font(.pantangCaption)
                        .foregroundStyle(Color.pantangMuted)
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
                .frame(minHeight: geo.size.height)
            }
        }
        .background(Color.pantangBg)
    }

    private func chipGroup(_ judul: String, _ items: [Pantangan]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(judul)
                .font(.pantangMeta)
                .foregroundStyle(Color.pantangInk)
            ChipFlow {
                ForEach(items) { item in
                    Button {
                        if pilihan.contains(item) {
                            pilihan.remove(item)
                        } else {
                            pilihan.insert(item)
                        }
                    } label: {
                        PantangChip(title: item.kataDiKalimat, selected: pilihan.contains(item))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ScanView: View {
    let pilihan: Set<Pantangan>
    var gantiPantangan: () -> Void

    @State private var hasil: ScanOutput?
    @State private var sedang = false
    @State private var bukaKamera = false
    @State private var bukaGaleri = false
    @State private var fotoGaleri: PhotosPickerItem?
    @State private var izinDitolak = false
    @State private var bicara = AVSpeechSynthesizer()
    @State private var gambarTerakhir: UIImage?

    private var pilihanUrut: [Pantangan] {
        pilihan.sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AppBar()
                HStack {
                    Button(action: gantiPantangan) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.pantangInk)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text(hasil == nil && !sedang ? "BACA KOMPOSISI" : "HASIL KOMPOSISI")
                        .font(.pantangEyebrow)
                        .foregroundStyle(Color.pantangMuted)
                }

                HStack(spacing: 10) {
                    if pilihan.isEmpty {
                        Text("Tanpa pantangan · cek alergen umum")
                            .font(.pantangBody)
                            .foregroundStyle(Color.pantangMuted)
                        Spacer()
                    } else {
                        ChipFlow {
                            ForEach(pilihanUrut) { item in
                                PantangChip(title: item.kataDiKalimat, selected: false, compact: true)
                            }
                        }
                    }
                    Button("Ubah", action: gantiPantangan)
                        .font(.pantangBody)
                        .foregroundStyle(Color.pantangMuted)
                        .buttonStyle(.plain)
                }

                if let gambarTerakhir {
                    CapturedPhoto(image: gambarTerakhir, ringkas: hasil != nil)
                }

                if sedang {
                    VStack(spacing: 8) {
                        BouncingDots()
                        Text("Membaca komposisi")
                            .font(.pantangBody)
                            .foregroundStyle(Color.pantangAccent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                } else if let hasil {
                    hasilBlok(hasil)
                }

                if gambarTerakhir != nil {
                    if izinDitolak {
                        DeniedBanner(bukaPengaturan: bukaPengaturan)
                    }
                } else if hasil == nil && !sedang {
                    Text("Foto daftar komposisi di belakang kemasan.")
                        .font(.pantangTitle)
                            .lineSpacing(6)
                        .foregroundStyle(Color.pantangInk)
                    Viewfinder()
                    if izinDitolak {
                        DeniedBanner(bukaPengaturan: bukaPengaturan)
                    }
                    PrimaryButton(title: "Pakai kamera", systemImage: "camera", imageOnTrailing: true, action: mintaKamera)
                    PrimaryButton(title: "Pilih dari galeri", systemImage: "photo.on.rectangle", imageOnTrailing: true, outline: true) {
                        bukaGaleri = true
                    }
                }
            }
            .padding(20)
        }
        .background(Color.pantangBg)
        .safeAreaInset(edge: .bottom) {
            if gambarTerakhir != nil && !sedang {
                HStack(spacing: 10) {
                    PrimaryButton(title: "Foto ulang", systemImage: "arrow.clockwise", imageOnTrailing: false, centeredIcon: true, action: mintaKamera)
                    PrimaryButton(title: "Galeri", systemImage: "photo.on.rectangle", imageOnTrailing: false, outline: true) {
                        bukaGaleri = true
                    }
                }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background {
                        Color.pantangBg
                            .ignoresSafeArea(edges: .bottom)
                            .overlay(alignment: .top) { Divider().overlay(Color.pantangLine) }
                    }
            }
        }
        .sheet(isPresented: $bukaKamera) {
            CameraPicker { image in
                Task { await proses(image) }
            }
            .ignoresSafeArea()
        }
        // PhotosPicker berjalan di proses terpisah, jadi tidak perlu izin akses galeri.
        .photosPicker(isPresented: $bukaGaleri, selection: $fotoGaleri, matching: .images)
        .onChange(of: fotoGaleri) { _, item in
            guard let item else { return }
            fotoGaleri = nil
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                await proses(image)
            }
        }
        .onAppear(perform: pratinjauJikaDiminta)
    }

    @ViewBuilder
    private func hasilBlok(_ hasil: ScanOutput) -> some View {
        if hasil.ditolak {
            VStack(alignment: .leading, spacing: 14) {
                Text("Ditolak")
                    .font(.system(size: 44, weight: .regular, design: .serif))
                    .foregroundStyle(Color.pantangInk)
                BukanBahanGambar()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.pantangFinder)
            .overlay {
                RoundedRectangle(cornerRadius: 22).stroke(Color.pantangLine, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        } else {
            let bahaya = hasil.adaBahan
            let warnaTeks = hasil.tanpaPantangan ? Color.pantangInk : (bahaya ? Color.pantangBahaya : Color.pantangAman)
            let warnaLatar = hasil.tanpaPantangan ? Color.pantangKartu : (bahaya ? Color.pantangBahayaLatar : Color.pantangAmanLatar)
            VStack(alignment: .leading, spacing: 12) {
                Text(hasil.kalimat)
                    .font(.pantangTitle)
                    .lineSpacing(6)
                    .foregroundStyle(warnaTeks)
                if let peringatan = hasil.peringatan {
                    Label(peringatan, systemImage: "exclamationmark.triangle")
                        .font(.pantangBody)
                        .foregroundStyle(Color.pantangInk)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.pantangPeringatanLatar)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(warnaLatar)
            .overlay { RoundedRectangle(cornerRadius: 22).stroke(hasil.tanpaPantangan ? Color.pantangLine : .clear, lineWidth: 1) }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }

        if !hasil.ditolak {
            if let penjelasan = hasil.penjelasan {
                KartuBagian(judul: "Kenapa") {
                    Text(penjelasan)
                        .font(.pantangBody)
                        .lineSpacing(3)
                        .foregroundStyle(Color.pantangInk)
                }
            }

            KartuBagian(judul: "Di label") {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        SubJudul("Bahan")
                        if hasil.teks.isEmpty {
                            Text("Tidak ada kalimat bahan yang terbaca.")
                                .font(.pantangCaption)
                                .foregroundStyle(Color.pantangMuted)
                        } else {
                            MarkedComposition(teks: hasil.teks, pilihan: pilihan.isEmpty ? Set(Pantangan.allCases) : pilihan)
                        }
                    }
                    if !hasil.teksPeringatan.isEmpty {
                        Divider().overlay(Color.pantangLine)
                        VStack(alignment: .leading, spacing: 6) {
                            SubJudul("Dapat mengandung")
                            MarkedComposition(teks: hasil.teksPeringatan, pilihan: pilihan.isEmpty ? Set(Pantangan.allCases) : pilihan)
                        }
                    }
                }
            }

            // Bagian teknis paling bawah: peran tiap fitur AI.
            let status = Self.pisahStatus(hasil.statusModel)
            KartuBagian(judul: "Hasil AI", latar: Color.pantangFinder) {
                VStack(alignment: .leading, spacing: 10) {
                    BarisInfo(
                        label: "Kalimat label",
                        nilai: "\(hasil.jumlah[.bahan] ?? 0) bahan · \(hasil.jumlah[.peringatan] ?? 0) peringatan"
                    )
                    BarisInfo(label: "Penjelasan", nilai: "Apple Foundation Models", catatan: [status.0, status.1].compactMap { $0 }.joined(separator: ". "))
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    /// "Bahasa Indonesia (Apple Intelligence …)" jadi ("Bahasa Indonesia", "Apple Intelligence …").
    private static func pisahStatus(_ mentah: String) -> (String, String?) {
        let teks = mentah.prefix(1).uppercased() + mentah.dropFirst()
        guard let buka = teks.firstIndex(of: "("), teks.hasSuffix(")") else { return (teks, nil) }
        let utama = teks[..<buka].trimmingCharacters(in: .whitespaces)
        let catatan = teks[teks.index(after: buka)..<teks.index(before: teks.endIndex)]
        return (utama, String(catatan) + ".")
    }

    private func bukaPengaturan() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func mintaKamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            izinDitolak = false
            bukaKamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { boleh in
                Task { @MainActor in
                    izinDitolak = !boleh
                    bukaKamera = boleh
                }
            }
        default:
            izinDitolak = true
        }
    }

    private func pratinjauJikaDiminta() {
        let args = ProcessInfo.processInfo.arguments
        let ditolak = args.contains("--ditolak")
        let aman = args.contains("--aman")
        let peringatan = args.contains("--peringatan")
        let tanpa = args.contains("--tanpa")
        guard ditolak || aman || peringatan || tanpa || args.contains("--pratinjau") else { return }
        let baris = tanpa
            ? ["BISKUIT SUSU", "KOMPOSISI", "tepung terigu, gula,", "susu bubuk, telur, garam.", "INFORMASI NILAI GIZI"]
            : peringatan
            ? ["WAFER COKELAT", "KOMPOSISI", "tepung terigu, gula,", "susu bubuk, garam.", "Dapat mengandung", "telur dan kacang.", "INFORMASI NILAI GIZI"]
            : ditolak
            ? ["KRIUK", "Keripik Kentang", "Rasa Original", "Berat bersih 68 g"]
            : aman
            ? ["TEH MELATI", "KOMPOSISI", "air, daun teh,", "bunga melati", "INFORMASI NILAI GIZI", "Takaran saji 30 g"]
            : ["SELAI KACANG", "KOMPOSISI", "kacang tanah,", "arachis hypogaea,", "gula, minyak kelapa", "INFORMASI NILAI GIZI", "Takaran saji 30 g"]
        Task { await proses(gambarTeks(baris)) }
    }

    private func gambarTeks(_ baris: [String]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 1000))
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 800, height: 1000))
            let teks = baris.joined(separator: "\n")
            let gaya: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 36, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            teks.draw(in: CGRect(x: 48, y: 80, width: 704, height: 840), withAttributes: gaya)
        }
    }

    private func proses(_ image: UIImage) async {
        gambarTerakhir = image
        hasil = nil
        sedang = true
        let output = await ScanService.scan(image: image, dipilih: pilihan)
        hasil = output
        sedang = false
        print("PANTANG \(output.jumlah) | \(output.kalimat) | \(output.peringatan ?? "-") | \(output.penjelasan ?? "-")")
        ucapkan(output.kalimat)
    }

    private func ucapkan(_ teks: String) {
        bicara.stopSpeaking(at: .immediate)
        let ucapan = AVSpeechUtterance(string: teks)
        ucapan.voice = AVSpeechSynthesisVoice(language: "id-ID")
        ucapan.rate = 0.45
        bicara.speak(ucapan)
    }
}

private struct AppBar: View {
    /// Subjudul hanya tampil di layar pertama.
    var subjudul = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    (Text("ScanBite").foregroundStyle(Color.pantangInk)
                        + Text(".").foregroundStyle(Color.pantangAccent))
                        .font(.system(size: 20, weight: .medium, design: .serif))
                    if subjudul {
                        Text("Scan First, Eat Safer")
                            .font(.pantangCaption)
                            .foregroundStyle(Color.pantangMuted)
                    }
                }
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay { RoundedRectangle(cornerRadius: 8).stroke(Color.pantangLine, lineWidth: 1) }
                    .accessibilityLabel("Logo ScanBite")
            }
            Rectangle().fill(Color.pantangLine).frame(height: 1)
        }
    }
}

private struct PantangChip: View {
    let title: String
    let selected: Bool
    var compact = false

    var body: some View {
        Text(title)
            .font(.system(size: compact ? 12 : 15, weight: .regular))
            .foregroundStyle(selected ? Color.pantangAccent : Color.pantangInk)
            .padding(.horizontal, compact ? 12 : 16)
            .frame(minWidth: compact ? 0 : 76, minHeight: compact ? 28 : 44)
            .background(selected ? Color.pantangBanner : Color.clear)
            .overlay {
                Capsule().stroke(selected ? Color.pantangAccent : Color.pantangChipLine, lineWidth: 1)
            }
            .clipShape(Capsule())
    }
}

/// Semua tombol penuh-lebar memakai bentuk yang sama: tinggi 52, sudut 14, teks dan ikon di tengah.
private struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var imageOnTrailing = true
    var centeredIcon = true
    var enabled = true
    /// Garis tepi tanpa isi, untuk pilihan kedua.
    var outline = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage, !imageOnTrailing {
                    Image(systemName: systemImage)
                }
                Text(title)
                if let systemImage, imageOnTrailing {
                    Image(systemName: systemImage)
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(outline ? Color.pantangInk : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(outline ? Color.clear : (enabled ? Color.pantangInk : Color.pantangButtonOff))
            .overlay {
                if outline {
                    RoundedRectangle(cornerRadius: 14).stroke(Color.pantangChipLine, lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

private struct BouncingDots: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let detik = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { indeks in
                    let siklus = 0.9
                    let t = (detik + Double(indeks) * 0.16).truncatingRemainder(dividingBy: siklus) / siklus
                    let naik = CGFloat(sin(t * .pi))
                    Circle()
                        .fill(Color.pantangAccent)
                        .frame(width: 5, height: 5)
                        .offset(y: -5 * naik)
                }
            }
            .frame(height: 16)
        }
        .accessibilityLabel("Membaca komposisi")
    }
}

private struct BukanBahanGambar: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                VStack(alignment: .leading, spacing: 6) {
                    Text("KEMASAN")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    Text("Rasa original")
                    Text("Berat bersih 68 g")
                }
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(Color.pantangMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(16)
                GeometryReader { geo in
                    Path { path in
                        path.move(to: CGPoint(x: 16, y: geo.size.height - 16))
                        path.addLine(to: CGPoint(x: geo.size.width - 16, y: 16))
                    }
                    .stroke(Color.pantangBahaya, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
            .frame(height: 128)
            .accessibilityLabel("Gambar ini bukan daftar komposisi")
            Text("Gambar ini bukan daftar komposisi.")
                .font(.pantangBody)
                .foregroundStyle(Color.pantangInk)
        }
    }
}

private struct CapturedPhoto: View {
    let image: UIImage
    var ringkas = false

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: ringkas ? 120 : 210)
            .background(Color.pantangFinder)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay { CornerMarks() }
            .accessibilityLabel("Foto daftar komposisi")
    }
}

private struct Viewfinder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.pantangFinder)
            VStack(spacing: 8) {
                Image(systemName: "camera")
                    .font(.system(size: 22, weight: .regular))
                Text("Daftar komposisi")
                    .font(.system(size: 12))
            }
            .foregroundStyle(Color.pantangMuted)
            CornerMarks()
        }
        .frame(height: 207)
    }

}

private struct CornerMarks: View {
    var body: some View {
        ZStack {
            CornerBracket(alignment: .topLeading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            CornerBracket(alignment: .bottomTrailing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .padding(15)
        .allowsHitTesting(false)
    }
}

private struct CornerBracket: View {
    let alignment: Alignment

    var body: some View {
        Path { path in
            switch alignment {
            case .topLeading:
                path.move(to: CGPoint(x: 0, y: 22))
                path.addLine(to: .zero)
                path.addLine(to: CGPoint(x: 22, y: 0))
            default:
                path.move(to: CGPoint(x: 0, y: 22))
                path.addLine(to: CGPoint(x: 22, y: 22))
                path.addLine(to: CGPoint(x: 22, y: 0))
            }
        }
        .stroke(Color.pantangAccent, style: StrokeStyle(lineWidth: 2, lineCap: .square, lineJoin: .miter))
        .frame(width: 22, height: 22)
    }
}

private struct DeniedBanner: View {
    var bukaPengaturan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "camera.slash")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.pantangAccent)
            Text("Kamera ditolak. Buka Pengaturan, izinkan kamera, lalu kembali ke sini.")
                .font(.system(size: 14))
                .foregroundStyle(Color.pantangInk)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: bukaPengaturan) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Buka Pengaturan")
                }
                .font(.pantangMeta)
                .foregroundStyle(Color.pantangAccent)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pantangBanner)
        .overlay(alignment: .leading) {
            Rectangle().fill(Color.pantangAccent).frame(width: 2)
        }
    }
}

/// Kartu putih dengan judul kecil, dipakai untuk semua bagian di bawah hasil.
private struct KartuBagian<Isi: View>: View {
    let judul: String
    var latar: Color = .pantangKartu
    @ViewBuilder var isi: Isi

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(judul.uppercased())
                .font(.pantangEyebrow)
                .tracking(0.6)
                .foregroundStyle(Color.pantangMuted)
            isi
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(latar)
        .overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.pantangLine, lineWidth: 1) }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct SubJudul: View {
    let teks: String
    init(_ teks: String) { self.teks = teks }

    var body: some View {
        Text(teks)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.pantangInk)
    }
}

/// Label di kiri, nilai di kanan; catatan kecil di bawah kalau ada.
private struct BarisInfo: View {
    let label: String
    let nilai: String
    var catatan: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(.pantangCaption)
                .foregroundStyle(Color.pantangMuted)
                .frame(width: 92, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(nilai)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.pantangInk)
                if let catatan, !catatan.isEmpty {
                    Text(catatan)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.pantangMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

/// Satu baris di bagian HASIL AI: nama model di atas, hasilnya di bawah.
private struct BarisAI: View {
    let nama: String
    let hasil: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(nama)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.pantangInk)
            Text(hasil)
                .font(.pantangMeta)
                .foregroundStyle(Color.pantangMuted)
        }
        .padding(.top, 2)
    }
}

private struct MarkedComposition: View {
    let teks: String
    let pilihan: Set<Pantangan>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(baris.enumerated()), id: \.offset) { _, line in
                MarkedLine(line: line, pilihan: pilihan)
            }
        }
    }

    private var baris: [String] {
        teks.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }
}

private struct MarkedLine: View {
    let line: String
    let pilihan: Set<Pantangan>

    /// Satu Text dengan sorotan di dalamnya, supaya baris membungkus per kata
    /// dan tanda koma tidak terlepas ke baris baru.
    var body: some View {
        Text(teksBersorot)
            .font(.system(size: 13, weight: .regular, design: .monospaced))
            .foregroundStyle(Color.pantangInk)
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var teksBersorot: AttributedString {
        var hasil = AttributedString()
        var index = line.startIndex
        for range in IngredientMatch.rentangSorotan(di: line, dipilih: pilihan) where range.lowerBound >= index {
            if index < range.lowerBound {
                hasil += AttributedString(String(line[index..<range.lowerBound]))
            }
            var sorot = AttributedString("\u{00A0}" + String(line[range]) + "\u{00A0}")
            sorot.foregroundColor = Color.pantangBahaya
            sorot.backgroundColor = Color.pantangBahayaLatar
            sorot.font = .system(size: 13, weight: .semibold, design: .monospaced)
            hasil += sorot
            index = range.upperBound
        }
        if index < line.endIndex {
            hasil += AttributedString(String(line[index...]))
        }
        return hasil
    }

    private struct Piece: Identifiable {
        let id = UUID()
        var text: String
        var highlight: Bool
    }

    private var potongan: [Piece] {
        let ranges = IngredientMatch.rentangSorotan(di: line, dipilih: pilihan)
        var hasil: [Piece] = []
        var index = line.startIndex
        for range in ranges where range.lowerBound >= index {
            if index < range.lowerBound {
                hasil.append(contentsOf: kata(String(line[index..<range.lowerBound]), highlight: false))
            }
            hasil.append(Piece(text: String(line[range]), highlight: true))
            index = range.upperBound
        }
        if index < line.endIndex {
            hasil.append(contentsOf: kata(String(line[index...]), highlight: false))
        }
        if hasil.isEmpty {
            hasil.append(Piece(text: " ", highlight: false))
        }
        return hasil
    }

    private func kata(_ teks: String, highlight: Bool) -> [Piece] {
        teks.split(separator: " ", omittingEmptySubsequences: true).map {
            Piece(text: String($0), highlight: highlight)
        }
    }
}

private struct MarkWrap: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        let rows = rows(width: width, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: max(height, 1))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for item in row.items {
                item.view.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func rows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if current.width + size.width > width, !current.items.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.items.append(Item(view: subview, size: size))
            current.width += size.width + spacing
            current.height = max(current.height, size.height)
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }

    private struct Item {
        var view: LayoutSubview
        var size: CGSize
    }

    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

private struct ChipFlow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 350
        let rows = rows(width: width, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height } + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for item in row.items {
                item.view.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func rows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if current.width + size.width > width, !current.items.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.items.append(Item(view: subview, size: size))
            current.width += size.width + spacing
            current.height = max(current.height, size.height)
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }

    private struct Item {
        var view: LayoutSubview
        var size: CGSize
    }

    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

private extension Color {
    static let pantangBg = Color(red: 0.976, green: 0.965, blue: 0.945)
    static let pantangInk = Color(red: 0.169, green: 0.169, blue: 0.157)
    static let pantangMuted = Color(red: 0.431, green: 0.420, blue: 0.396)
    static let pantangAccent = Color(red: 0.722, green: 0.353, blue: 0.235)
    static let pantangAman = Color(red: 0.13, green: 0.45, blue: 0.27)
    static let pantangAmanLatar = Color(red: 0.89, green: 0.96, blue: 0.91)
    static let pantangBahaya = Color(red: 0.73, green: 0.16, blue: 0.16)
    static let pantangBahayaLatar = Color(red: 0.99, green: 0.90, blue: 0.90)
    static let pantangKartu = Color(red: 1.0, green: 0.988, blue: 0.973)
    static let pantangPeringatanLatar = Color(red: 0.99, green: 0.94, blue: 0.80)
    static let pantangLine = Color(red: 0.894, green: 0.878, blue: 0.847)
    static let pantangChipLine = Color(red: 0.835, green: 0.827, blue: 0.808)
    static let pantangButtonOff = Color(red: 0.612, green: 0.608, blue: 0.588)
    static let pantangFinder = Color(red: 0.933, green: 0.925, blue: 0.894)
    static let pantangBanner = Color(red: 0.965, green: 0.890, blue: 0.863)
}

private extension Font {
    static let pantangTitle = Font.system(size: 30, weight: .regular, design: .serif)
    static let pantangBody = Font.system(size: 15, weight: .regular)
    static let pantangMeta = Font.system(size: 14, weight: .medium)
    static let pantangCaption = Font.system(size: 13, weight: .regular)
    static let pantangEyebrow = Font.system(size: 11, weight: .medium)
}
