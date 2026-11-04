// Draw the approved original leaf. Run from the iOS project directory.
// The square image feeds the App Store icon; the transparent image is used in the UI.
import CoreGraphics
import Foundation
import ImageIO

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let size = 1024
let green = CGColor(red: 35 / 255, green: 122 / 255, blue: 102 / 255, alpha: 1)
let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

func drawLeaf(on context: CGContext) {
    context.translateBy(x: 0, y: 1024)
    context.scaleBy(x: 1, y: -1)
    let leaf = CGMutablePath()
    leaf.move(to: CGPoint(x: 512, y: 792))
    leaf.addCurve(to: CGPoint(x: 303, y: 493), control1: CGPoint(x: 407, y: 718), control2: CGPoint(x: 303, y: 622))
    leaf.addCurve(to: CGPoint(x: 512, y: 181), control1: CGPoint(x: 303, y: 349), control2: CGPoint(x: 398, y: 239))
    leaf.addCurve(to: CGPoint(x: 721, y: 493), control1: CGPoint(x: 626, y: 239), control2: CGPoint(x: 721, y: 349))
    leaf.addCurve(to: CGPoint(x: 512, y: 792), control1: CGPoint(x: 721, y: 622), control2: CGPoint(x: 617, y: 718))
    leaf.closeSubpath()
    context.setFillColor(green)
    context.addPath(leaf)
    context.fillPath()

    context.setStrokeColor(green)
    context.setLineWidth(34)
    context.setLineCap(.round)
    context.move(to: CGPoint(x: 512, y: 771))
    context.addLine(to: CGPoint(x: 512, y: 838))
    context.strokePath()

    context.setStrokeColor(white)
    context.setLineWidth(22)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.move(to: CGPoint(x: 512, y: 746))
    context.addCurve(to: CGPoint(x: 512, y: 292), control1: CGPoint(x: 512, y: 620), control2: CGPoint(x: 512, y: 424))
    context.strokePath()
    context.setLineWidth(17)
    for (x1, y1, x2, y2) in [(512.0, 610.0, 415.0, 525.0), (512.0, 610.0, 609.0, 525.0), (512.0, 495.0, 444.0, 423.0), (512.0, 495.0, 580.0, 423.0)] {
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
        context.strokePath()
    }
}

func render(background: Bool) -> CGImage {
    guard let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        fatalError("Could not create the icon drawing context")
    }
    if background {
        context.setFillColor(white)
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))
    }
    drawLeaf(on: context)
    guard let image = context.makeImage() else { fatalError("Could not render the icon") }
    return image
}

func writePNG(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
        fatalError("Could not create PNG destination")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("Could not save PNG") }
}

let logo = root.appending(path: "Resources/my_chuannong_brand_logo.png")
let imageset = root.appending(path: "Resources/Assets.xcassets/BrandMark.imageset", directoryHint: .isDirectory)
try FileManager.default.createDirectory(at: imageset, withIntermediateDirectories: true)
try writePNG(render(background: true), to: logo)
guard let mark = render(background: false).cropping(to: CGRect(x: 287, y: 165, width: 450, height: 706)) else {
    fatalError("Could not crop the transparent brand mark")
}
try writePNG(mark, to: imageset.appending(path: "BrandMark.png"))
try Data(#"{"images":[{"filename":"BrandMark.png","idiom":"universal"}],"info":{"author":"xcode","version":1}}"#.utf8).write(to: imageset.appending(path: "Contents.json"))
print("Generated the approved original leaf and transparent in-app mark.")
