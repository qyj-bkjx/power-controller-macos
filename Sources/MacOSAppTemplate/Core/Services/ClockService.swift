import Foundation

@MainActor
protocol ClockServicing: Sendable {
    func nowText() -> String
}

@MainActor
struct SystemClockService: ClockServicing {
    func nowText() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}
