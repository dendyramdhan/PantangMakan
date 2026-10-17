// Melatih PemilahKalimat.mlmodel dengan Create ML.
// Jalankan dari folder repo: swift dataset/latih.swift
import CreateML
import Foundation

let dir = URL(fileURLWithPath: "dataset")
let train = try MLDataTable(contentsOf: dir.appendingPathComponent("kalimat-train.csv"))
let test = try MLDataTable(contentsOf: dir.appendingPathComponent("kalimat-test.csv"))

// Embedding bawaan Apple tidak mendukung bahasa Indonesia, jadi dipakai maxEnt.
let algoritma: [(String, MLTextClassifier.ModelAlgorithmType)] = [
    ("maxEnt", .maxEnt(revision: 1)),
]
// Evaluasi manual per baris supaya terlihat salahnya di kelas mana.
let teksUji = test.rows.map { $0["text"]?.stringValue ?? "" }
let labelUji = test.rows.map { $0["label"]?.stringValue ?? "" }
var terbaik: (String, MLTextClassifier, Double)?
for (nama, algo) in algoritma {
    let params = MLTextClassifier.ModelParameters(algorithm: algo, language: nil)
    let model = try MLTextClassifier(trainingData: train, textColumn: "text", labelColumn: "label", parameters: params)
    var benar = 0
    var bingung: [String: Int] = [:]
    for (teks, label) in zip(teksUji, labelUji) {
        let tebak = try model.prediction(from: teks)
        if tebak == label { benar += 1 } else { bingung["\(label) -> \(tebak)", default: 0] += 1 }
    }
    let akurasi = Double(benar) / Double(teksUji.count) * 100
    print("\(nama): \(benar)/\(teksUji.count) benar, akurasi data uji \(String(format: "%.1f", akurasi))%")
    for (k, v) in bingung.sorted(by: { $0.value > $1.value }) { print("  salah \(k): \(v)") }
    if terbaik == nil || akurasi > terbaik!.2 { terbaik = (nama, model, akurasi) }
}
let (nama, model, akurasi) = terbaik!
let meta = MLModelMetadata(author: "Grup 5", shortDescription: "Memilah kalimat label kemasan: bahan, peringatan (dapat mengandung), atau lain. Algoritma \(nama), akurasi uji \(String(format: "%.1f", akurasi))%.", version: "1")
try model.write(to: URL(fileURLWithPath: "PantangMakan/Models/PemilahKalimat.mlmodel"), metadata: meta)
print("disimpan: \(nama)")
