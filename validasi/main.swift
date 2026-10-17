// Evaluasi di Mac: alur sama dengan app (Vision OCR -> gerbang Komposisi -> daftar kata),
// semua pantangan dipilih. Foundation Models tidak ikut karena hanya menyusun kalimat.
import AppKit
import Foundation
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

let semua = Set(Pantangan.allCases)
for path in CommandLine.arguments.dropFirst() {
    let teks = ocr(path)
    let nama = (path as NSString).lastPathComponent
    guard let komposisi = IngredientMatch.bagianKomposisi(teks) else {
        print("\(nama)\tDITOLAK\t-")
        continue
    }
    let hasil = IngredientMatch.kalimat(ocr: komposisi, dipilih: semua)
    let hits = hasil.hits.map(\.rawValue).sorted().joined(separator: ",")
    print("\(nama)\t\(hits.isEmpty ? "-" : hits)\t\(hasil.kalimat)")
}
