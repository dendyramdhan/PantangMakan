import CoreML
import Foundation
import FoundationModels
import NaturalLanguage
import UIKit
import Vision

struct ScanOutput: Equatable {
    var teks: String
    var modelTeks: String
    var kalimat: String
    var sumber: String
    var kalimatAPI: String
    var koneksiGagal: Bool
    var adaBahan: Bool
    var ditolak: Bool
}

enum ScanService {
    static func scan(image: UIImage, dipilih: Set<Pantangan>) async -> ScanOutput {
        let ocr = recognizeText(in: image)
        guard !ocr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ScanOutput(
                teks: "",
                modelTeks: "Tidak dikenali",
                kalimat: "Ditolak. Gambar ini bukan daftar komposisi.",
                sumber: "Kata yang cocok",
                kalimatAPI: "",
                koneksiGagal: false,
                adaBahan: false,
                ditolak: true
            )
        }
        guard let komposisi = IngredientMatch.bagianKomposisi(ocr) else {
            return ScanOutput(
                teks: "",
                modelTeks: "Tidak dikenali",
                kalimat: "Ditolak. Gambar ini bukan daftar komposisi.",
                sumber: "Kata yang cocok",
                kalimatAPI: "",
                koneksiGagal: false,
                adaBahan: false,
                ditolak: true
            )
        }
        let matched = IngredientMatch.kalimat(ocr: komposisi, dipilih: dipilih)
        let modelTeks = klasifikasi(komposisi)

        if SystemLanguageModel.default.isAvailable {
            if let dariModel = await phraseWithFoundationModel(fakta: matched.kalimat, hits: matched.hits) {
                return ScanOutput(
                    teks: komposisi,
                    modelTeks: modelTeks,
                    kalimat: dariModel,
                    sumber: "Foundation Models",
                    kalimatAPI: "",
                    koneksiGagal: false,
                    adaBahan: !matched.hits.isEmpty,
                    ditolak: false
                )
            }
            return aturan(komposisi, modelTeks: modelTeks, matched: matched)
        }

        if let dariAPI = await phraseWithDicoding(fakta: matched.kalimat, hits: matched.hits) {
            return ScanOutput(
                teks: komposisi,
                modelTeks: modelTeks,
                kalimat: dariAPI,
                sumber: "API Dicoding",
                kalimatAPI: dariAPI,
                koneksiGagal: false,
                adaBahan: !matched.hits.isEmpty,
                ditolak: false
            )
        }

        return aturan(komposisi, modelTeks: modelTeks, matched: matched, koneksiGagal: true)
    }

    private static func aturan(
        _ komposisi: String,
        modelTeks: String,
        matched: (hits: [Pantangan], kalimat: String),
        koneksiGagal: Bool = false
    ) -> ScanOutput {
        ScanOutput(
            teks: komposisi,
            modelTeks: modelTeks,
            kalimat: matched.kalimat,
            sumber: "Kata yang cocok",
            kalimatAPI: "",
            koneksiGagal: koneksiGagal,
            adaBahan: !matched.hits.isEmpty,
            ditolak: false
        )
    }

    private static func klasifikasi(_ teks: String) -> String {
        let bersih = teks.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bersih.isEmpty else { return "Tidak dikenali" }
        guard let ml = try? PantanganText(configuration: MLModelConfiguration()).model,
              let nl = try? NLModel(mlModel: ml) else {
            return "Model tidak termuat"
        }
        let hyps = nl.predictedLabelHypotheses(for: bersih.lowercased(), maximumCount: 1)
        guard let top = hyps.max(by: { $0.value < $1.value }) else { return "Tidak dikenali" }
        return "\(top.key) \(Int(top.value * 100))%"
    }

    private static func phraseWithFoundationModel(fakta: String, hits: [Pantangan]) async -> String? {
        guard SystemLanguageModel.default.isAvailable else { return nil }
        let session = LanguageModelSession(instructions: """
        Kamu menulis tepat satu kalimat bahasa Indonesia.
        Salin faktanya. Jangan mengubah susunan kata.
        Jangan menambah bahan atau angka.
        """)
        let prompt = "Tulis ulang fakta ini persis. Fakta: \(fakta)"
        guard let reply = try? await session.respond(to: prompt).content else { return nil }
        return diterima(reply, hits: hits)
    }

    private static func phraseWithDicoding(fakta: String, hits: [Pantangan]) async -> String? {
        guard let url = URL(string: "https://oss.dicoding-ai.dev/v1/chat/completions") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 40
        let payload: [String: Any] = [
            "model": "openai/gpt-oss-20b",
            "messages": [
                ["role": "user", "content": "Balas dengan satu kalimat bahasa Indonesia saja. Jangan menambah benda baru. Salin faktanya. Fakta: \(fakta)"]
            ],
            "max_tokens": 2000,
            "temperature": 0.2
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return nil }
        request.httpBody = body
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            return nil
        }
        return diterima(content, hits: hits)
    }

    private static func diterima(_ mentah: String, hits: [Pantangan]) -> String? {
        let kalimat = mentah
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
        guard !kalimat.isEmpty else { return nil }
        let lower = kalimat.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if hits.isEmpty {
            guard lower.hasPrefix("aman"), lower.contains("tidak mengandung"), !lower.contains("tidak aman") else { return nil }
            return kalimat
        }
        guard lower.hasPrefix("tidak aman"), lower.contains("mengandung"), !lower.contains("tidak mengandung") else { return nil }
        for hit in hits where !lower.contains(hit.kataDiKalimat) {
            return nil
        }
        return kalimat
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
