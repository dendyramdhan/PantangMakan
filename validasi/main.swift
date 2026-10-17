// Evaluasi di Mac dengan alur yang sama seperti app:
// Vision OCR -> gerbang Komposisi -> Create ML PemilahKalimat -> daftar kata.
// Keenam pantangan dipilih. Foundation Models tidak ikut karena hanya menulis penjelasan.
import AppKit
import CoreML
import Foundation
import NaturalLanguage
import Vision

func ocr(_ path: String) -> String {
    guard let img = NSImage(contentsOfFile: path) else { return "" }
    var rect = CGRect(origin: .zero, size: img.size)
    guard let cg = img.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return "" }
    let req = VNRecognizeTextRequest()
    req.recognitionLevel = .accurate
    req.recognitionLanguages = ["id-ID", "en-US"]
    req.usesLanguageCorrection = true
    try? VNImageRequestHandler(cgImage: cg, orientation: .up).perform([req])
    return (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
}

let pakaiModel = !CommandLine.arguments.contains("--tanpa-model")
var model: NLModel?
if pakaiModel {
    let url = try MLModel.compileModel(at: URL(fileURLWithPath: "PantangMakan/Models/PemilahKalimat.mlmodel"))
    model = try NLModel(contentsOf: url)
}
let semua = Set(Pantangan.allCases)
let urut: (Pantangan, Pantangan) -> Bool = { $0.rawValue < $1.rawValue }
for path in CommandLine.arguments.dropFirst() where !path.hasPrefix("--") {
    let nama = (path as NSString).lastPathComponent
    guard let komposisi = IngredientMatch.bagianKomposisi(ocr(path)) else {
        print("\(nama)\tDITOLAK\t-\t-")
        continue
    }
    let kalimat = Pemilah.pilah(komposisi, model: model)
    let bahan = kalimat.filter { $0.jenis == .bahan }.map(\.teks).joined(separator: "\n")
    let peringatan = kalimat.filter { $0.jenis == .peringatan }.map(\.teks).joined(separator: "\n")
    let hits = IngredientMatch.kalimat(ocr: bahan, dipilih: semua).hits
    let mungkin = IngredientMatch.kalimat(ocr: peringatan, dipilih: semua).hits.filter { !hits.contains($0) }
    let a = hits.sorted(by: urut).map(\.rawValue).joined(separator: ",")
    let b = mungkin.sorted(by: urut).map(\.rawValue).joined(separator: ",")
    print("\(nama)\t\(a.isEmpty ? "-" : a)\t\(b.isEmpty ? "-" : b)")
    if CommandLine.arguments.contains("--rinci") {
        for k in kalimat { print("    [\(k.jenis.rawValue)] \(k.teks.prefix(110))") }
    }
}
