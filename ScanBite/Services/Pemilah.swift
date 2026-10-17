import Foundation
import NaturalLanguage

/// Jenis kalimat di label kemasan, hasil model Create ML `PemilahKalimat`.
enum JenisKalimat: String {
    /// Daftar bahan atau pernyataan "mengandung". Dipakai untuk kartu merah/hijau.
    case bahan
    /// "Dapat mengandung", "diproduksi dengan peralatan yang juga memproses". Jadi peringatan terpisah.
    case peringatan
    /// Gizi, alamat, cara penyajian, "lihat daftar bahan yang dicetak tebal". Diabaikan.
    case lain
}

struct KalimatLabel: Equatable {
    let teks: String
    let jenis: JenisKalimat
    /// Keyakinan model untuk label teratas (0–1). 1 kalau model tidak dimuat.
    var yakin: Double = 1
}

/// Memotong teks OCR menjadi kalimat, lalu memberi jenis tiap kalimat dengan model Create ML.
/// Aturan potongnya sama dengan `dataset/seg.py`, supaya data latih dan app melihat potongan yang sama.
enum Pemilah {
    /// Potong sebelum frasa pembuka yang biasa muncul di label, misalnya "Dapat mengandung".
    private static let penanda = try! NSRegularExpression(
        pattern: #"(?=\b(?:dapat mengandung|mungkin mengandung|bisa mengandung|may (?:also )?contain|diproduksi (?:menggunakan|di|pada|dengan)|diproses (?:di|dengan|pada)|informasi nilai gizi|nutrition facts|informasi alergen|allergen information|mengandung alergen|ingredients?\b|komposisi|takaran saji|saran penyajian|cara penyajian|diproduksi oleh|layanan konsumen)\b)"#,
        options: [.caseInsensitive]
    )
    /// Titik di luar angka (3.7% tidak terpotong), titik koma, bullet, atau tanda hubung berspasi.
    private static let pemisah = try! NSRegularExpression(
        pattern: #"\||(?<!\d)\.(?!\d)|;|•|·|\s[-–]\s|(?:^|\s)\*(?=\S)"#
    )
    private static let pinggir = CharacterSet(charactersIn: " ,:-*").union(.whitespacesAndNewlines)

    static func potong(_ teks: String) -> [String] {
        var gabung = teks
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: " ")
        gabung = gabung.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        let utuh = NSRange(gabung.startIndex..., in: gabung)
        gabung = penanda.stringByReplacingMatches(in: gabung, range: utuh, withTemplate: "|")

        var hasil: [String] = []
        var awal = gabung.startIndex
        let semua = NSRange(gabung.startIndex..., in: gabung)
        for cocok in pemisah.matches(in: gabung, range: semua) {
            guard let r = Range(cocok.range, in: gabung) else { continue }
            hasil.append(String(gabung[awal..<r.lowerBound]))
            awal = r.upperBound
        }
        hasil.append(String(gabung[awal...]))
        return hasil
            .map { $0.trimmingCharacters(in: pinggir) }
            .filter { $0.count >= 4 }
    }

    /// Kalimat peringatan selalu punya penanda seperti ini. Tanpa penanda, tebakan "peringatan"
    /// tidak dipercaya, supaya bahan pantangan tidak pernah tersembunyi sebagai peringatan.
    private static let penandaPeringatan = try! NSRegularExpression(
        pattern: #"dapat|mungkin|bisa mengandung|may|might|can contain|trace|jejak|diproduksi|diproses|dibuat (?:di|pada|dengan)|produced|manufactured|processed|made (?:in|on)|fasilitas|facility|peralatan|equipment|memproses|processes|shared"#,
        options: [.caseInsensitive]
    )

    /// Di bawah angka ini model dianggap ragu, dan kalimat diperlakukan sebagai bahan.
    static let ambangYakin = 0.6

    /// Aturan memakai hasil model (urutannya penting):
    /// 1. Tanpa model, semua kalimat dianggap bahan.
    /// 2. Label teratas dipakai kalau keyakinannya >= 60%.
    /// 3. Kalau ragu (< 60%), kalimat dianggap bahan: lebih baik pantangan ikut dicek
    ///    daripada terlewat. Kalimat "lain" yang tidak memuat nama pantangan tidak mengubah hasil.
    /// 4. "Peringatan" hanya diterima kalau ada penanda seperti "dapat", "may", "diproduksi".
    static func pilah(_ teks: String, model: NLModel?) -> [KalimatLabel] {
        potong(teks).map { kalimat in
            guard let model else { return KalimatLabel(teks: kalimat, jenis: .bahan) }
            let tebakan = model.predictedLabelHypotheses(for: kalimat, maximumCount: 3)
            guard let teratas = tebakan.max(by: { $0.value < $1.value }),
                  var label = JenisKalimat(rawValue: teratas.key) else {
                return KalimatLabel(teks: kalimat, jenis: .bahan)
            }
            if teratas.value < ambangYakin {
                label = .bahan
            }
            let rentang = NSRange(kalimat.startIndex..., in: kalimat)
            if label == .peringatan && penandaPeringatan.firstMatch(in: kalimat, range: rentang) == nil {
                label = .bahan
            }
            return KalimatLabel(teks: kalimat, jenis: label, yakin: teratas.value)
        }
    }
}
