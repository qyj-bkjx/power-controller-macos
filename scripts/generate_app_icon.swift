import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = root.appendingPathComponent("AppBundle/AppIcon.iconset", isDirectory: true)

let variants: [(name: String, size: CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

for variant in variants {
    let image = NSImage(size: NSSize(width: variant.size, height: variant.size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: variant.size, height: variant.size)
    let radius = variant.size * 0.23

    let gradient = NSGradient(
        colors: [
            NSColor(calibratedRed: 0.10, green: 0.13, blue: 0.18, alpha: 1),
            NSColor(calibratedRed: 0.08, green: 0.45, blue: 0.78, alpha: 1)
        ]
    )!
    let path = NSBezierPath(roundedRect: rect.insetBy(dx: variant.size * 0.03, dy: variant.size * 0.03), xRadius: radius, yRadius: radius)
    gradient.draw(in: path, angle: 270)

    NSGraphicsContext.current?.imageInterpolation = .high

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
    shadow.shadowBlurRadius = variant.size * 0.05
    shadow.shadowOffset = NSSize(width: 0, height: -variant.size * 0.02)
    shadow.set()

    let text = NSString(string: "power")
    let fontSize = variant.size * 0.22
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .black),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
        .kern: -0.6
    ]

    let textSize = text.size(withAttributes: attributes)
    let textRect = NSRect(
        x: (variant.size - textSize.width) / 2,
        y: (variant.size - textSize.height) / 2 - variant.size * 0.02,
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect, withAttributes: attributes)

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Failed to generate \(variant.name)")
    }

    try png.write(to: iconsetURL.appendingPathComponent(variant.name))
}
