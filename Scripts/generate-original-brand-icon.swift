// Copy the user-approved MyChuannong icon into the iOS brand resources.
// Run from the iOS project directory; the master is kept outside generated assets.
import Foundation
import ImageIO

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let master = root.appending(path: "DesignReferences/MyChuannongBrand/ApprovedIcon.png")
let data = try Data(contentsOf: master)
guard let source = CGImageSourceCreateWithData(data as CFData, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      image.width == 1024, image.height == 1024 else {
    fatalError("The approved 1024 × 1024 brand icon is missing or invalid")
}
let logo = root.appending(path: "Resources/my_chuannong_brand_logo.png")
let brandMark = root.appending(path: "Resources/Assets.xcassets/BrandMark.imageset", directoryHint: .isDirectory)
try FileManager.default.createDirectory(at: brandMark, withIntermediateDirectories: true)
try data.write(to: logo, options: .atomic)
try data.write(to: brandMark.appending(path: "BrandMark.png"), options: .atomic)
try Data(#"{"images":[{"filename":"BrandMark.png","idiom":"universal"}],"info":{"author":"xcode","version":1}}"#.utf8)
    .write(to: brandMark.appending(path: "Contents.json"), options: .atomic)
print("Copied the approved white-background 川 brand icon to iOS brand resources.")
