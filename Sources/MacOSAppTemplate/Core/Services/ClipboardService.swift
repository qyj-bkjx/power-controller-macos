import AppKit
import Foundation

@MainActor
protocol ClipboardServicing: Sendable {
    func copy(_ value: String)
}

@MainActor
struct ClipboardService: ClipboardServicing {
    func copy(_ value: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }
}
