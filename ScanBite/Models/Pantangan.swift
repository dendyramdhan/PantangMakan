import Foundation

enum Pantangan: String, CaseIterable, Identifiable, Codable {
    case susu
    case kacang
    case telur
    case gluten
    case pemanis
    case garam

    var id: String { rawValue }

    var judul: String {
        switch self {
        case .susu: return "Alergi susu"
        case .kacang: return "Alergi kacang"
        case .telur: return "Alergi telur"
        case .gluten: return "Alergi gluten"
        case .pemanis: return "Hindari pemanis"
        case .garam: return "Hindari garam"
        }
    }

    var kelompok: String {
        switch self {
        case .susu, .kacang, .telur, .gluten: return "Alergi"
        case .pemanis, .garam: return "Pantangan"
        }
    }

    var kataDiKalimat: String {
        switch self {
        case .susu: return "susu"
        case .kacang: return "kacang"
        case .telur: return "telur"
        case .gluten: return "gluten"
        case .pemanis: return "pemanis"
        case .garam: return "garam"
        }
    }

    /// Nama untuk prompt dan pengecek Foundation Models versi bahasa Inggris.
    var namaInggris: String {
        switch self {
        case .susu: return "milk"
        case .kacang: return "nut"
        case .telur: return "egg"
        case .gluten: return "gluten"
        case .pemanis: return "sweetener"
        case .garam: return "salt"
        }
    }

    /// Nama di label Indonesia, Inggris, dan nama kimia/INCI. Dicocokkan utuh, bukan potongan kata.
    var frasa: [String] {
        switch self {
        case .susu:
            return [
                "susu bubuk", "susu skim", "susu full cream", "full cream milk", "krim susu",
                "sodium caseinate", "calcium caseinate", "beta lactoglobulin", "beta laktoglobulin",
                "milk fat", "milkfat",
                "susu", "krim", "mentega", "keju", "whey", "yoghurt", "yogurt", "ghee", "dadih",
                "milk", "buttermilk", "cream", "cheese", "lactose", "laktosa",
                "lactalbumin", "lactoglobulin", "kasein", "casein", "kaseinat", "caseinate"
            ]
        case .kacang:
            return [
                "kacang tanah", "kacang mede", "kacang mete", "kacang kenari", "kacang almond",
                "selai kacang", "minyak arachis", "arachis oil", "arachis hypogaea",
                "ground nut", "brazil nut", "pine nut", "pine nuts",
                "kacang", "peanut", "peanuts", "groundnut", "arachis",
                "almond", "almonds", "amygdalus", "cashew", "cashews", "anacardium",
                "walnut", "walnuts", "juglans", "hazelnut", "hazelnuts", "corylus",
                "pistachio", "pistachios", "pistacia", "pecan", "pecans", "macadamia",
                "bertholletia", "praline", "marzipan"
            ]
        case .telur:
            return [
                "putih telur", "kuning telur", "egg white", "egg yolk", "dried egg",
                "telur", "egg", "eggs", "albumen", "albumin", "ovalbumin", "ovomucoid",
                "ovomucin", "lysozyme", "livetin", "e1105", "mayones", "mayonnaise"
            ]
        case .gluten:
            return [
                "tepung terigu", "wheat flour", "wheat starch", "hydrolyzed wheat protein",
                "triticum vulgare", "triticum aestivum", "hordeum vulgare", "secale cereale",
                "gandum hitam",
                "gluten", "terigu", "gandum", "jelai", "wheat", "barley", "rye", "malt",
                "triticale", "spelt", "semolina", "durum", "bulgur", "couscous", "seitan", "farina",
                "triticum", "hordeum", "secale"
            ]
        case .pemanis:
            return [
                "gula pasir", "high fructose corn syrup", "corn syrup", "sirup jagung",
                "gula", "madu", "honey", "sirup", "syrup", "sugar", "pemanis",
                "sukrosa", "sucrose", "fruktosa", "fructose", "glukosa", "glucose",
                "dekstrosa", "dextrose", "aspartam", "aspartame", "e951",
                "sakarin", "saccharin", "e954", "sukralosa", "sucralose", "e955",
                "asesulfam", "acesulfame", "e950", "siklamat", "cyclamate", "e952",
                "stevia", "steviol", "e960", "sorbitol", "e420", "maltitol", "xylitol",
                "manitol", "mannitol"
            ]
        case .garam:
            return [
                "garam dapur", "garam laut", "sea salt", "table salt", "sodium chloride",
                "natrium klorida", "monosodium glutamate", "mononatrium glutamat",
                "disodium inosinate", "disodium guanylate", "penguat rasa",
                "garam", "salt", "nacl", "msg", "vetsin", "e621", "e627", "e631"
            ]
        }
    }
}

enum IngredientMatch {
    /// Bahan yang tulisannya mirip, tetapi bukan pantangan yang dipilih.
    private static let bukanPantangan = [
        "susu kedelai", "soy milk", "coconut milk", "air kelapa",
        "cocoa butter", "cacao butter", "shea butter", "lemak kakao", "mentega kakao",
        "kacang kedelai", "soy bean", "soy beans", "soybean", "soya bean",
        "sodium benzoate", "natrium benzoat", "sodium bicarbonate", "natrium bikarbonat",
        "baking soda"
    ]

    /// Hanya isi di bawah judul daftar komposisi. Nil berarti judul itu tidak ada di foto.
    static func bagianKomposisi(_ ocr: String) -> String? {
        let baris = ocr
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let mulai = [
            "komposisi", "ingredients", "ingredient", "daftar komposisi",
            "daftar bahan", "bahan bahan", "bahan-bahan", "composition"
        ]
        let berhenti = [
            "informasi nilai gizi", "nilai gizi", "nutrition facts", "nutrition information",
            "nutrition", "cara penyimpanan", "cara penyajian", "saran penyajian",
            "saran penyimpanan", "petunjuk penyimpanan", "diproduksi oleh", "produced by",
            "berat bersih", "net weight", "baik digunakan sebelum", "customer service"
        ]
        guard let indeks = baris.firstIndex(where: { barisDiawali($0, judul: mulai) }) else { return nil }
        var dipakai: [String] = []
        var pertama = true
        for barisIni in baris[indeks...] {
            if pertama {
                pertama = false
                let sisa = sisaSetelahJudul(barisIni, judul: mulai)
                if !sisa.isEmpty { dipakai.append(sisa) }
                continue
            }
            if barisDiawali(barisIni, judul: berhenti) { break }
            dipakai.append(barisIni)
        }
        guard !dipakai.isEmpty else { return nil }
        return dipakai.joined(separator: "\n")
    }

    /// Judul "KOMPOSISI" sendiri tidak ikut. Sisa di baris yang sama, misalnya "susu bubuk", ikut.
    private static func sisaSetelahJudul(_ baris: String, judul daftar: [String]) -> String {
        let trimmed = baris.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        for judul in daftar.sorted(by: { $0.count > $1.count }) {
            guard lower.hasPrefix(judul) else { continue }
            let after = trimmed.index(trimmed.startIndex, offsetBy: judul.count)
            var sisa = trimmed[after...].trimmingCharacters(in: .whitespaces)
            while sisa.first == ":" || sisa.first == "-" {
                sisa = sisa.dropFirst().trimmingCharacters(in: .whitespaces)
            }
            return String(sisa)
        }
        return trimmed
    }

    private static func barisDiawali(_ baris: String, judul daftar: [String]) -> Bool {
        let teks = baris
            .lowercased()
            .replacingOccurrences(of: ":", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .joined(separator: " ")
        return daftar.contains { judul in
            teks == judul || teks.hasPrefix(judul + " ")
        }
    }

    static func rentangSorotan(di teks: String, dipilih: Set<Pantangan>) -> [Range<String.Index>] {
        let letak = letakToken(teks)
        let kata = letak.map(\.teks)
        guard !kata.isEmpty else { return [] }
        let terhalang = indeksTerhalang(kata)
        var calon: [(Int, Range<String.Index>)] = []
        for pantangan in Pantangan.allCases where dipilih.contains(pantangan) {
            let daftar = pantangan.frasa.map(tokenize).sorted { $0.count > $1.count }
            for frase in daftar where !frase.isEmpty && frase.count <= kata.count {
                for awal in 0...(kata.count - frase.count) {
                    let jendela = Array(kata[awal..<(awal + frase.count)])
                    guard jendela == frase else { continue }
                    let kenaBlok = (0..<frase.count).contains { terhalang.contains(awal + $0) }
                    if kenaBlok { continue }
                    let range = letak[awal].range.lowerBound..<letak[awal + frase.count - 1].range.upperBound
                    calon.append((frase.count, range))
                }
            }
            guard pantangan == .susu else { continue }
            for (index, token) in kata.enumerated() where token == "butter" || token == "mentega" {
                if terhalang.contains(index) { continue }
                if index > 0, sebelumButterBukanSusu.contains(kata[index - 1]) { continue }
                calon.append((1, letak[index].range))
            }
        }
        return gabung(calon.map(\.1))
    }

    private static func gabung(_ ranges: [Range<String.Index>]) -> [Range<String.Index>] {
        let urut = ranges.sorted { $0.lowerBound < $1.lowerBound }
        var hasil: [Range<String.Index>] = []
        for range in urut {
            if let terakhir = hasil.last, terakhir.upperBound >= range.lowerBound {
                let akhir = terakhir.upperBound > range.upperBound ? terakhir.upperBound : range.upperBound
                hasil[hasil.count - 1] = terakhir.lowerBound..<akhir
            } else {
                hasil.append(range)
            }
        }
        return hasil
    }

    private struct LetakToken {
        var teks: String
        var range: Range<String.Index>
    }

    private static func letakToken(_ text: String) -> [LetakToken] {
        var hasil: [LetakToken] = []
        var indeks = text.startIndex
        while indeks < text.endIndex {
            if text[indeks].isLetter || text[indeks].isNumber {
                let awal = indeks
                while indeks < text.endIndex, text[indeks].isLetter || text[indeks].isNumber {
                    indeks = text.index(after: indeks)
                }
                hasil.append(LetakToken(teks: text[awal..<indeks].lowercased(), range: awal..<indeks))
            } else {
                indeks = text.index(after: indeks)
            }
        }
        return hasil
    }

    /// Kata di teks yang membuat pantangan ini cocok, misalnya "arachis hypogaea" untuk kacang.
    static func kataCocok(_ pantangan: Pantangan, di teks: String) -> [String] {
        var hasil: [String] = []
        for r in rentangSorotan(di: teks, dipilih: [pantangan]) {
            let kata = teks[r].lowercased()
            if !hasil.contains(kata) { hasil.append(kata) }
        }
        return hasil
    }

    static func kalimat(ocr: String, dipilih: Set<Pantangan>) -> (hits: [Pantangan], kalimat: String) {
        let tokens = tokenize(ocr)
        if tokens.isEmpty {
            return ([], kalimatAman(dipilih))
        }
        let terhalang = indeksTerhalang(tokens)
        let hits = Pantangan.allCases.filter { pantangan in
            dipilih.contains(pantangan) && cocok(pantangan, tokens: tokens, terhalang: terhalang)
        }
        if hits.isEmpty {
            return ([], kalimatAman(dipilih))
        }
        let daftar = gabungNama(hits.map(\.kataDiKalimat))
        return (hits, "Ada \(daftar) di komposisi ini.")
    }

    static func gabungNama(_ nama: [String]) -> String {
        switch nama.count {
        case 0: return ""
        case 1: return nama[0]
        case 2: return "\(nama[0]) dan \(nama[1])"
        default:
            let awal = nama.dropLast().joined(separator: ", ")
            return "\(awal), dan \(nama[nama.count - 1])"
        }
    }

    private static let sebelumButterBukanSusu: Set<String> = [
        "cocoa", "cacao", "kakao", "shea", "peanut", "almond", "kacang", "nut", "nuts"
    ]

    private static func cocok(_ pantangan: Pantangan, tokens: [String], terhalang: Set<Int>) -> Bool {
        if pantangan.frasa.contains(where: { memuat(tokenize($0), di: tokens, terhalang: terhalang) }) {
            return true
        }
        guard pantangan == .susu else { return false }
        return tokens.enumerated().contains { index, token in
            guard token == "butter" || token == "mentega" else { return false }
            if terhalang.contains(index) { return false }
            if index > 0 && sebelumButterBukanSusu.contains(tokens[index - 1]) { return false }
            return true
        }
    }

    private static func memuat(_ frasa: [String], di tokens: [String], terhalang: Set<Int>) -> Bool {
        guard !frasa.isEmpty, frasa.count <= tokens.count else { return false }
        for awal in 0...(tokens.count - frasa.count) {
            let jendela = Array(tokens[awal..<(awal + frasa.count)])
            guard jendela == frasa else { continue }
            let kenaBlok = (0..<frasa.count).contains { terhalang.contains(awal + $0) }
            if !kenaBlok { return true }
        }
        return false
    }

    private static func indeksTerhalang(_ tokens: [String]) -> Set<Int> {
        var hasil = Set<Int>()
        for frase in bukanPantangan.map(tokenize) where !frase.isEmpty && frase.count <= tokens.count {
            for awal in 0...(tokens.count - frase.count) {
                let jendela = Array(tokens[awal..<(awal + frase.count)])
                if jendela == frase {
                    for offset in 0..<frase.count { hasil.insert(awal + offset) }
                }
            }
        }
        return hasil
    }

    private static func tokenize(_ text: String) -> [String] {
        let huruf = text.lowercased().map { karakter -> Character in
            if karakter.isLetter || karakter.isNumber { return karakter }
            return " "
        }
        return String(huruf).split(separator: " ").map(String.init)
    }

    private static func kalimatAman(_ dipilih: Set<Pantangan>) -> String {
        let daftar = gabungNama(dipilih.sorted { $0.rawValue < $1.rawValue }.map(\.kataDiKalimat))
        return "Tidak ditemukan \(daftar) di komposisi ini."
    }
}
