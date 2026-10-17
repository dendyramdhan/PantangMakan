// Langkah 6: melatih PemilahKalimat.mlmodel dengan framework Create ML di Mac ini.
// Jalankan dari folder repo: swift dataset/latih.swift
//
// - train      : dipakai untuk belajar
// - validation : dipakai Create ML selama latihan untuk mengukur model (tidak ikut belajar)
// - test       : tidak disentuh sama sekali sampai model selesai, untuk angka akhir
import CreateML
import TabularData
import Foundation

let dir = URL(fileURLWithPath: "dataset")
func tabel(_ nama: String) throws -> MLDataTable {
    try MLDataTable(contentsOf: dir.appendingPathComponent("kalimat-\(nama).csv"))
}
let train = try tabel("train")
let validation = try tabel("validation")
let test = try tabel("test")

func akurasi(_ model: MLTextClassifier, _ data: MLDataTable, _ nama: String) throws -> Double {
    var benar = 0
    var salah: [String: Int] = [:]
    let baris = data.rows.map { ($0["text"]?.stringValue ?? "", $0["label"]?.stringValue ?? "") }
    for (teks, label) in baris {
        let tebak = try model.prediction(from: teks)
        if tebak == label { benar += 1 } else { salah["\(label) -> \(tebak)", default: 0] += 1 }
    }
    let persen = Double(benar) / Double(baris.count) * 100
    print("\(nama): \(benar)/\(baris.count) benar (\(String(format: "%.1f", persen))%)")
    for (k, v) in salah.sorted(by: { $0.value > $1.value }) { print("    salah \(k): \(v)") }
    return persen
}

// maxEnt: embedding bawaan Apple (transfer learning) belum mendukung bahasa Indonesia.
let params = MLTextClassifier.ModelParameters(
    validation: .dataFrame(try DataFrame(contentsOfCSVFile: dir.appendingPathComponent("kalimat-validation.csv")), textColumn: "text", labelColumn: "label"),
    algorithm: .maxEnt(revision: 1),
    language: nil
)
let model = try MLTextClassifier(trainingData: train, textColumn: "text", labelColumn: "label", parameters: params)

_ = try akurasi(model, train, "train     ")
_ = try akurasi(model, validation, "validation")
let uji = try akurasi(model, test, "test      ")

let meta = MLModelMetadata(
    author: "Grup 5",
    shortDescription: "Memilah kalimat label kemasan: bahan, peringatan (dapat mengandung), atau lain. Create ML maxEnt, akurasi test \(String(format: "%.1f", uji))%.",
    version: "2"
)
try model.write(to: URL(fileURLWithPath: "ScanBite/Models/PemilahKalimat.mlmodel"), metadata: meta)
print("disimpan: ScanBite/Models/PemilahKalimat.mlmodel")
