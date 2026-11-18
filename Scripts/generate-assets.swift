// Package the approved, opaque 1024 × 1024 icon for Apple's asset catalog.
// Run from the iOS project directory after generate-original-brand-icon.swift.
import Foundation
import ImageIO
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let original = root.appending(path: "Resources/my_chuannong_brand_logo.png")
let data = try Data(contentsOf: original)
guard let source = CGImageSourceCreateWithData(data as CFData, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      image.width == 1024, image.height == 1024,
      image.alphaInfo == .none || image.alphaInfo == .noneSkipFirst || image.alphaInfo == .noneSkipLast else {
    fatalError("The approved iOS app icon must be an opaque 1024 × 1024 PNG")
}
let folder = root.appending(path: "Resources/Assets.xcassets/AppIcon.appiconset", directoryHint: .isDirectory)
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
try data.write(to: folder.appending(path: "AppIcon.png"), options: .atomic)
try Data(#"{"images":[{"filename":"AppIcon.png","idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"author":"xcode","version":1}}"#.utf8)
    .write(to: folder.appending(path: "Contents.json"), options: .atomic)
try Data(#"{"info":{"author":"xcode","version":1}}"#.utf8)
    .write(to: folder.deletingLastPathComponent().appending(path: "Contents.json"), options: .atomic)
print("Packaged the approved iOS app icon.")
