import AppKit; import Vision; import Foundation
var out: [String: [String]] = [:]
for path in CommandLine.arguments.dropFirst() {
  autoreleasepool {
    guard let img = NSImage(contentsOfFile: path) else { return }
    var r = CGRect(origin: .zero, size: img.size)
    guard let cg = img.cgImage(forProposedRect: &r, context: nil, hints: nil) else { return }
    let req = VNRecognizeTextRequest(); req.recognitionLevel = .accurate; req.recognitionLanguages = ["id-ID","en-US"]; req.usesLanguageCorrection = true
    try? VNImageRequestHandler(cgImage: cg, orientation: .up).perform([req])
    out[(path as NSString).lastPathComponent] = (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }
  }
}
let data = try! JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
FileManager.default.createFile(atPath: "dataset/ocr.json", contents: data)
print(out.count)
