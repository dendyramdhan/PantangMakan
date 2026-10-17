import CoreML
import Foundation
import FoundationModels
import NaturalLanguage
import UIKit
import Vision

struct ScanOutput: Equatable {
    /// Kalimat yang dipilah Create ML sebagai bahan. Ini yang dicocokkan dengan pantangan.
    var teks: String
    /// Kalimat "dapat mengandung" dan sejenisnya, ditampilkan terpisah.
    var teksPeringatan: String
    var kalimat: String
    /// Pantangan yang hanya disebut di kalimat peringatan, misalnya "Dapat mengandung kacang".
    var peringatan: String?
    /// Penjelasan dari Foundation Models. Nil kalau Apple Intelligence tidak tersedia.
    var penjelasan: String?
    /// Status Foundation Models untuk bagian HASIL AI, termasuk alasan kalau gagal.
    var statusModel: String
    var jumlah: [JenisKalimat: Int]
    /// Semua kalimat hasil pilahan, urut seperti di label, untuk rincian di HASIL AI.
    var kalimatDipilah: [KalimatLabel]
    var adaBahan: Bool
    /// Scan tanpa pantangan: semua alergen umum dicek, kartu netral, bukan merah/hijau.
    var tanpaPantangan: Bool = false
    var ditolak: Bool

    static let tolak = ScanOutput(
        teks: "", teksPeringatan: "",
        kalimat: "Ditolak. Gambar ini bukan daftar komposisi.",
        peringatan: nil, penjelasan: nil, statusModel: "", jumlah: [:], kalimatDipilah: [], adaBahan: false, ditolak: true
    )
}

enum ScanService {
    /// Model Create ML hasil latihan di `dataset/latih.swift`.
    private static let pemilah: NLModel? = {
        guard let ml = try? PemilahKalimat(configuration: MLModelConfiguration()).model else { return nil }
        return try? NLModel(mlModel: ml)
    }()

    static func scan(image: UIImage, dipilih: Set<Pantangan>) async -> ScanOutput {
        let ocr = recognizeText(in: image)
        guard !ocr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let komposisi = IngredientMatch.bagianKomposisi(ocr) else {
            return .tolak
        }

        // 1. Create ML memilah tiap kalimat: bahan, peringatan, atau lain.
        let kalimat = Pemilah.pilah(komposisi, model: pemilah)
        let teksBahan = kalimat.filter { $0.jenis == .bahan }.map(\.teks).joined(separator: "\n")
        let teksPeringatan = kalimat.filter { $0.jenis == .peringatan }.map(\.teks).joined(separator: "\n")
        var jumlah: [JenisKalimat: Int] = [:]
        for k in kalimat { jumlah[k.jenis, default: 0] += 1 }

        // 2. Daftar kata mencocokkan pantangan hanya di kalimat bahan.
        //    Tanpa pantangan: keenam alergen dan pantangan umum dicek.
        let tanpa = dipilih.isEmpty
        let dicek = tanpa ? Set(Pantangan.allCases) : dipilih
        var matched = IngredientMatch.kalimat(ocr: teksBahan, dipilih: dicek)
        if tanpa {
            matched.kalimat = matched.hits.isEmpty
                ? "Tidak ada alergen umum di komposisi ini."
                : "Komposisi ini memuat \(IngredientMatch.gabungNama(matched.hits.map(\.kataDiKalimat)))."
        }
        let mungkin = IngredientMatch.kalimat(ocr: teksPeringatan, dipilih: dicek).hits
            .filter { !matched.hits.contains($0) }
        let peringatan = mungkin.isEmpty
            ? nil
            : "Label juga menulis dapat mengandung \(IngredientMatch.gabungNama(mungkin.map(\.kataDiKalimat)))."

        // 3. Foundation Models menjelaskan efek pantangan yang terbaca bagi pemakainya.
        let (penjelasan, statusModel) = await jelaskan(
            hits: matched.hits, mungkin: mungkin,
            teksBahan: teksBahan, teksPeringatan: teksPeringatan
        )

        return ScanOutput(
            teks: teksBahan,
            teksPeringatan: teksPeringatan,
            kalimat: matched.kalimat,
            peringatan: peringatan,
            penjelasan: penjelasan,
            statusModel: statusModel,
            jumlah: jumlah,
            kalimatDipilah: kalimat,
            adaBahan: !matched.hits.isEmpty,
            tanpaPantangan: tanpa,
            ditolak: false
        )
    }

    private static func jelaskan(
        hits: [Pantangan], mungkin: [Pantangan],
        teksBahan: String, teksPeringatan: String
    ) async -> (String?, String) {
        guard !(hits.isEmpty && mungkin.isEmpty) else {
            return (nil, "Tidak dipakai (Tidak ada pantangan untuk dijelaskan)")
        }
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            return (nil, "tidak tersedia, iPhone tidak mendukung Apple Intelligence")
        case .unavailable(.appleIntelligenceNotEnabled):
            return (nil, "tidak tersedia, Apple Intelligence belum dinyalakan")
        case .unavailable(.modelNotReady):
            return (nil, "tidak tersedia, model masih diunduh")
        case .unavailable(let alasan):
            return (nil, "tidak tersedia, \(alasan)")
        }
        if !model.supportsLocale() {
            return (nil, "bahasa iPhone (\(Locale.current.identifier)) tidak didukung")
        }
        // Satu fakta per pantangan: kata di label plus efeknya. Efek diambil dari Pantangan.efek,
        // bukan dikarang model; model hanya merangkai kalimatnya.
        var faktaID: [String] = []
        var faktaEN: [String] = []
        for p in hits {
            let kata = IngredientMatch.kataCocok(p, di: teksBahan).joined(separator: ", ")
            faktaID.append("\(p.kataDiKalimat) ada di daftar bahan, tertulis: \(kata). Efek: \(p.efek)")
            faktaEN.append("\(p.namaInggris) is in the ingredient list, written on the label as: \(kata). Effect: \(p.efekInggris)")
        }
        for p in mungkin {
            let sisaID = p.kelompok == "Alergi" ? ", sisa kecil pun bisa memicu reaksi pada orang yang alergi berat" : ""
            let sisaEN = p.kelompok == "Alergi" ? ", and even small traces can trigger a reaction in people with a severe allergy" : ""
            faktaID.append("\(p.kataDiKalimat) hanya ada di kalimat dapat mengandung. Efek: \(p.efek)\(sisaID)")
            faktaEN.append("\(p.namaInggris) only appears in a may-contain statement. Effect: \(p.efekInggris)\(sisaEN)")
        }
        let maks = min(3, hits.count + mungkin.count)
        let diagnosa = Self.diagnosaBahasa(model)
        print("PANTANG FM diagnosa: \(diagnosa)")
        let boleh = Set(hits + mungkin)

        // Coba bahasa Indonesia dulu. Di iPhone fisik, Foundation Models menolak teks Indonesia
        // ("unsupported language or locale"), jadi ulangi dalam bahasa Inggris.
        let sessionID = LanguageModelSession(instructions: """
        Kamu memberi tahu efek bahan di label kemasan makanan, dalam bahasa Indonesia, untuk orang yang punya pantangan makan.
        Tulis satu kalimat pendek untuk setiap fakta, paling banyak tiga kalimat.
        Sebut kata yang tertulis di label, lalu efeknya. Pakai efek yang ada di fakta saja, jangan menambah gejala lain.
        Kalau kata di label sama dengan nama bahannya, jangan menulis "berasal dari", langsung tulis efeknya.
        Jangan memakai kata aman. Jangan memberi saran medis, obat, atau dosis. Jangan menyebut bahan yang tidak ada di fakta.

        Contoh fakta: susu ada di daftar bahan, tertulis: whey bubuk. Efek: pada orang alergi susu bisa memicu gatal, ruam, muntah, sampai sesak napas
        Contoh jawaban: Whey bubuk berasal dari susu, dan pada orang alergi susu bisa memicu gatal, ruam, muntah, sampai sesak napas.
        Contoh fakta: telur hanya ada di kalimat dapat mengandung. Efek: pada orang alergi telur bisa memicu ruam, gatal, muntah, sampai sesak napas, sisa kecil pun bisa memicu reaksi pada orang yang alergi berat
        Contoh jawaban: Sisa telur dari pabrik pun bisa memicu ruam atau sesak napas pada orang yang alergi telur berat.
        """)
        do {
            let reply = try await sessionID.respond(to: "Fakta:\n" + faktaID.joined(separator: "\n")).content
            guard let teks = diterima(reply, boleh: boleh, maksKalimat: maks, inggris: false) else {
                print("PANTANG FM ditolak: \(reply)")
                return (nil, "jawaban ditolak pengecek")
            }
            return (teks, "Bahasa Indonesia (Apple Intelligence di iOS \(UIDevice.current.systemVersion) mendukung bahasa Indonesia)")
        } catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
            print("PANTANG FM: bahasa Indonesia ditolak, coba bahasa Inggris")
        } catch {
            print("PANTANG FM error: \(error)")
            return (nil, "gagal, \(error.localizedDescription)")
        }

        let sessionEN = LanguageModelSession(instructions: """
        You tell people who avoid certain foods what an ingredient on a food label can do to them.
        Write one short sentence per fact, at most three sentences, in plain English.
        Name the word written on the label, then its effect. Use only the effect given in the fact, do not add other symptoms.
        If the label word is the same as the ingredient name, do not write "comes from", just state the effect.
        Do not use the word safe. Do not give medical advice, medicine, or doses. Do not mention ingredients that are not in the facts.

        Example fact: milk is in the ingredient list, written on the label as: whey bubuk. Effect: in people with a milk allergy it can trigger itching, hives, vomiting, or trouble breathing
        Example answer: Whey bubuk comes from milk, and in people with a milk allergy it can trigger itching, hives, vomiting, or trouble breathing.
        Example fact: egg only appears in a may-contain statement. Effect: in people with an egg allergy it can trigger hives, itching, vomiting, or trouble breathing, and even small traces can trigger a reaction in people with a severe allergy
        Example answer: Even traces of egg from the factory can trigger hives or trouble breathing in people with a severe egg allergy.
        """)
        do {
            let reply = try await sessionEN.respond(to: "Facts:\n" + faktaEN.joined(separator: "\n")).content
            guard let teks = diterima(reply, boleh: boleh, maksKalimat: maks, inggris: true) else {
                print("PANTANG FM ditolak (EN): \(reply)")
                return (nil, "jawaban ditolak pengecek")
            }
            return (teks, "Bahasa Inggris (Apple Intelligence di iOS \(UIDevice.current.systemVersion) belum mendukung bahasa Indonesia)")
        } catch {
            print("PANTANG FM error (EN): \(error)")
            return (nil, "gagal, \(error.localizedDescription)")
        }
    }

    /// Ringkasan untuk mencari tahu kenapa bahasa Indonesia diterima di satu iPhone dan ditolak di iPhone lain.
    private static func diagnosaBahasa(_ model: SystemLanguageModel) -> String {
        let indo = model.supportsLocale(Locale(identifier: "id_ID")) ? "ya" : "tidak"
        let region = Locale.current.region?.identifier ?? "?"
        let bahasa = model.supportedLanguages
            .compactMap { $0.languageCode?.identifier }
            .sorted()
            .joined(separator: ",")
        return "Indonesia didukung: \(indo), region \(region), bahasa model: \(bahasa)"
    }

    /// Penjelasan ditolak kalau memakai kata "aman", terlalu panjang, atau menyebut pantangan lain.
    /// Hanya kalimat sebanyak kata yang dijelaskan yang dipakai; sisanya biasanya mengulang.
    private static func diterima(_ mentah: String, boleh: Set<Pantangan>, maksKalimat: Int, inggris: Bool) -> String? {
        let rapi = mentah
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        let potong = rapi.components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: " .")) }
            .filter { !$0.isEmpty }
            .prefix(maksKalimat)
        let teks = potong.map { $0 + "." }.joined(separator: " ")
        let lower = teks.lowercased()
        // Kata utuh saja: "tanaman" dan "keamanan pangan" tidak boleh ikut tertolak karena memuat "aman".
        let kataLarang = inggris ? #"\bsafe(ly|r|st)?\b"# : #"\baman\b"#
        guard !teks.isEmpty, teks.count <= 450,
              lower.range(of: kataLarang, options: .regularExpression) == nil else { return nil }
        for p in Pantangan.allCases where !boleh.contains(p)
            && lower.range(of: "\\b\(inggris ? p.namaInggris : p.kataDiKalimat)\\b", options: .regularExpression) != nil {
            return nil
        }
        return teks
    }

    private static func recognizeText(in image: UIImage) -> String {
        guard let cgImage = image.cgImage else { return "" }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["id-ID", "en-US"]
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation(image.imageOrientation))
        try? handler.perform([request])
        let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
        return lines.joined(separator: "\n")
    }

    private static func cgOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
