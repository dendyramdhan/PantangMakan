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
    var adaBahan: Bool
    var ditolak: Bool

    static let tolak = ScanOutput(
        teks: "", teksPeringatan: "",
        kalimat: "Ditolak. Gambar ini bukan daftar komposisi.",
        peringatan: nil, penjelasan: nil, statusModel: "", jumlah: [:], adaBahan: false, ditolak: true
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
        let matched = IngredientMatch.kalimat(ocr: teksBahan, dipilih: dipilih)
        let mungkin = IngredientMatch.kalimat(ocr: teksPeringatan, dipilih: dipilih).hits
            .filter { !matched.hits.contains($0) }
        let peringatan = mungkin.isEmpty
            ? nil
            : "Label juga menulis dapat mengandung \(IngredientMatch.gabungNama(mungkin.map(\.kataDiKalimat)))."

        // 3. Foundation Models menjelaskan kenapa kata yang terbaca termasuk pantangan.
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
            adaBahan: !matched.hits.isEmpty,
            ditolak: false
        )
    }

    private static func jelaskan(
        hits: [Pantangan], mungkin: [Pantangan],
        teksBahan: String, teksPeringatan: String
    ) async -> (String?, String) {
        guard !(hits.isEmpty && mungkin.isEmpty) else {
            return (nil, "Foundation Models: tidak ada pantangan untuk dijelaskan")
        }
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            return (nil, "Foundation Models tidak tersedia: iPhone ini tidak mendukung Apple Intelligence")
        case .unavailable(.appleIntelligenceNotEnabled):
            return (nil, "Foundation Models tidak tersedia: Apple Intelligence belum dinyalakan")
        case .unavailable(.modelNotReady):
            return (nil, "Foundation Models tidak tersedia: model Apple Intelligence masih diunduh")
        case .unavailable(let alasan):
            return (nil, "Foundation Models tidak tersedia: \(alasan)")
        }
        if !model.supportsLocale() {
            return (nil, "Foundation Models tidak mendukung bahasa iPhone (\(Locale.current.identifier)). Ganti bahasa iPhone ke English")
        }
        var jumlahKata = mungkin.count
        var faktaID: [String] = []
        var faktaEN: [String] = []
        for p in hits {
            let daftar = IngredientMatch.kataCocok(p, di: teksBahan)
            jumlahKata += max(1, daftar.count)
            let kata = daftar.joined(separator: ", ")
            faktaID.append("\(p.kataDiKalimat) ada di daftar bahan, tertulis: \(kata)")
            faktaEN.append("\(p.namaInggris) is in the ingredient list, written on the label as: \(kata)")
        }
        for p in mungkin {
            faktaID.append("\(p.kataDiKalimat) hanya ada di kalimat dapat mengandung")
            faktaEN.append("\(p.namaInggris) only appears in a may-contain statement")
        }
        let maks = min(3, jumlahKata)
        let boleh = Set(hits + mungkin)

        // Coba bahasa Indonesia dulu. Di iPhone fisik, Foundation Models menolak teks Indonesia
        // ("unsupported language or locale"), jadi ulangi dalam bahasa Inggris.
        let sessionID = LanguageModelSession(instructions: """
        Kamu menjelaskan label kemasan makanan dalam bahasa Indonesia, untuk orang yang punya pantangan makan.
        Tulis satu kalimat pendek untuk setiap fakta, paling banyak tiga kalimat.
        Jelaskan arti kata yang tertulis, misalnya nama Latin, nama Inggris, atau bahan turunan.
        Jangan memakai kata aman. Jangan memberi saran medis. Jangan menyebut bahan yang tidak ada di fakta.

        Contoh fakta: susu ada di daftar bahan, tertulis: whey bubuk
        Contoh jawaban: Whey bubuk dibuat dari susu.
        Contoh fakta: telur hanya ada di kalimat dapat mengandung
        Contoh jawaban: Telur bukan bahan produk ini, tetapi pabriknya juga mengolah telur, jadi bisa ada sisa.
        """)
        do {
            let reply = try await sessionID.respond(to: "Fakta:\n" + faktaID.joined(separator: "\n")).content
            guard let teks = diterima(reply, boleh: boleh, maksKalimat: maks, inggris: false) else {
                print("PANTANG FM ditolak: \(reply)")
                return (nil, "Penjelasan Foundation Models ditolak pengecek")
            }
            return (teks, "Penjelasan dari Foundation Models")
        } catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
            print("PANTANG FM: bahasa Indonesia ditolak, coba bahasa Inggris")
        } catch {
            print("PANTANG FM error: \(error)")
            return (nil, "Foundation Models gagal: \(error.localizedDescription)")
        }

        let sessionEN = LanguageModelSession(instructions: """
        You explain food package labels for people who avoid certain foods.
        Write one short sentence per fact, at most three sentences, in plain English.
        Explain what the written word means, for example a Latin name, an Indonesian name, or a derived ingredient.
        Do not use the word safe. Do not give medical advice. Do not mention ingredients that are not in the facts.

        Example fact: milk is in the ingredient list, written on the label as: whey bubuk
        Example answer: Whey bubuk is whey powder, which is made from milk.
        Example fact: egg only appears in a may-contain statement
        Example answer: Egg is not an ingredient, but the factory also handles egg, so traces are possible.
        """)
        do {
            let reply = try await sessionEN.respond(to: "Facts:\n" + faktaEN.joined(separator: "\n")).content
            guard let teks = diterima(reply, boleh: boleh, maksKalimat: maks, inggris: true) else {
                print("PANTANG FM ditolak (EN): \(reply)")
                return (nil, "Penjelasan Foundation Models ditolak pengecek")
            }
            return (teks, "Penjelasan dari Foundation Models (bahasa Inggris)")
        } catch {
            print("PANTANG FM error (EN): \(error)")
            return (nil, "Foundation Models gagal: \(error.localizedDescription)")
        }
    }

    /// Penjelasan ditolak kalau memakai kata "aman", terlalu panjang, atau menyebut pantangan lain.
    /// Hanya kalimat sebanyak kata yang dijelaskan yang dipakai; sisanya biasanya mengulang.
    private static func diterima(_ mentah: String, boleh: Set<Pantangan>, maksKalimat: Int, inggris: Bool) -> String? {
        let rapi = mentah.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        let potong = rapi.components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: " .")) }
            .filter { !$0.isEmpty }
            .prefix(maksKalimat)
        let teks = potong.map { $0 + "." }.joined(separator: " ")
        let lower = teks.lowercased()
        let kataLarang = inggris ? "safe" : "aman"
        guard !teks.isEmpty, teks.count <= 320, !lower.contains(kataLarang) else { return nil }
        for p in Pantangan.allCases where !boleh.contains(p) && lower.contains(inggris ? p.namaInggris : p.kataDiKalimat) {
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
